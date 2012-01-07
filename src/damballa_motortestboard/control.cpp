
#include "control.hpp"
#include "fpga.hpp"

#include "ui.hpp"	// TODO

uint16_t Control::steps[4] = {};
uint16_t Control::encoderLast[4] = {};

// ----------------------------------------------------------------------------
void
Control::initialize()
{
	
	Fpga::attachHandler(Control::run);
}

void
Control::readEncoders()
{
	uint16_t encoderCurrent[4] = {
		Fpga::getEncoder(Fpga::ENCODER_BLDC1),
		Fpga::getEncoder(Fpga::ENCODER_BLDC2),
		Fpga::getEncoder(Fpga::ENCODER_MOTOR3),
		Fpga::getEncoder(Fpga::ENCODER_MOTOR4),
	};
	
	for (uint32_t i = 0; i < 4; ++i) {
		steps[i] = encoderCurrent[i] - encoderLast[i];
		encoderLast[i] = encoderCurrent[i];
	}
}

// ----------------------------------------------------------------------------
void
Control::run()
{
	readEncoders();
	
	// TODO do something useful
	
	// Encoder -12..11 
	int16_t indexLeft = static_cast<int16_t>(Ui::getEncoder(Ui::ENCODER_6) - 12);
	int16_t indexRight = static_cast<int16_t>(Ui::getEncoder(Ui::ENCODER_7) - 12);
	
	// -12..11 -> -32760..30030
	//int16_t servo1 = indexLeft * 2730;
	//Fpga::setServo(Fpga::SERVO1, servo1);
	
	
	// -12..11 -> 0..1024
	/*int16_t speedLeft = indexLeft * 42 + 512;
	int16_t speedRight = indexRight * 42 + 512;
	
	Fpga::setPwm(Fpga::MOTOR_BLDC1, speedRight);
	Fpga::setPwm(Fpga::MOTOR_BLDC2, speedLeft);*/
}
