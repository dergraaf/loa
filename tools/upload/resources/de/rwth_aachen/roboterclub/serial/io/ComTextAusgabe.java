package de.rwth_aachen.roboterclub.serial.io;

import de.rwth_aachen.roboterclub.serial.io.messages.*;
import de.rwth_aachen.roboterclub.serial.ui.*;
public class ComTextAusgabe
    implements Communicatable, Sender {
  private PnlTextEingabeAusgabe pnlTextEingabeAusgabe;
  private Sender sender;

  public void setSender(Sender sender) {
    this.sender = sender;
  }

  /**
   * setPnlTextEingabeAusgabe
   *
   * @param pnlTextEingabeAusgabe PnlTextEingabeAusgabe
   */
  public void setPnlTextEingabeAusgabe(PnlTextEingabeAusgabe
                                       pnlTextEingabeAusgabe) {
    this.pnlTextEingabeAusgabe = pnlTextEingabeAusgabe;
  }

  public synchronized void sendeString(String message) {
    sender.sendMessage(new StringMessage(message/*+'\n'*/));
  }

  public ComTextAusgabe() {
  }

  /**
   * messageArived kriegt jede nachricht die ankommt, und muss selber entscheiden
   * was damit zu tun ist.
   *
   * @param message Message
   */
  public synchronized void messageArived(Message message) {
    if(message!=null){
      //    pnlTextEingabeAusgabe.addStringToInputProtokol(((StringMessage)message).getString());
      pnlTextEingabeAusgabe.addStringToInputProtokol(message.toString());
    }

//      pnlTextEingabeAusgabe.addStringToInputProtokol(calculateSth(message));
  }



/*  private String calculateSth(byte[] message) {
    int offset=15;
    int[] b_tmp = new int[7];
    int[] intWerte = new int[(message.length-offset) / 2];
    for (int i = 0; i < intWerte.length; i++) {
      intWerte[i] = CanMessageFactory.getInt((char)message[offset+2*i],(char)message[offset + 2 * i +1]);
    }

//    b_tmp[0] = intWerte[0]/(intWerte[5]/4);
//    b_tmp[1] = intWerte[1]/(intWerte[5]/4);
    b_tmp[2] = intWerte[2];///((intWerte[2]+intWerte[3]+intWerte[4])/60);  // R
    b_tmp[3] = intWerte[3];///((intWerte[2]+intWerte[3]+intWerte[4])/60);  // G
    b_tmp[4] = intWerte[4];///((intWerte[2]+intWerte[3]+intWerte[4])/60);  // B
    b_tmp[5] = intWerte[5];
//    b_tmp[6] = intWerte[6];
    return "" + b_tmp[2]+" "  + b_tmp[3]+" "  + b_tmp[4];
  }*/

  /**
   * sendMessage
   *
   * @param message Message
   * @return boolean
   * @todo Implement this serialCommunications.io.Sender method
   */
  public synchronized boolean sendMessage(Message message) {
    pnlTextEingabeAusgabe.addStringToOutputProtokol(message.toString());
    return sender.sendMessage(message);
  }
}
