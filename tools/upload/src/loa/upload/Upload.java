package loa.upload;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.util.concurrent.Semaphore;
import java.util.concurrent.TimeUnit;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;

import loa.sab.Frame;

import com.beust.jcommander.JCommander;
import com.beust.jcommander.ParameterException;

import de.rwth_aachen.roboterclub.serial.io.Communicatable;
import de.rwth_aachen.roboterclub.serial.io.Connection;
import de.rwth_aachen.roboterclub.serial.io.PortIdentifier;
import de.rwth_aachen.roboterclub.serial.io.messages.Message;

public class Upload implements Communicatable {
	
	private Connection connection;
	private File bitfile;
	private int bitstreamSize;
	
	private Frame transmittedFrame;
	private int expectedSize;
	private byte[] receivedData;
	private Semaphore receiveSemaphore = new Semaphore(0);
	private String animation = "|/-\\";
	private int lastPercent = -1;
	private int defaultTimeout = 500;
	
	private final int segmentBufferSize = 256;
	
	public Upload(String portName, int baudrate, File file) throws IOException {
		bitfile = file;
		connection = new Connection(new loa.sab.Decoder());
		connection.addCommunicatable(this);
		
		connection.connect(new PortIdentifier(portName), baudrate);
		if (!connection.isConnected()) {
			throw new IOException("Could not open '" + portName + "'");
		}
	}
	
	private void disconnect() {
		if (connection != null && connection.isConnected()) {
			connection.disconnect();
		}
	}
	
	public void upload() throws IOException {
		bitstreamSize = getBitstreamSize();
		
		// Check file size
		if (bitfile.length() != bitstreamSize) {
			throw new IOException("Wrong filesize of '" + bitfile.getName() +
					"'. Expected " + bitstreamSize + " bytes, got " +
					bitfile.length() + " bytes.");
		}
		
		TimeWatch watch = TimeWatch.start();
		
		FileInputStream reader = new FileInputStream(bitfile);
		byte[] buffer = new byte[segmentBufferSize];
		
		int remaingBytes = bitstreamSize;
		// round up to the next full 256 Byte border
		short segmentCount = (short) (Math.ceil(((float) bitstreamSize) / 256.0) * (256 / segmentBufferSize));
		short segment = 0;
		
		setSegment(segment);
		while (segment < segmentCount) {
			int size = remaingBytes;
			if (size > segmentBufferSize) {
				size = segmentBufferSize;
			}
			remaingBytes -= size;
			
			reader.read(buffer, 0, size);
			short segmentWritten = storeSegment(segment, buffer);
			
			if (segment != segmentWritten) {
				throw new IOException("Segment number mismatch!");
			}
			
			reportProgress(segment, segmentCount);
			segment++;
		}
		reportProgress(segment, segmentCount);
		
		reloadFpga();
		
		// get elapsed time in Seconds
		watch.stop();
		float estimatedTime = ((float) watch.getTime(TimeUnit.MILLISECONDS)) / 1000.0f;
		
		int bytesWritten = (segmentCount * buffer.length);
		System.out.printf("\n\nwrote %d bytes in %.2fs (%.3f KiB/s)\n",
				bytesWritten,
				estimatedTime,
				bytesWritten / 1024f / estimatedTime);
	}
	
	private int getBitstreamSize() {
		ByteBuffer b = send(0x02, 'b', new byte[0], 4, defaultTimeout);
		return b.getInt();
	}
	
	private void setSegment(short segment) {
		ByteBuffer b = ByteBuffer.allocate(2);
		b.order(ByteOrder.LITTLE_ENDIAN);
		b.putShort(segment);
		
		send(0x02, 's', b.array());
	}
	
	private short storeSegment(short segment, byte[] data) {
		int tries = 3;
		while (true)
		{
			try {
				ByteBuffer b = send(0x02, 'S', data, 2, defaultTimeout);
				return b.getShort();
			}
			catch (TimeoutException e) {
				System.err.printf("Retry sending segment %d\n", segment);
				tries -= 1;
				if (tries == 0) {
					// Number of tries exceeded => abort
					throw e;
				}
				setSegment(segment);
			}
		}
	}
	
	private void reloadFpga() {
		send(0x02, 'r', new byte[0], 0, 3000);
	}
	
	/**
	 * Prints a simple Progressbar on the console.
	 * 
	 * @param completed	Events already done
	 * @param total		Total number of events
	 */
	private void reportProgress(int completed, int total) {
		int percent = (completed * 100) / total;
		if (lastPercent != percent) {
			lastPercent = percent;
			
			char spinnerCharacter = animation.charAt(percent % animation.length());
			
			System.out.print("\r");
			System.out.printf("%c %3d%% ", spinnerCharacter, percent);
			
			System.out.print("[");
			for (int i = 0; i < 50; i++) {
				if (i <= (percent / 2)) {
					System.out.print("=");
				}
				else {
					System.out.print(" ");
				}
			}
			System.out.print("] ");
		}
	}
	
	/**
	 * Send a message and wait for the response.
	 * 
	 * @param address	Address of the SAB slave
	 * @param command	Command
	 * @param data		Data array
	 * @param expectedSize	Expected size of the response
	 * @param timeout	Time until the response has to arrive
	 * @return	Received data wrapped into a ByteBuffer
	 * @throws TimeoutException
	 */
	private ByteBuffer send(int address, int command, byte[] data,
			int expectedSize, int timeout) throws TimeoutException {
		synchronized (this) {
			transmittedFrame = new Frame(address, command, data);
			this.expectedSize = expectedSize;
			connection.sendMessage(transmittedFrame);
		}
		
		// DEBUG
		//System.out.println("< " + transmittedFrame.toString());
		
		try {
			if (receiveSemaphore.tryAcquire(timeout, TimeUnit.MILLISECONDS))
			{
				ByteBuffer b;
				synchronized (this) {
					b = ByteBuffer.wrap(receivedData.clone());
					b.order(ByteOrder.LITTLE_ENDIAN);
				}
				return b;
			}
			else {
				throw new TimeoutException("No message received for " + 
						transmittedFrame.toString());
			}
		} catch (InterruptedException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	private ByteBuffer send(int address, int command, byte[] data)
			throws TimeoutException {
		return send(address, command, data, 0, defaultTimeout);
	}
	
	@Override
	public synchronized void messageArived(Message message) {
		Frame frame = (Frame) message;
		
		// DEBUG
		//System.out.println("> " + frame.toString());
		
		if (frame.isResponse(transmittedFrame)) {
			if (frame.type == Frame.Type.NACK) {
				System.err.printf("Received Error code: %d for %s\n",
						frame.data[0], transmittedFrame.toString());
			}
			else if (frame.data.length != expectedSize) {
				System.err.printf("Unexpected length: %d, expected %d\n",
						frame.data.length, expectedSize);
			}
			else {
				// TODO check that the data is processed before continuing
				receivedData = frame.data;
				receiveSemaphore.release();
			}
		}
		else {
			System.err.println("Unwanted message:");
			System.err.println(frame.toString());
			System.err.printf("expected (%02x > %02x)\n",
					transmittedFrame.address, transmittedFrame.command);
		}
	}
	
	public static void main(String[] args) {
		Upload loader = null;
		
		try {
			CommandLineArgs options = new CommandLineArgs();
			JCommander parser = new JCommander(options, args);
			
			if (options.files.size() != 1 || options.help) {
				parser.usage();
				System.exit(1);
			}
			
			// If the filename starts with a tilde it's relative to the
			// home folder of the user. Java doesn't resolve this, so it
			// needs to be done by hand here.
			String filename = options.files.get(0);
			if (filename.startsWith("~")) {
				filename = filename.replaceFirst("~", System.getProperty("user.home"));
			}
			File file = new File(filename);
			
			System.out.println("Port=" + options.port);
			System.out.println("Baud=" + options.baudrate.intValue());
			System.out.println("File=" + file.getAbsolutePath());
			
			loader = new Upload(options.port, options.baudrate.intValue(), file);
			loader.upload();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (TimeoutException e) {
			e.printStackTrace();
		} catch (ParameterException e) {
			System.out.println(e.getMessage());
		}
		
		if (loader != null) {
			loader.disconnect();
		}
	}
}
