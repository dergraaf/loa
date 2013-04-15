package de.rwth_aachen.roboterclub.serial.io;

public interface ConnectionSupervisor {
	public static final int STATE_CONNECTED = 0;
	public static final int STATE_DISCONNECTED = 1;
	
	public void setShowState(int state);
}
