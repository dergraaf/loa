package de.rwth_aachen.roboterclub.serial.ui;

import javax.swing.*;
import java.awt.*;
import de.rwth_aachen.roboterclub.serial.io.ComTextAusgabe;
import java.awt.event.*;
import javax.swing.border.*;

/**
 * PnlTextEingabeAusgabe 
 * Ist soeine art HTerm Gui.
 * Hat das feature, dass es gleiche Strings in 
 * eins Zusammen fasst und einen Conuter dahinter anzeigt.
 * 
 * @author Georgi
 *
 */
@SuppressWarnings("serial")
public class PnlTextEingabeAusgabe extends JPanel {
  private ComTextAusgabe comTextAusgabe=null;
  private boolean sumUp = true;
  private int countInSumUps[] = new int[4];
  private int countOutSumUps[] = new int[4];

  BorderLayout borderLayout1 = new BorderLayout();
  JSplitPane jSplitPane1 = new JSplitPane();
  JTextArea txtAreaInputProtokol = new JTextArea();
  JTextArea txtAreaOutputProtokol = new JTextArea();
  JScrollPane jScrollPane1 = new JScrollPane();
  JScrollPane jScrollPane2 = new JScrollPane();
  JPanel jPanel1 = new JPanel();
  JTextField txtMessage = new JTextField();
  JButton cmbWrite = new JButton();
  JButton cmbFilter = new JButton();
  Box box2;
  BorderLayout borderLayout2 = new BorderLayout();
  Border border1;

  public void setComTextAusgabe(ComTextAusgabe comTextAusgabe) {
    this.comTextAusgabe = comTextAusgabe;
  }

  public PnlTextEingabeAusgabe() {
    try {
      jbInit();
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }



  void jbInit() throws Exception {
    box2 = Box.createHorizontalBox();
    border1 = BorderFactory.createEtchedBorder(Color.white,new Color(165, 163, 151));
    this.setLayout(borderLayout1);
    jSplitPane1.setOrientation(JSplitPane.VERTICAL_SPLIT);
    jSplitPane1.setResizeWeight(0.2);
    txtAreaInputProtokol.setFont(new java.awt.Font("Courier New", 0, 12));
    txtAreaOutputProtokol.setFont(new java.awt.Font("Courier New", 0, 12));
    txtMessage.setPreferredSize(new Dimension(120, 20));
    txtMessage.setEditable(true);
    txtMessage.addActionListener(new PnlTextEingabeAusgabe_cmbWrite_actionAdapter(this));
    cmbWrite.setText("Write");
    cmbWrite.addActionListener(new PnlTextEingabeAusgabe_cmbWrite_actionAdapter(this));
    cmbFilter.setText("Connect");
    cmbFilter.addActionListener(new PnlTextEingabeAusgabe_cmbFilter_actionAdapter(this));
    jPanel1.setPreferredSize(new Dimension(300, 33));
    jPanel1.setLayout(borderLayout2);
    this.setBorder(border1);
    this.add(jSplitPane1, BorderLayout.CENTER);
    jSplitPane1.add(jScrollPane1, JSplitPane.BOTTOM);
    jSplitPane1.add(jPanel1, JSplitPane.TOP);
    jScrollPane1.getViewport().add(txtAreaInputProtokol, null);
    box2.add(txtMessage, null);
    box2.add(cmbWrite, null);
    box2.add(cmbFilter, null);
    jPanel1.add(jScrollPane2, BorderLayout.CENTER);
    jScrollPane2.getViewport().add(txtAreaOutputProtokol, null);
    jPanel1.add(box2, BorderLayout.NORTH);
  }

  /**
   * addStringToInputProtokol
   *
   * @param string Spring
   * @todo Add message to Protokol
   * @todo Nein besser das protokol in der ComTextAusgabe Verwalten
   */
  public void addStringToInputProtokol(String string){
    addString(txtAreaInputProtokol, string, sumUp, countInSumUps, 4);

  //    txtAreaInputProtokol.setText(append(string+"\n");
/*    try{
      txtAreaInputProtokol.setText(string.trim() + "\n" +
                                   txtAreaInputProtokol.getText(0, 700));
    }
    catch(javax.swing.text.BadLocationException e){
      txtAreaInputProtokol.setText(string.trim() + "\n" +
                                   txtAreaInputProtokol.getText());
    }*/
    txtAreaInputProtokol.setCaretPosition(0);
  }

  public void addStringToOutputProtokol(String string){
    addString(txtAreaOutputProtokol, string, sumUp, countOutSumUps, 4);
    txtAreaOutputProtokol.setCaretPosition(0);
  }

  private synchronized void addString(JTextArea txtArea, String string, boolean sumUp, int actualCount[], int maxsums){
    try {
      String newString = string.trim();

      if (sumUp){
        String pred[] = new String[Math.min(txtArea.getLineCount(), maxsums)];
        for (int i = 0; i < pred.length; i++)
          pred[i] = txtArea.getText(txtArea.getLineStartOffset(i),
                                    Math.min(newString.length(),
                                             txtArea.getLineEndOffset(i) -
                                             txtArea.getLineStartOffset(i)));
        for (int i = 0; i < pred.length; i++) {
          if (newString.equals(pred[i])) {
            // write the number of reppititions
            txtArea.replaceRange(newString + "\t[" + ++actualCount[i] + "]\n",
                                 txtArea.getLineStartOffset(i),
                                 txtArea.getLineEndOffset(i));
            return;
          }
        }
        txtArea.setText(newString + "\n" +
                        txtArea.getText(0, 700));

        for (int i = actualCount.length - 1; i > 0; i--) {
          actualCount[i] = actualCount[i - 1];
        }
        actualCount[0] = 0;
      }
      else {
        // dont write the number of reppititions
        txtArea.setText(newString + "\n" +
                        txtArea.getText(0, 700));
      }
    }
    catch (javax.swing.text.BadLocationException e) {
      txtArea.setText(string.trim() + "\n" +
                      txtArea.getText());

      for (int i = actualCount.length - 1; i > 0; i--) {
        actualCount[i] = actualCount[i - 1];
      }
      actualCount[0] = 0;
    }
  }

  void cmbWrite_actionPerformed(ActionEvent e) {
    if(comTextAusgabe!=null){
      addStringToOutputProtokol(txtMessage.getText());
      comTextAusgabe.sendeString(txtMessage.getText());
    }
    txtMessage.selectAll();
  }

  void cmbFilter_actionPerformed(ActionEvent e) {
//    comTextAusgabe.

    // TODO eigentlich ist das die falsche Stelle das einzubauen,
    // aber es war so schön einfach ;-)
    comTextAusgabe.sendeString("S4");
    comTextAusgabe.sendeString("S4");
    comTextAusgabe.sendeString("O");
    addStringToOutputProtokol("connect");
  }
}

class PnlTextEingabeAusgabe_cmbWrite_actionAdapter implements java.awt.event.ActionListener {
  PnlTextEingabeAusgabe adaptee;

  PnlTextEingabeAusgabe_cmbWrite_actionAdapter(PnlTextEingabeAusgabe adaptee) {
    this.adaptee = adaptee;
  }
  public void actionPerformed(ActionEvent e) {
    adaptee.cmbWrite_actionPerformed(e);
  }
}

class PnlTextEingabeAusgabe_cmbFilter_actionAdapter implements java.awt.event.ActionListener {
  PnlTextEingabeAusgabe adaptee;

  PnlTextEingabeAusgabe_cmbFilter_actionAdapter(PnlTextEingabeAusgabe adaptee) {
    this.adaptee = adaptee;
  }
  public void actionPerformed(ActionEvent e) {
    adaptee.cmbFilter_actionPerformed(e);
  }
}
