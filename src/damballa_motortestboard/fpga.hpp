
#ifndef FPGA_HPP
#define FPGA_HPP

#include <stdint.h>

/**
 * Interface to the FPGA (XC3S400).
 * 
 * Uses Timer 6 to generate periodic interrupts. Within this interrupts first
 * values are read from the FPGA, than the control handler is called and
 * afterwards new control values are written to the FPGA.
 * 
 * \author	Fabian Greif
 */
class Fpga
{
public:
	typedef void (*Handler)(void);
	
public:
	static void
	initialize();
	
	static void
	attachHandler(Handler handler);
	
	// TODO
	static void
	update();
	
public:
	enum Servo
	{
		SERVO1 = 8,
		SERVO2 = 9,
		SERVO3 = 10,
	};
	
	enum Encoder
	{
		ENCODER_BLDC1 = 1, 
		ENCODER_BLDC2 = 2,
		ENCODER_MOTOR3 = 3,
		ENCODER_MOTOR4 = 4,
		ENCODER_USER = 5,
	};
	
	enum Motor
	{
		MOTOR_BLDC1 = 4,
		MOTOR_BLDC2 = 5,
		MOTOR3 = 6,
		MOTOR4 = 7,
	};
	
	static inline void
	setServo(Servo servo, int16_t value)
	{
		// convert to signed
		toFpgaBuffer[servo].value = 32768 + value;
	}
	
	static inline void
	setPwm(Motor motor, uint16_t pwm)
	{
		toFpgaBuffer[motor].value = pwm;
	}
	
	static inline void
	setRgbLed(uint16_t r, uint16_t g, uint16_t b)
	{
		toFpgaBuffer[1].value = r;
		toFpgaBuffer[2].value = g;
		toFpgaBuffer[3].value = b;
	}
	
	static inline uint16_t
	getEncoder(Encoder encoder)
	{
		return fromFpgaBuffer[encoder];
	}
	
	static inline uint16_t
	getButtons()
	{
		return fromFpgaBuffer[0];
	}
	
public:
	struct SpiWriteFormat
	{
		const uint16_t address;
		uint16_t value;
	};
	
	// These values should only be used by the Interrupt!
	static const uint16_t fromFpgaAddress[];
	static uint16_t fromFpgaBuffer[];
	static SpiWriteFormat toFpgaBuffer[];
};

#endif // FPGA_HPP
