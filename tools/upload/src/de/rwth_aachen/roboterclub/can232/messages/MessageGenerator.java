package de.rwth_aachen.roboterclub.can232.messages;

public interface MessageGenerator {
	DefaultCanMessage generateMessage(int iD, byte[] message);
}
