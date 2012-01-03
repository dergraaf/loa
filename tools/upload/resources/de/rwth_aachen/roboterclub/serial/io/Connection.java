package de.rwth_aachen.roboterclub.serial.io;

import java.util.Vector;
import java.util.Enumeration;
import de.rwth_aachen.roboterclub.serial.io.messages.Message;
import de.rwth_aachen.roboterclub.serial.ui.PnlConnection; //import javax.comm.*;
import gnu.io.*;

public class Connection implements Sender, MessageDistributor {
	// Variablen für die Grafik
	private PnlConnection pnlConnection = null;

	// Variablen zur MessageVerwaltung
	private Vector<Communicatable> communicatables = new Vector<Communicatable>();
	private MessageDecoder decoder;

	// Variablen für die Verbindung
	private SerialPort serialPort;
	private InputOutputProcess inputOutputProcess = null;
	
	private boolean verbose = false;
	
	public Connection(MessageDecoder decoder) {
		this.decoder = decoder;
		this.verbose = false;
	}
	
	/**
	 * @param decoder	Decoder use to interpret the received bytes
	 * @param verbose	Display additional debug informations
	 */
	public Connection(MessageDecoder decoder, boolean verbose) {
		this.decoder = decoder;
		this.verbose = verbose;
	}
	
	public MessageDecoder getMessageDecoder() {
		return decoder;
	}

	public void setPnlConnection(PnlConnection pnlConnection) {
		this.pnlConnection = pnlConnection;
	}

	/**
	 * It is possible to generate more than one Sender which are using different
	 * decoder to send Messages.<br>
	 * Here generated Senders are Synchronized while sending data on
	 * InpunOutputProcess. <br>
	 * Note: there will be still exactly one decoder reading the inputstream.
	 * The one was passed to the constructor.
	 * 
	 * 
	 * @param decoder
	 * @return Sender associated with given decoder
	 */
	public Sender addMessageSender(MessageDecoder decoder) {
		Sender s = new SenderAdapter(decoder);
		return s;
	}

	/**
	 * sendMessage
	 * 
	 * @param message
	 *            Message
	 * @todo Implement this serialCommunications.io.Sender method
	 */
	public boolean sendMessage(Message message) {
		return sendMessage(message, decoder);
	}

	private boolean sendMessage(Message message, MessageDecoder decoder) {
		if (message != null && inputOutputProcess != null)
			return inputOutputProcess.processOutput(message, decoder);
		return false;
	}

	@SuppressWarnings( { "unchecked" } )
	public Enumeration enumPorts() {
		Enumeration enu = CommPortIdentifier.getPortIdentifiers();
		Vector identifiers = new Vector();
		while (enu.hasMoreElements())
			identifiers.add(new PortIdentifier((CommPortIdentifier) enu
					.nextElement()));
		return identifiers.elements();
	}

	public void disconnect() {
		if (inputOutputProcess != null)
			inputOutputProcess.cleanUp();
		else if (serialPort != null)
			serialPort.close();
	}

	public boolean isConnected() {
		return inputOutputProcess != null && inputOutputProcess.isConnected();
	}

	/**
	 * connect
	 * 
	 * @param portIdentifier
	 *            Object
	 * @return boolean
	 * @todo Destroy anders machen
	 */
	public boolean connect(Object portIdentifier) {
		if (inputOutputProcess != null && inputOutputProcess.isConnected()
				|| portIdentifier == null) {
			return false;
		}
		if (portIdentifier instanceof PortIdentifier
				&& ((PortIdentifier) portIdentifier).getCi()
						.getPortType() == CommPortIdentifier.PORT_SERIAL) {
			try {
				if (inputOutputProcess != null && inputOutputProcess.isAlive())
					throw new RuntimeException("InputOutput still alive"); // TODO

				serialPort = (SerialPort) ((PortIdentifier) portIdentifier)
						.getCi().open("CanCommunications", 2000);
				// int baud = serialPort.getBaudRate();
				serialPort.setSerialPortParams(115200, SerialPort.DATABITS_8,
						SerialPort.STOPBITS_1, SerialPort.PARITY_NONE);
				// serialPort.setSerialPortParams(9600,
				// SerialPort.DATABITS_8,
				// SerialPort.STOPBITS_1,
				// SerialPort.paPARITY_NONE);
				serialPort.enableReceiveTimeout(500);
				inputOutputProcess = new InputOutputProcess(this, serialPort, verbose);
				if (inputOutputProcess != null)
					inputOutputProcess.start();
				return true;
			} catch (PortInUseException piuEx) {
				System.err.println(piuEx.getMessage());
				// piuEx.printStackTrace();
			} catch (UnsupportedCommOperationException unscoEx) {
				System.err.println(unscoEx.getMessage());
				// piuEx.printStackTrace();
			}
		}
		return false;
	}

	/**
	 * portClosed Wird vom InputOutputProcess aufgerufen.
	 * 
	 * @todo
	 */
	protected void portClosed() {
		if (pnlConnection != null) {
			pnlConnection.setShowState(PnlConnection.STATE_DISCONNECTED);
		}
	}

	/**
	 * Wird vom InputOutputProcess aufgerufen.
	 * 
	 * @param message
	 *            byte[]
	 */
	public void messageArived(Message message) {
		for (Communicatable c : communicatables) {
			sendMessageArived(message, c);
		}
	}

	/**
	 * sendMessageArived Hier wird eine Nachricht an ein Communicatable
	 * geschickt und eventuelle Feher Abgefangan.
	 * 
	 * @param message
	 *            Message
	 * @param c
	 *            Communicatable
	 */
	private void sendMessageArived(Message message, Communicatable c) {
		try {
			c.messageArived(message);
		} catch (Exception ex) {
			System.err.println("Es wurde ein Verarbeitungsfehler abgefangen: "
					+ ex.toString());
			System.err.println("Sonst nichts pasiert.");
			ex.printStackTrace();
		}
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @seeserialCommunications.io.MessageDistributor#addCommunicatable(
	 * serialCommunications.io.Communicatable)
	 */
	public void addCommunicatable(Communicatable c) {
		if (!communicatables.contains(c))
			communicatables.add(c);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @seeserialCommunications.io.MessageDistributor#removeCommunicatable(
	 * serialCommunications.io.Communicatable)
	 */
	public void removeCommunicatable(Communicatable c) {
		communicatables.remove(c);
	}

	private class SenderAdapter implements Sender {
		MessageDecoder decoder;

		public SenderAdapter(MessageDecoder decoder) {
			this.decoder = decoder;
		}

		@Override
		public boolean sendMessage(Message message) {
			return Connection.this.sendMessage(message, decoder);
		}
	}
}
