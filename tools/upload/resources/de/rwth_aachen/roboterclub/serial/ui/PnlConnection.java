package de.rwth_aachen.roboterclub.serial.ui;

import java.util.Enumeration;
import java.awt.*;
import javax.swing.*;
import de.rwth_aachen.roboterclub.serial.io.Connection;
import java.awt.event.*;

@SuppressWarnings("serial")
public class PnlConnection extends JPanel {
  public static final int STATE_CONNECTED=0;
  public static final int STATE_DISCONNECTED=1;
  private Connection connection;
  JComboBox jComboBox1 = new JComboBox();
  FlowLayout flowLayout1 = new FlowLayout();
  JButton cmbConnect = new JButton();
  JButton cmbDisconnect = new JButton();
  JButton cmbEnumPorts = new JButton();
  public void setConnection(Connection connection) {
    this.connection = connection;
  }

  public PnlConnection() {
    try {
      jbInit();
    }
    catch(Exception ex) {
      ex.printStackTrace();
    }
  }

  void jbInit() throws Exception {
    this.setLayout(flowLayout1);
    jComboBox1.setMinimumSize(new Dimension(100, 19));
    jComboBox1.setPreferredSize(new Dimension(100, 19));
    cmbConnect.setText("Connect");
    cmbConnect.addActionListener(new PnlConnection_cmbConnect_actionAdapter(this));
    cmbDisconnect.setText("Disconnect");
    cmbDisconnect.addActionListener(new PnlConnection_cmbDisconnect_actionAdapter(this));
    cmbEnumPorts.setText("EnumPorts");
    cmbEnumPorts.addActionListener(new PnlConnection_cmbEnumPorts_actionAdapter(this));
    this.add(cmbEnumPorts, null);
    this.add(jComboBox1, null);
    this.add(cmbConnect, null);
    this.add(cmbDisconnect, null);
  }

  public void closeAll() {
    connection.disconnect();
  }
  void cmbConnect_actionPerformed(ActionEvent e) {
    if(connection.isConnected())
      connection.disconnect();
    if(connection.connect(jComboBox1.getSelectedItem()))
      setShowState(STATE_CONNECTED);
  }

  @SuppressWarnings({ "rawtypes" })
	void cmbEnumPorts_actionPerformed(ActionEvent e) {
    if (!connection.isConnected()) {
      setShowState(STATE_DISCONNECTED);
      jComboBox1.removeAllItems();
      Enumeration enu = connection.enumPorts();
      while (enu.hasMoreElements())
        jComboBox1.addItem(enu.nextElement());
    }
    else{
      setShowState(STATE_CONNECTED);
    }
  }

  void cmbDisconnect_actionPerformed(ActionEvent e) {
    connection.disconnect();
  }

  public void setShowState(int state){
    cmbConnect.setEnabled(state!=STATE_CONNECTED);
    cmbDisconnect.setEnabled(state==STATE_CONNECTED);
    jComboBox1.setEnabled(state!=STATE_CONNECTED);
/*    switch(state){
      case STATE_CONNECTED:
        cmbConnect.setEnabled(false);
        cmbDisconnect.setEnabled(true);
        jComboBox1.setEnabled(false);
        break;
      case STATE_DISCONNECTED:
        cmbConnect.setEnabled(true);
        cmbDisconnect.setEnabled(false);
        jComboBox1.setEnabled(true);
        break;
    }*/
  }
}

class PnlConnection_cmbConnect_actionAdapter implements java.awt.event.ActionListener {
  PnlConnection adaptee;

  PnlConnection_cmbConnect_actionAdapter(PnlConnection adaptee) {
    this.adaptee = adaptee;
  }
  public void actionPerformed(ActionEvent e) {
    adaptee.cmbConnect_actionPerformed(e);
  }
}

class PnlConnection_cmbEnumPorts_actionAdapter implements java.awt.event.ActionListener {
  PnlConnection adaptee;

  PnlConnection_cmbEnumPorts_actionAdapter(PnlConnection adaptee) {
    this.adaptee = adaptee;
  }
  public void actionPerformed(ActionEvent e) {
    adaptee.cmbEnumPorts_actionPerformed(e);
  }
}

class PnlConnection_cmbDisconnect_actionAdapter implements java.awt.event.ActionListener {
  PnlConnection adaptee;

  PnlConnection_cmbDisconnect_actionAdapter(PnlConnection adaptee) {
    this.adaptee = adaptee;
  }
  public void actionPerformed(ActionEvent e) {
    adaptee.cmbDisconnect_actionPerformed(e);
  }
}
