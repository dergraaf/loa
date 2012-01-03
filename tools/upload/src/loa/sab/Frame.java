package loa.sab;

/**
 * SAB (Sensor Actor Bus) Message
 * 
 * @author fabian
 */
public class Frame implements
		de.rwth_aachen.roboterclub.serial.io.messages.Message {

	/**
	 * Type of the Message
	 */
	public enum Type {
		/** Request from the Master */
		REQUEST(0x00),
		INVALID(0x40),
		/** Negative response from the slave */
		NACK(0x80),
		/** Positive response from the slave */
		ACK(0xc0);

		private int flags;

		Type(int flags) {
			this.flags = flags;
		}

		public int getFlags() {
			return this.flags;
		}
		
		static Type decode(int flags) {
			switch (flags & 0xc0) {
			case 0x00:
				return REQUEST;
			case 0x80:
				return NACK;
			case 0xc0:
				return ACK;
			default:
				return INVALID;
			}
		}
		
		@Override
		public String toString() {
			switch (flags & 0xc0) {
			case 0x00:
				return "REQUEST";
			case 0x80:
				return "NACK";
			case 0xc0:
				return "ACK";
			default:
				return "INVALID";
			}
		}
	}

	/**
	 *  Slave address in range 0..63
	 */
	public int address;

	/**
	 * Message type (Request, ACK or NACK)
	 */
	public Type type;
	
	/**
	 * Command Byte
	 */
	public int command;
	public byte[] data;

	private int crc;

	public Frame() {
		this.type = Type.REQUEST;
		this.address = 0;
		this.command = 0;
		this.crc = 0;
	}
	
	public Frame(int address, int command) {
		this.type = Type.REQUEST;
		this.address = address;
		this.command = command;
		this.crc = 0;
	}
	
	public Frame(int address, int command, byte[] data) {
		this.type = Type.REQUEST;
		this.address = address;
		this.command = command;
		this.data = data;
		this.crc = 0;
	}
	
	/**
	 * Copy constructor
	 */
	public Frame(Frame other) {
		this.address = other.address;
		this.type = other.type;
		this.command = other.command;
		this.data = other.data.clone();
		this.crc = other.crc;
	}
	
	public int getLength() {
		return data.length;
	}
	
	public boolean isResponse(Frame other) {
		if (this.address == other.address && 
				(this.type == Type.ACK || this.type == Type.NACK)) {
			return true;
		}
		else {
			return false;
		}
	}
	
	/**
	 * Update CRC value
	 * 
	 * @return	Calculated CRC value (see getCrc())
	 */
	public int calculateCrc() {
		crc = 0;
		updateCrc(data.length);

		int header = address | type.getFlags();
		updateCrc(header);
		updateCrc(command);
		for (byte b : data) {
			updateCrc((int) b);
		}
		return crc;
	}

	public int getCrc() {
		return this.crc;
	}

	private int updateCrc(int data) {
		crc = (crc ^ data) & 0xff;
		for (int i = 0; i < 8; ++i) {
			if ((crc & 0x01) > 0) {
				crc = (crc >> 1) ^ 0x8C;
			} else {
				crc >>= 1;
			}
		}
		return crc;
	}
	
	private String dataToString() {
		String str = new String("[");
		for (byte b : data) {
			str += String.format("%02x ", b);
		}
		str = str.trim();
		str += "]";
		return str;
	}
	
	@Override
	public String toString() {
		return String.format("(%02x > %02x.%s: %s)", address, command, type.toString(), dataToString()); 
	}
}
