package de.rwth_aachen.roboterclub.serial.io;

import de.rwth_aachen.roboterclub.serial.io.messages.*;

public interface Communicatable {

	/**
	 * messageArived kriegt jede nachricht die ankommt, und muss selber
	 * entscheiden was damit zu tun ist.
	 * 
	 * @param message
	 *            Message
	 */
	public void messageArived(Message message);
	// public int[] getMessageTypes();// vieleicht auch ohne
}
