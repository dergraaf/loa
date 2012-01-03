package de.rwth_aachen.roboterclub.serial.io.messages;

public class StringMessage implements Message {
	String s;

	public StringMessage(String s) {
		// super(s.getBytes());
		this.s = s;
	}

	/**
	 * getBufferToSendOut
	 * 
	 * @return byte[]
	 * @todo Implement this serialCommunications.io.messages.Message method
	 */
	/*
	 * public byte[] getBufferToSendOut() { return s.getBytes(); }
	 */

	public String getString() {
		return s;
	}

	public String toString() {
		return s;
	}

}
