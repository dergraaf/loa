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
	
	public Upload(String portName, int baudrate, File file) throws IOException {
		bitfile = file;
		connection = new Connection(new loa.sab.Decoder());
		connection.addCommunicatable(this);
		
		connection.connect(new PortIdentifier(portName));
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
		
		FileInputStream reader = new FileInputStream(bitfile);
		byte[] buffer = new byte[32];
		
		int remaingBytes = bitstreamSize;
		// round up to the next full 256 Byte border
		short segmentCount = (short) (Math.ceil(((float) bitstreamSize) / 256.0) * 8);
		short segment = 0;
		
		setSegment(segment);
		while (segment < segmentCount) {
			int size = remaingBytes;
			if (size > 32) {
				size = 32;
			}
			remaingBytes -= size;
			
			reader.read(buffer, 0, size);
			short segmentWritten = storeSegment(buffer);
			
			if (segment != segmentWritten) {
				throw new IOException("Segment number mismatch!");
			}
			System.out.println("segment=" + segmentWritten);
			segment++;
		}
		
		System.out.println("Finished!");
	}
	
	private int getBitstreamSize() {
		ByteBuffer b = send(0x02, 'b', new byte[0], 4);
		return b.getInt();
	}
	
	private void setSegment(short segment) {
		ByteBuffer b = ByteBuffer.allocate(2);
		b.order(ByteOrder.LITTLE_ENDIAN);
		b.putShort(segment);
		
		send(0x02, 's', b.array());
	}
	
	private short storeSegment(byte[] data) {
		ByteBuffer b = send(0x02, 'S', data, 2);
		return b.getShort();
	}
	
	/**
	 * Send a message and wait for the response.
	 * 
	 * @param address	Address of the SAB slave
	 * @param command	Command
	 * @param data		Data array
	 * @param expectedSize	Expected size of the response
	 * @return	Received data wrapped into a ByteBuffer
	 * @throws TimeoutException
	 */
	private ByteBuffer send(int address, int command, byte[] data,
			int expectedSize) throws TimeoutException {
		synchronized (this) {
			transmittedFrame = new Frame(address, command, data);
			this.expectedSize = expectedSize;
		}
		connection.sendMessage(transmittedFrame);
		
		// DEBUG
		//System.out.println("< " + transmittedFrame.toString());
		
		try {
			if (receiveSemaphore.tryAcquire(500, TimeUnit.MILLISECONDS))
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
		return send(address, command, data, 0);
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
				System.err.printf("Unexpected length: %i, expected %i\n",
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