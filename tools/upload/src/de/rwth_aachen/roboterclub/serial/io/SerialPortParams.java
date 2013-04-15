package de.rwth_aachen.roboterclub.serial.io;

import gnu.io.SerialPort;

public class SerialPortParams {
	public final int baudRate;
	public final int stopBits = SerialPort.STOPBITS_1;
	public final int parity = SerialPort.PARITY_NONE;
	public final int dataBits = SerialPort.DATABITS_8;
	
	// problem bei den SerialPort.DATABITS_8 und anderen in SerialPort definierten
	// parametern ist, dass wenn man diese benutzen soll, dann wird man als benutzer
	// SerialPort importieren müssen, das soll aber vermieden werden.
	// wenn es benötigt wird diese zu setzen sollten hier entsprechende enums
	// angelegt werden.
	public SerialPortParams(int baudRate) {
		this.baudRate = baudRate;
	}
}

