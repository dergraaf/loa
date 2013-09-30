package de.rwth_aachen.roboterclub.serial.io;

public interface MessageDistributor {

	public void addCommunicatable(Communicatable c);

	public void removeCommunicatable(Communicatable c);

}
