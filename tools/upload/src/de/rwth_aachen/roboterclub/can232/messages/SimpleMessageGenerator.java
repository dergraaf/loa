package de.rwth_aachen.roboterclub.can232.messages;

public class SimpleMessageGenerator implements MessageGenerator {

	@Override
	public DefaultCanMessage generateMessage(int iD, byte[] message) {
		DefaultCanMessage m = new DefaultCanMessage(iD, message);
		// TODO Auto-generated method stub
		return m;
	}

}
