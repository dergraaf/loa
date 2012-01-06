
#include <xpcc/architecture.hpp>
#include <xpcc/workflow.hpp>

#include "loa/damballa.hpp"
#include "fpga.hpp"

#include "ui.hpp"

// ----------------------------------------------------------------------------
GPIO__INPUT(EncoderA, C, 6);
GPIO__INPUT(EncoderB, C, 7);
GPIO__INPUT(EncoderIndex, C, 8);

GPIO__INPUT(Btn1, E, 11);
GPIO__INPUT(Btn2, E, 12);
GPIO__INPUT(Btn3, E, 13);
GPIO__INPUT(Btn4, E, 14);

xpcc::ButtonGroup<uint16_t> Ui::button(0);

using namespace xpcc::stm32;

// ----------------------------------------------------------------------------
void
Ui::initialize()
{
	EncoderIndex::setInput(xpcc::stm32::PULLUP);
	EncoderA::setAlternateFunction(xpcc::stm32::AF_TIM3);
	EncoderB::setAlternateFunction(xpcc::stm32::AF_TIM3);
	
	Timer3::enable();
	Timer3::setMode(Timer3::UP_COUNTER, Timer3::SLAVE_ENCODER_3);
	Timer3::setOverflow(24*4 - 1);
	Timer3::setValue(48);
	Timer3::start();
	
	Btn1::setInput(xpcc::stm32::PULLUP);
	Btn2::setInput(xpcc::stm32::PULLUP);
	Btn3::setInput(xpcc::stm32::PULLUP);
	Btn4::setInput(xpcc::stm32::PULLUP);
}

// ----------------------------------------------------------------------------
uint32_t
Ui::getEncoder(Encoder encoder)
{
	if (encoder == ENCODER_6)
	{
		// Read Encoder
		static uint16_t encoderUserLast = 0;
		uint16_t encoderUser = Fpga::getEncoder(Fpga::ENCODER_USER);
		int16_t steps = encoderUser - encoderUserLast;
		encoderUserLast = encoderUser;
		
		// Limit to 0..95
		static uint16_t position = 48;
		steps += position;
		while (steps < 0) {
			steps += 24*4;
		}
		while (steps >= 24*4) {
			steps -= 24*4;
		}
		position = steps;
		
		// round the value to 0..23
		return ((position + 2) % (24*4)) / 4;
	}
	else {
		// round the value to 0..23
		return ((Timer3::getValue() + 2) % (24*4)) / 4;
	}
}

// ----------------------------------------------------------------------------
static xpcc::PeriodicTimer<> timer(10);

void
Ui::update()
{
	if (timer.isExpired())
	{
		uint16_t value = (~Fpga::getButtons()) & 0xf;
		
		value |= loa::Button1::read() ? BUTTON_LOA1 : 0;
		value |= loa::Button2::read() ? BUTTON_LOA2 | BUTTON5 : 0;
		value |= Btn1::read() ? BUTTON1 : 0;
		value |= Btn2::read() ? BUTTON2 : 0;
		value |= Btn3::read() ? BUTTON3 : 0;
		value |= Btn4::read() ? BUTTON4 : 0;
		value |= EncoderIndex::read() ? BUTTON_ENCODER7 : 0;
		
		button.update(value);
	}
}
