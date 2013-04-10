package de.rwth_aachen.roboterclub.serial.io;

import java.io.*;
import java.util.concurrent.SynchronousQueue;

//import javax.comm.SerialPort;
import gnu.io.SerialPort;
import de.rwth_aachen.roboterclub.serial.io.messages.*;

public class InputOutputProcess extends Thread {
	private boolean synchronousReadWrite = false;
	SynchronousQueue<QueueElement> messageOutputQueue = new SynchronousQueue<QueueElement>();

	private SerialPort serialPort;
	private Connection connection;
	private boolean verbose;

	// private MyBlueInputStreamReader inputStream;
	// private MyOutputStreamWriter outputStream;
	public InputOutputProcess(Connection connection, SerialPort serialPort, boolean verbose) {
		this.serialPort = serialPort;
		this.connection = connection;
		this.verbose = verbose;
		preformStreams();
	}

	public void run() {
		try {
			while (isConnected()) {
				processInput();
				if (synchronousReadWrite)
					processOutput();
			}
			cleanUp();
		} catch (IOException e) {
			// Comon.showErrorMessage("I/O error: ",
			// "Allgemeiner Ausnahmefehler");
			// Comon.showErrorMessage("I/O error: ", e.toString());
			// Comon.showErrorMessage("I/O error: ", e.getMessage());
			System.err.println("Fataler I/O error beim IOThread: "
					+ e.toString());
			e.printStackTrace();
			// if (Server == "")
			// System.err.println("Clent " + PORT + " hat sich verabschiedet");
			cleanUp();
		}
	}

	private void processOutput() {
		QueueElement e = messageOutputQueue.poll();
		if (e == null)
			return;
		try {
			e.decoder.writeMessage(e.message);
		} catch (Exception ex) {
			System.err.println("Fehlgeschlagen. " + ex.toString());
			ex.printStackTrace();
		}
	}

	private void preformStreams() {
		// Perform severs connection
		try {
			if (verbose)
				System.out.println("Versuche OutStream zu erstellen");
			
			// outputStream =
			// connection.getMessageDecoder().setOutputStream(serialPort.getOutputStream());
			connection.getMessageDecoder().setOutputStream(
					serialPort.getOutputStream());
			
			if (verbose) {
				System.out.println("OutStream Erstellt");
				System.out.println("Versuche InputStream zu erstellen");
			}
			// inputStream = new
			// MyBlueInputStreamReader(serialPort.getInputStream());
			connection.getMessageDecoder().setInputStream(
					serialPort.getInputStream());
			
			if (verbose)
				System.out.println("InputStream Erstellt");
		} catch (IOException e) {
			System.err.println("Exception: couldn't create Streams! "
					+ e.getMessage());
			e.printStackTrace();
			cleanUp();
		}
	}

	/**
	 * connected
	 * 
	 * @return boolean
	 * @todo wie herausfinden ob port connected
	 */
	public boolean isConnected() {
		return serialPort != null;
	}

	/**
	 * cleanUp
	 * 
	 * @todo Gucken wie herausfinden ob port noch connected ist.
	 */
	public void cleanUp() {
		try {
			// Cleanup
			if (isConnected()) {
				if (verbose)
					System.out.println("Verbindung wird geschlossen");
				
				connection.getMessageDecoder().closeOutput();
				connection.getMessageDecoder().closeInput();
				SerialPort s = serialPort;
				serialPort = null;
				s.close();
				if (verbose)
					System.out.println("Meine Verbindung wurde erfolgreich geschlossen");
				connection.portClosed();
			}
		} catch (Exception e) {
			serialPort = null;
			System.err.println("Exception beim Clean Up: " + e.toString());
			System.out.println("Meine Verbindung wurde nicht geschlossen");
			e.printStackTrace();
		}
	}

	/**
	 * processOutput since it is possible to send messages via different
	 * decoders MessageDecoder have to be passed here.
	 * 
	 * @param outMsg
	 *            Message
	 * @param decoder
	 * @return boolean
	 * @todo Eigenen buffered reader schreiben mit close und so
	 */
	public synchronized boolean processOutput(Message outMsg,
			MessageDecoder decoder) {
		if (isConnected() && outMsg != null) {
			// System.out.println("Gesendet: " + outMsg);
			try {
				if (synchronousReadWrite)
					messageOutputQueue.put(new QueueElement(outMsg, decoder));
				else {
					processOutput();
					try {
						decoder.writeMessage(outMsg);
					} catch (Exception ex) {
						System.err.println("Fehlgeschlagen. " + ex.toString());
						ex.printStackTrace();
					}
				}
				return true;
			} catch (Exception ee) {
				System.err.println("Fehlgeschlagen. " + ee.toString());
				System.err.println("Aber Ganz Doof");
				ee.printStackTrace();
				return false;
			}
		} else {
			return false;
		}
	}

	/**
	 * processInput
	 * 
	 * @throws IOException
	 * 
	 * @todo InputOutputProcess sollte der listener sein und immer gucken ob
	 *       alles mit der hardware noch stimmt, und ob die verbindung noch
	 *       besteht und so.
	 */
	void processInput() throws IOException {
		// Process input
		//lesen, es wird jedes mal ein neues array erstellt!!!
		Message b = connection.getMessageDecoder().readMessage();
		try {
			if (b != null /* && b.length>0 */)
				connection.messageArived(b);
		} catch (Exception ex) {
			// Comon.showErrorMessage("I/O error: ",
			// "Der Stream-read wird weitergefhrt");
			System.err.println("Es ist ein Verarbeitungsfehler aufgetreten: "
					+ ex.toString());
			System.err.println("Der Stream-read wird weitergefhrt");
			ex.printStackTrace();
		}
	}
	
	class QueueElement {
		Message message;
		MessageDecoder decoder;

		public QueueElement(Message message, MessageDecoder decoder) {
			this.message = message;
			this.decoder = decoder;
		}

	}
}
