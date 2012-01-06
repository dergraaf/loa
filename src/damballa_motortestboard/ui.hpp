
#ifndef UI_HPP
#define UI_HPP

#include <xpcc/driver/ui/button_group.hpp>

class Ui
{
public:
	enum Encoder
	{
		ENCODER_6,
		ENCODER_7,
	};
	
	enum Button
	{
		// Buttons on the Loa board
		BUTTON_LOA1 = 0x0010,
		BUTTON_LOA2 = 0x0020,
		BUTTON_LOA3 = 0x0001,
		BUTTON_LOA4 = 0x0002,
		
		// Buttons of the Motorcontrol board
		BUTTON1 = 0x0040,
		BUTTON2 = 0x0080,
		BUTTON3 = 0x0100,
		BUTTON4 = 0x0200,
		BUTTON5 = 0x0400,	// connected parallel to BUTTON_LOA2
		
		// Rotary Encoder buttons
		BUTTON_ENCODER6 = 0x0004,
		BUTTON_ENCODER7 = 0x0800,
	};
	
	static void
	initialize();
	
	static uint32_t
	getEncoder(Encoder encoder);
	
	static xpcc::ButtonGroup<uint16_t> button;
	
	static void
	update();
};

#endif // UI_HPP
