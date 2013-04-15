package de.rwth_aachen.roboterclub.serial.io;

import java.io.IOException;

import gnu.io.CommPortIdentifier;
import gnu.io.NoSuchPortException;

public class PortIdentifier {
	private CommPortIdentifier ci;
	
	public PortIdentifier(CommPortIdentifier ci) {
		this.ci = ci;
	}
	
	/**
	 * Create port identifier from a port name.
	 * 
	 * @param portName	Serial port name
	 * @throws IOException 
	 */
	public PortIdentifier(String portName) throws IOException {
		try {
			this.ci = CommPortIdentifier.getPortIdentifier(portName);
		} catch (NoSuchPortException e) {
			throw new IOException(e);
		}
	}
	
	public CommPortIdentifier getCi() {
		return ci;
	}

	public String toString() {
		return ci.getName();
	}
}
