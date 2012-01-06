package loa.sab;

import java.io.IOException;

import de.rwth_aachen.roboterclub.serial.io.MessageDecoder;
import de.rwth_aachen.roboterclub.serial.io.messages.Message;

public class Decoder extends MessageDecoder {

	private static final int FRAME_BOUNDERY_BYTE = 0x7e;
	private static final int CONTROL_ESCAPE_BYTE = 0x7d;

	private enum State {
		STATE_SYNC, STATE_LENGTH, STATE_HEADER, STATE_COMMAND, STATE_DATA, STATE_CRC;
	}

	private State state;
	private boolean nextEscaped = false;
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

		outputStream.write(FRAME_BOUNDERY_BYTE);
		writeByteEscaped(m.getLength());

		int header = m.address | m.type.getFlags();
		writeByteEscaped(header);
		writeByteEscaped(m.command);

		for (byte b : m.data) {
			writeByteEscaped(b);
		}

		m.calculateCrc();
		writeByteEscaped(m.getCrc());
		outputStream.write(FRAME_BOUNDERY_BYTE);
	}
	
	private void writeByteEscaped(int data) throws IOException {
		if (data == FRAME_BOUNDERY_BYTE || data == CONTROL_ESCAPE_BYTE) {
			outputStream.write(CONTROL_ESCAPE_BYTE);
			outputStream.write(data ^ 0x20);
		}
		else {
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
		//System.out.println(state);
		
		if (b == FRAME_BOUNDERY_BYTE) {
			if ((state != State.STATE_SYNC && state != State.STATE_LENGTH) ||
					(nextEscaped == true))
			{
				System.err.println("Framing error");
			}
			nextEscaped = false;
			state = State.STATE_LENGTH;
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
			
			switch (state) {
			case STATE_SYNC:
				System.err.println("Framing error");
				break;
				
			case STATE_LENGTH:
				receiveMessage = new Frame();
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
		}

		return false;
	}
}
