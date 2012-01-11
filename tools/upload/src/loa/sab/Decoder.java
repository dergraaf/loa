package loa.sab;

import java.io.IOException;

import de.rwth_aachen.roboterclub.serial.io.MessageDecoder;
import de.rwth_aachen.roboterclub.serial.io.messages.Message;

public class Decoder extends MessageDecoder {

	private static final int FRAME_BOUNDERY_BYTE = 0x7e;
	private static final int CONTROL_ESCAPE_BYTE = 0x7d;
	private static final int CRC_INITIAL_VALUE = 0xffff;

	private Frame receiveMessage;
	private boolean nextEscaped = false;
	private int receiveLength = -1; // a length of -1 forces the decoder to wait
									// for the next framing byte
	private int receiveCrc;
	private byte[] receiveData = new byte[2048 + 4];

	public Decoder() {
	}
	
	@Override
	public Message readMessage() throws IOException {
		while (true) {
			int b = inputStream.read();

			if (b == -1) {
				// End of stream
				return null;
			} else {
				if (decodeStream(b)) {
					return receiveMessage;
				}
			}
		}
	}

	@Override
	public void writeMessage(Message message) throws IOException {
		Frame m = (Frame) message;

		outputStream.write(FRAME_BOUNDERY_BYTE);

		int crc = CRC_INITIAL_VALUE;
		int header = m.address | m.type.getFlags();
		writeByteEscaped(header);
		crc = updateCrc(crc, header);
		writeByteEscaped(m.command);
		crc = updateCrc(crc, m.command);
		
		for (byte b : m.data) {
			writeByteEscaped(b);
			crc = updateCrc(crc, b);
		}
		
		writeByteEscaped((crc) & 0xff);
		writeByteEscaped((crc >> 8) & 0xff);

		outputStream.write(FRAME_BOUNDERY_BYTE);
	}

	private void writeByteEscaped(int data) throws IOException {
		if (data == FRAME_BOUNDERY_BYTE || data == CONTROL_ESCAPE_BYTE) {
			outputStream.write(CONTROL_ESCAPE_BYTE);
			outputStream.write(data ^ 0x20);
		} else {
			outputStream.write(data);
		}
	}

	/**
	 * Decode byte stream
	 * 
	 * @param b
	 *            Next byte to decode
	 * @return true if a correct message was received, false otherwise
	 */
	private boolean decodeStream(int b) {
		//System.out.printf("> %02x\n", b);
		
		if (b == FRAME_BOUNDERY_BYTE) {
			if (nextEscaped == true) {
				System.err.println("\nFraming error");
			}
			else {
				if (receiveLength >= 4) {
					if (receiveCrc == 0) {
						receiveMessage = new Frame();
	
						receiveMessage.address = (receiveData[0] & 0x3f);
						receiveMessage.type = Frame.Type.decode(receiveData[0]);
						receiveMessage.command = receiveData[1];
						
						// copy data
						receiveMessage.data = new byte[receiveLength - 4];
						System.arraycopy(receiveData, 2,
								receiveMessage.data, 0, receiveLength - 4);
						
						receiveLength = 0;
						return true;
					}
					else {
						System.err.printf("\nCRC error (got %02x)\n", receiveCrc);
						System.err.println(dataToString());
					}
				}
			}
			
			nextEscaped = false;
			receiveLength = 0;
			receiveCrc = CRC_INITIAL_VALUE;
			
			return false;
		}
		else if (b == CONTROL_ESCAPE_BYTE) {
			nextEscaped = true;
			return false;
		}
		else {
			if (nextEscaped == true) {
				nextEscaped = false;
				b = b ^ 0x20;
			}

			if (receiveLength >= 0) {
				if (receiveLength >= receiveData.length) {
					System.err.println("Message to long!");
					receiveLength = -1;
				} else {
					receiveCrc = updateCrc(receiveCrc, b);
					receiveData[receiveLength] = (byte) b;
					receiveLength += 1;
				}
			}
			
			return false;
		}
	}

	private String dataToString() {
		String str = new String("[");
		for (int i = 0; i < receiveLength; ++i) {
			str += String.format("%02x ", receiveData[i]);
		}
		str = str.trim();
		str += "]";
		return str;
	}

	private int updateCrc(int crc, int data) {
		crc = (crc ^ (data & 0xff)) & 0xffff;
		for (int i = 0; i < 8; ++i) {
			if ((crc & 0x0001) > 0) {
				crc = (crc >> 1) ^ 0xA001;
			} else {
				crc = (crc >> 1);
			}
		}
		return crc;
	}
}
