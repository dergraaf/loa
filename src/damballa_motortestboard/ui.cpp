
#include <xpcc/architecture.hpp>

#include "fpga.hpp"
#include "ui.hpp"

GPIO__INPUT(EncoderA, C, 6);
GPIO__INPUT(EncoderB, C, 7);
GPIO__INPUT(EncoderIndex, C, 8);

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
