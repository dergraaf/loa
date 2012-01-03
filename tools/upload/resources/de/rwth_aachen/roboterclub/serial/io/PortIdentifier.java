package de.rwth_aachen.roboterclub.serial.io;

import java.io.IOException;
import java.util.Enumeration;

import gnu.io.CommPortIdentifier;

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
	@SuppressWarnings("unchecked")
	public PortIdentifier(String portName) throws IOException {
		// TODO CommPortIdentifier.getPortIdentifier(portName);
		Enumeration<CommPortIdentifier> enumComm = CommPortIdentifier.getPortIdentifiers();
		while(enumComm.hasMoreElements()) {
			CommPortIdentifier identifier = enumComm.nextElement();
			if (portName.contentEquals(identifier.getName())) {
				this.ci = identifier;
				return;
			}
		}
		
		throw new IOException("Port '" + portName + "' does not exist");
	}
	
	public CommPortIdentifier getCi() {
		return ci;
	}

	public String toString() {
		return ci.getName();
	}
}
