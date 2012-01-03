package loa.sab;

import java.io.IOException;

import de.rwth_aachen.roboterclub.serial.io.MessageDecoder;
import de.rwth_aachen.roboterclub.serial.io.messages.Message;

public class Decoder extends MessageDecoder {

	private static final int SYNC = 0x54;

	private enum State {
		STATE_SYNC, STATE_LENGTH, STATE_HEADER, STATE_COMMAND, STATE_DATA, STATE_CRC;
	}

	private State state;
	private Frame receiveMessage;
	private int receiveIndex;

	public Decoder() {
		state = State.STATE_SYNC;
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

		outputStream.write(SYNC);
		outputStream.write(m.getLength());

		int header = m.address | m.type.getFlags();
		outputStream.write(header);
		outputStream.write(m.command);

		for (byte b : m.data) {
			outputStream.write(b);
		}

		m.calculateCrc();
		outputStream.write(m.getCrc());
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
		switch (state) {
		case STATE_SYNC:
			if (b == SYNC) {
				state = State.STATE_LENGTH;
				receiveMessage = new Frame();
			}
			break;

		case STATE_LENGTH:
			receiveIndex = 0;
			receiveMessage.data = new byte[b];
			state = State.STATE_HEADER;
			break;

		case STATE_HEADER:
			receiveMessage.address = (b & 0x3f);
			receiveMessage.type = Frame.Type.decode(b);
			state = State.STATE_COMMAND;
			break;

		case STATE_COMMAND:
			receiveMessage.command = b;
			if (receiveMessage.data.length > 0) {
				state = State.STATE_DATA;
			}
			else {
				state = State.STATE_CRC;
			}
			break;

		case STATE_DATA:
			receiveMessage.data[receiveIndex] = (byte) b;
			receiveIndex++;
			if (receiveIndex == receiveMessage.data.length) {
				state = State.STATE_CRC;
			}
			break;

		case STATE_CRC:
			state = State.STATE_SYNC;
			int messageCrc = receiveMessage.calculateCrc();
			if (b == messageCrc) {
				return true;
			}
			else {
				System.err.printf("CRC error: expected %02x, got %02x\n",
						messageCrc, b);
			}
			break;
		}

		return false;
	}
}
