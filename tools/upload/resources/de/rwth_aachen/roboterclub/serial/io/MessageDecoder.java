package de.rwth_aachen.roboterclub.serial.io;

import de.rwth_aachen.roboterclub.serial.io.messages.Message;
import java.io.*;

public abstract class MessageDecoder {
	protected InputStream inputStream;
	protected OutputStream outputStream;
	protected byte[] inBuffer = new byte[20];

	/**
	 * readMessage Kriegt das was die Readlinemethode des Readers rausgibt.
	 * Generiert eine Nachricht und gibt sie zurück. Kann zb auch Null
	 * zurückgeben falls nachricht nicht erkannt, aber auch eine Fehler
	 * nachricht. Man kann damit so frei wie mans braucht umgehen. Zb Mehrere
	 * zeilen sammeln und aus diesen eine Nachricht zusammenbasteln.
	 * 
	 * @return Message
	 * @throws IOException
	 */
	abstract public Message readMessage() throws IOException;

	abstract public void writeMessage(Message message) throws IOException;

	public void setOutputStream(OutputStream outputStream) {
		this.outputStream = outputStream;
	}

	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}

	public void closeInput() throws IOException {
		inputStream.close();
	}

	public void closeOutput() throws IOException {
		outputStream.close();
	}

	protected void extendBuffer() {
		byte[] tmp = new byte[inBuffer.length * 2];
		for (int i = 0; i < inBuffer.length; i++)
			tmp[i] = inBuffer[i];
		inBuffer = tmp;
	}

	protected byte[] truncate(byte[] b, int offset, int length) {
		if (length == 0)
			return null;
		byte[] result = new byte[length];
		for (int i = 0; i < length; i++)
			result[i] = b[offset + i];
		return result;
	}

}
