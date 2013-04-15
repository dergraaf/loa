package de.rwth_aachen.roboterclub.can232.messages;

import de.rwth_aachen.roboterclub.serial.io.messages.Message;
import java.io.*;

public class CanLongIDMessageFactory extends CanMessageFactory{
	public CanLongIDMessageFactory() {
	}

	public CanLongIDMessageFactory(File f) {
		super(f);
	}

	/**
	 * writeMessage
	 * schreibt Tiiiiiiiisnnnn..
	 *
	 * @param message Message
	 * @throws IOException
	 * @todo Fragment long messages!!
	 */
	public void writeMessage(Message message) throws IOException {
		if(message instanceof DefaultCanMessage){
			outputStream.write('T');
			DefaultCanMessage def = (DefaultCanMessage) message;
			for (int i = 1; i < 8; i++) // mit nullen auffüllen bis zur 8-stelligen hex zahl
				if (def.getId() < Math.round(Math.pow(16, i)))
					outputStream.write('0');
			outputStream.write(Integer.toHexString(def.getId()).getBytes());
			outputStream.write(Integer.toHexString(def.getLength()).getBytes());
			for (int i = 0; i < def.getLength(); i++) {
				if (def.getByte(i) < 16)
					outputStream.write('0');
				outputStream.write(Integer.toHexString(def.getByte(i)).getBytes());
			}
			outputStream.write('\r');
		}
		else
			super.writeMessage(message);
	}

}
