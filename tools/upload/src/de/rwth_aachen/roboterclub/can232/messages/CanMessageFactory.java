package de.rwth_aachen.roboterclub.can232.messages;

import de.rwth_aachen.roboterclub.serial.io.MessageDecoder;
import de.rwth_aachen.roboterclub.serial.io.messages.*;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;

public class CanMessageFactory
extends MessageDecoder {

	protected MessageGenerator messageGenerator = null;
	private FileOutputStream f;

	public CanMessageFactory() {

	}

	public CanMessageFactory(File f) {
		System.out.println(f.getAbsolutePath());
		try {
			if(!f.exists())
				f.createNewFile();
			if (f.canWrite()){
				this.f = new FileOutputStream(f, false);
				System.out.println("Write log file");
				System.out.println(f.getAbsoluteFile().getPath());
			}
			else {
				System.out.println("Cannot write file");
			}
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}

	public void setMessageGenerator(MessageGenerator messageGenerator){
		this.messageGenerator = messageGenerator;
	}

	/*
   CanID

   set filter 0 0 0   Alle kommen lassen
   set filter 0 7FF 7c5  Nur 7c5= farbsensoren rohwerte

   0 : 7c5 8
   04 ID
   A6 RotLED Rot filter
   A2 Grün...
   1A Blau...
   EB WeisLed Ohne filter
   EB Weis led mit R
   BE Wies led Grün filter
   BD Weis led Blau filter



	 */

	//  public String getByte

	public static byte getByte(char c16, char c1) {
		return (byte)(16 * getByte(c16) + getByte(c1));
	}

	static public byte getByte(char c) {
		return (byte)Character.getNumericValue(c);
	}

	/**
	 * getMessage Kriegt das was die Readlinemethode rausgibt. Bzw.
	 * extrahiert aus einem bestimmten Format die Id und die Bytes.<br>
	 * Hier: [tiiisnnn...] (0xiii: ID, s: anzahl der Bytes, n: nibbles)<br>
	 * Hier: t5654aabbccdd -> (ID=0x560, byte[]={0xaa,0xbb,0xcc,0xdd}).<br>
	 * Dann macht generateMessage(Id,byte[]) weiter.
	 *
	 * @param line byte[]
	 * @return Message
	 * @todo Implement this serialCommunications.io.MessageEncoder method
	 */
	protected Message getMessage(byte[] line) {
		if(line == null)
			return null;
		//    System.out.println(new String(line));
		//    super(message);
		//    String s = new String(line);
		int length;
		int iD;
		byte[] message;
		try {
			if (line !=null && line.length>4 && line[0] == 't') {
				//* id wird eingelesen, [..iii..], wobei das dritte i immer als 0 zählt (0x234==0x230)
				int faktor = 16;
				iD = 0;
				for (int c = 2; c > 0; c--) {
					iD += getByte( (char) line[c]) * faktor;
					faktor *= 16;
				}
				//        irgendwelcheId = Integer.parseInt(new String(message, 0, spaces[1]));
				//* länge wird eingelesen [..s..]
				//        length= Integer.parseInt(new String(message, spaces[1]+1, 1));
				length = getByte( (char) line[4]);
				//* inhalt wird eingelesen, hier wird entsteht eine exception falls die länge nicht stimmt
				message = new byte[length];
				for (int c = 0; c < length /*&& (5 + 2 * c + 1) < line.length*/; c++) {
					message[c] = getByte((char) line[5 + 2 * c],
							(char) line[5 + 2 * c + 1]);
				}
			}
			else if(line !=null && line.length>9 && line[0] == 'T'){
				//* id wird eingelesen, [..iii..]
				int faktor = 1;
				iD = 0;
				for (int c = 8; c > 0; c--) {
					iD += getByte( (char) line[c]) * faktor;
					faktor *= 16;
				}
				//        irgendwelcheId = Integer.parseInt(new String(message, 0, spaces[1]));
				//* länge wird eingelesen [..s..]
				//        length= Integer.parseInt(new String(message, spaces[1]+1, 1));
				length = getByte( (char) line[9]);
				//* inhalt wird eingelesen, hier wird entsteht eine exception falls die länge nicht stimmt
				message = new byte[length];
				for (int c = 0; c < length /*&& (5 + 2 * c + 1) < line.length*/; c++) {
					message[c] = getByte((char) line[10 + 2 * c],
							(char) line[10 + 2 * c + 1]);
				}
			}
			else
				throw new Exception("Generating message failed");
		}
		catch (Exception e) {
			System.out.println("Generating message failed. " + new String(line) + '\n');
			iD=-1;
			message=null;
			length=0;
		}

		Message m = messageGenerator.generateMessage(iD,message);
		log(m);
		return m;
	}

	/**
	 * getMessage Kriegt das was die Readlinemethode des Readers rausgibt.
	 *
	 * @return Message
	 * @throws IOException
	 * @todo Implement this serialCommunications.io.MessageDecoder method
	 */
	public Message readMessage() throws IOException {
		return getMessage(readLn());
	}

	int actualBufferSize = 0;
	protected byte[] readLn() throws IOException {
		while (true) {
			int b = inputStream.read(); //lesen// falls gewünscht kann irgentwo ein time out gesetzt werden
			//      if (b >= 0) {
			// end of stream, oder timeout(b=-1)   und end of line// evntl. mit frames lösen
			if (b<0){
				return null;
			}
			else if ((byte) b == '\r') {
				try{
					//          for (int i=0;i<actualBufferSize;i++)
					//            System.out.print(Integer.toHexString((int)inBuffer[i])+"#");
					//          if(actualBufferSize > 0)
					//            System.out.println("_*1");
					byte[] bb = truncate(inBuffer, 0, actualBufferSize);
					actualBufferSize = 0;
					log(bb);
					return bb;
				}
				catch(Exception e){
					e.printStackTrace();
					return null;
				}
			}
			else if (actualBufferSize >= inBuffer.length) // buffer erweitern
				extendBuffer();
			inBuffer[actualBufferSize++] = (byte) b; // zeichen einfügen
		}
		//      else { // (b=-1)-> end of stream, or recieve timeout
		//          cleanUp();
		//      }
	}

	/**
	 * writeMessage
	 * schreibt tiiisnnnn..
	 *
	 * @param message Message
	 * @throws IOException
	 * @todo Implement this serialCommunications.io.MessageDecoder method
	 */
	public void writeMessage(Message message) throws IOException {
		if(message instanceof DefaultCanMessage){
			outputStream.write('t');
			DefaultCanMessage def = (DefaultCanMessage) message;
			for (int i = 1; i < 3; i++) // mit nullen auffüllen bis zur 3-stelligen hex zahl
				if (def.getId() < Math.round(Math.pow(16, i)))
					outputStream.write('0');
			outputStream.write(Integer.toHexString(def.getId()).getBytes());
			outputStream.write(Integer.toHexString(def.getLength()).getBytes());
			for (int i = 0; i < def.getLength(); i++) {
				if (def.getByte(i) < 16)
					outputStream.write('0');
				outputStream.write(Integer.toHexString(def.getByte(i)).getBytes());
			}
			outputStream.write('\r');
		}
		else if(message instanceof StringMessage)
			writeLn(((StringMessage)message).getString().getBytes());
	}

	public void writeLn(byte[] b) throws IOException{
		outputStream.write(b);
		outputStream.write('\r');
	}

	private void log(byte[] b){
		if (f != null){
			try {
				f.write(b);
			}
			catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}

	private void log(Message m){
		if (f != null){
			try {
				if (m != null)
					f.write(("--> " + m.toString()+'\n').getBytes());
			}
			catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	public static void main(String[] args) {
		char c1[] = {'0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','A','B','C','D','E','F'};
		for (byte i = 0; i < c1.length; i++){
			System.out.println(getByte(c1[i]) == (i>=16?i-6:i));
		}
	}
}

