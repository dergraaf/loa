package de.rwth_aachen.roboterclub.can232.messages;
import de.rwth_aachen.roboterclub.serial.io.messages.Message;

public class DefaultCanMessage implements Message{
	private byte[] message;
	private int iD;
	// TODO rtr and extended flags

	public DefaultCanMessage(int iD, byte[] content) {
		//    super(content);
		if(content!=null && iD>0){
			this.iD = iD;
			this.message = content;
		}
		else
			generatingMessageFailed();
	}

	/**
	 * Keine Ahnung was diesen Constructor besonders macht.
	 *
	 * @param ibx int
	 * @param ix int
	 * @param message byte[]
	 */
	@SuppressWarnings("unused")
	private DefaultCanMessage(int ibx,int ix,byte[] message) {
		//    super(message);
		int[] spaces = new int[20];
		int i=0, count=0, length;
		while (i<message.length){
			if (message[i] == ' ')
				spaces[count++] = i;
			i++;
		}
		if(count >=3 && spaces[count-1]-spaces[count-2]==2){
			try {
				int faktor=1;
				iD=0;
				for (int c=spaces[count-2]-1;c>spaces[count-3];c--){
					iD+=CanMessageFactory.getByte((char)message[c])*faktor;
					faktor*=16;
				}
				//        irgendwelcheId = Integer.parseInt(new String(message, 0, spaces[1]));
				//        length= Integer.parseInt(new String(message, spaces[1]+1, 1));
				length= CanMessageFactory.getByte((char)message[spaces[1]+1]);
				this.message=new byte[length];
				for (int c=0; c<length && c<message.length;c++){
					this.message[c] = CanMessageFactory.getByte(
							(char) message[spaces[2]+1 + 2 * c],
							(char) message[spaces[2]+1 + 2 * c + 1]);
				}
			}
			catch(Exception e){
				generatingMessageFailed();
			}
		}
		else{
			generatingMessageFailed();
		}

	}

	private void generatingMessageFailed(){
		iD=-1;
		message=null;
	}

	/**
	 * Der alte Constructor mit nur 8-byte Messagelength
	 *
	 * @param message byte[]
	 */
	@SuppressWarnings("unused")
	private void DefaultCanMessage1(byte[] message) {
		char[] first=new char[message.length];
		int messageLength;
		char[] last=new char[message.length];
		int countFirst=0;
		int l=0;
		while(message[l]!=' ' && l<message.length ){
			first[l] = (char) message[l];
			l++;
		}
		messageLength=Integer.parseInt(new String(message,0,l));
		for (int i=l+2;i<message.length; i++)
			last[i]=(char)message[i];
		this.message=new byte[8];

		for (int i=0;i<8;i++){
			this.message[i] = CanMessageFactory.getByte( (char) message[message.length -
			                                                            16 + 2 * i],
			                                                            (char) message[message.length -
			                                                                           16 + 2 * i+1]);
		}
		for (int i=0;i<8;i++)
			System.out.print(this.message[i]+" ");
		System.out.println();
	}


	public int getId(){
		return iD;
	}

	public void setId(int iD){
		this.iD=iD;
	}

	public int getLength(){
		if(message!=null)
			return message.length;
		return 0;
	}

	public int getByte(int index){
		if (message != null)
			if (message[index] >= 0)
				return message[index];
			else
				return 0xff + message[index] + 1;
		return -1;
	}

	public float getFloat(int beginIndex, int byteCount){
		//    java.io.DataInputStream o = new java.io.DataInputStream(null);
		//    Float f;
		return Float.intBitsToFloat( ( (int) getByte(beginIndex)) +
				( (int) getByte(beginIndex + 1)) * 256 +
				( (int) getByte(beginIndex + 2)) * 256 * 256 +
				( (int) getByte(beginIndex + 3)) * 256 * 256 * 256);
		//    o.readFloat();
		//    Objectoutp
		//    return 0;
	}

	public static byte[] getCanFloat(float f){
		int i = Float.floatToIntBits(f);
		return new byte[]{(byte)(i&0xff),(byte)((i&0xff00)>>8),(byte)((i&0xff0000)>>16),(byte)((i&0xff000000)>>24)};
	}

	public static byte[] getCanUint16(int i){
		return new byte[]{(byte)(i&0xff),(byte)((i&0xff00)>>8)};
	}

	public int getUint16(int beginIndex, int byteCount){
		return ((int)getByte(beginIndex)) + ((int)getByte(beginIndex + 1))*256;
	}

	public int getUint8(int beginIndex, int byteCount){
		return getByte(beginIndex);
	}

	public int getInt16(int beginIndex, int byteCount){
		//    return ((int)getByte(beginIndex)) + ((int)getByte(beginIndex + 1))*256;

		int ret = 0;
		for (int i = 0; i < 2; i++){
			int c = ((int)getByte(beginIndex + i,1,false));
			int r = c  << i * 8;
			ret |= r;
		}
		if ((ret & (1<<15)) != 0){
			ret = ret|(~0xFFFF);
		}
		return ret;
	}

	public int getInt32(int beginIndex, int byteCount){
		int ret = 0;
		for (int i = 0; i < 4; i++){
			int c = ((int)getByte(beginIndex + i,1,false));
			int r = c  << i * 8;
			ret |= r;
		}
		return ret;
	}

	public int getByte(int beginIndex, int byteCount, boolean allowNegative){
		int ret=0;
		int shift=0;

		if (message != null && beginIndex>=0 && byteCount>0 && beginIndex + byteCount <= message.length){
			for (int i = beginIndex + byteCount - 1; i >= beginIndex; i--) {
				//        if (message[i] >= 0)
				ret |= (0xFF & message[i])<<shift;
				//        else
				//          ret |= (0xff + message[i] + 1)<<shift;
				shift += 8;
				//        faktor <<= 8;
			}
			if (allowNegative && message[beginIndex] < 0)
				ret = ret |((~0)<<shift);
			return ret;
		}
		else{
			return -1;
		}
	}

	public void setByte(int index, byte bbyte){
		if (index>=0 && index<message.length)
			message[index]=bbyte;
	}

	public void setByte(int beginIndex, int byteCount, int value){
		if (beginIndex>=0 && byteCount>0 && beginIndex + byteCount <= message.length)
			for(int i= beginIndex + byteCount-1; i >= beginIndex ; i--){
				message[i] = (byte) (value & 0xFF);
				value >>= 8;
			}
	}

	public byte[] getBytes(){
		return message;
	}

	public int getNibble(int position){
		if (message!=null){
			if(position%2==0){
				return message[position/2]>>4;
			}
			else{
				return message[position/2]&15;
			}
		}
		return -1;
	}

	/**
	 * Returns a string representation of the object.
	 *
	 * @return a string representation of the object.
	 * @todo Strage construcktion check
	 */
	public String toString() {
		if(iD>=0 && message!=null){
			String content = toString(true);


			String s = Integer.toHexString(iD);
			while (s.length() < 8){
				s = "0" + s;
			}
			return "0x" + s + " " + message.length +
					" " + content;
		}
		return "-noMessage-";
	}

	public String toString(boolean contentOnly){
		if (!contentOnly)
			return toString();
		if(iD>=0 && message!=null){
			StringBuffer buff = new StringBuffer();
			for (int i = 0; i < message.length; i++){
				String str=Integer.toHexString(message[i]);
				if (str.length() > 2) // i think that means negative
					buff.append(str.substring(6));// strage construction, check please
				else if (str.length() == 2)
					buff.append(str);
				else
					buff.append( "0" + str);

				if (i+1 < message.length)
					buff.append(" ");
			}
			return buff.toString();
		}
		return "-noMessage-";
	}
}
