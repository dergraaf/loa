package de.rwth_aachen.roboterclub.serial.ui;

import java.util.Enumeration;
import java.awt.*;
import javax.swing.*;
import de.rwth_aachen.roboterclub.serial.io.Connection;
import de.rwth_aachen.roboterclub.serial.io.ConnectionSupervisor;
import de.rwth_aachen.roboterclub.serial.io.PortIdentifier;

import java.awt.event.*;

@SuppressWarnings("serial")
public class PnlConnection extends JPanel implements ConnectionSupervisor {
	private String preferredPort;
	private Connection connection;
	JComboBox jComboBox1 = new JComboBox();
	FlowLayout flowLayout1 = new FlowLayout();
	JButton cmbConnect = new JButton();
	JButton cmbDisconnect = new JButton();
	JButton cmbEnumPorts = new JButton();
	
	public void setConnection(Connection connection) {
		this.connection = connection;
		connection.setPnlConnection(this);
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
		jComboBox1.setMinimumSize(new Dimension(150, 19));
		jComboBox1.setPreferredSize(new Dimension(150, 19));
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
		Object o = jComboBox1.getSelectedItem();
		preferredPort = o.toString();
		connection.connect(o);
	}

	void cmbEnumPorts_actionPerformed(ActionEvent e) {
		if (!connection.isConnected()) {
			setShowState(STATE_DISCONNECTED);
			jComboBox1.removeAllItems();
			Enumeration<PortIdentifier> enu = connection.enumPorts();
			while (enu.hasMoreElements()){
				PortIdentifier p = enu.nextElement();
				jComboBox1.addItem(p);
				if (preferredPort != null && p.toString().equals(preferredPort))
					jComboBox1.setSelectedItem(p);
			}
		}
		else{
			setShowState(STATE_CONNECTED);
		}
	}

	void cmbDisconnect_actionPerformed(ActionEvent e) {
		connection.disconnect();
	}

	@Override
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

	public String getPreferredPort() {
		return preferredPort;
	}
	public void setPreferredPort(String preferredPort) {
		this.preferredPort = preferredPort;
	}
	
	public void populatePortList() {
		cmbEnumPorts.doClick();
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
