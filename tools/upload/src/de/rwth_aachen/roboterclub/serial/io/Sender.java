package de.rwth_aachen.roboterclub.serial.io;

import de.rwth_aachen.roboterclub.serial.io.messages.Message;

public interface Sender {
	public boolean sendMessage(Message message);
}
