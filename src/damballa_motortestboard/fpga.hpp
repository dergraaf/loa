
#ifndef FPGA_HPP
#define FPGA_HPP

#include <stdint.h>
#include <xpcc/architecture/driver/atomic.hpp>

/**
 * Interface to the FPGA (XC3S400).
 * 
 * Uses Timer 6 to generate periodic interrupts. Within this interrupts first
 * values are read from the FPGA, than the control handler is called and
 * afterwards new control values are written to the FPGA.
 * 
 * TODO:
 * An additional array provides access to optional values (e.g. Servo values or
 * current limites). This is array is only transfered on request.
 * 
 * \author	Fabian Greif, cjt
 */
class Fpga
{
public:
	typedef void (*Handler)(void);
	
public:
	static void
	initialize();
	
	/**
	 * Enable/Disable communication with the FPGA.
	 * 
	 * Communication is enabled by default.
	 */
	static void
	enable(bool enable = true);

	static void
	attachHandler(Handler handler);
	
public:
	enum Servo
	{
		SERVO1 = 8,
		SERVO2 = 9,
		SERVO3 = 10,
	};

	enum Adc
	{
		ADC_0 = 8,
		ADC_1 = 9,
		ADC_2 = 10,
		ADC_3 = 11,
		ADC_4 = 12,
		ADC_5 = 13,
		ADC_6 = 14,
		ADC_7 = 15,
	};

	
	enum Encoder
	{
		ENCODER_BLDC1 = 1,		// Steps per Time 
		ENCODER_TIME_BLDC1 = 2, // Time per Step
		ENCODER_BLDC2 = 3,
		ENCODER_TIME_BLDC2 = 4,
		ENCODER_MOTOR3 = 5,
		ENCODER_MOTOR4 = 6,
		ENCODER_USER = 7,
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
		xpcc::atomic::Lock lock;
		
		// convert to signed
		toFpgaBuffer[servo].value = 32768 + value;
	}
	
	/**
	 * -1023..1023
	 */
	static inline void
	setPwm(Motor motor, int16_t pwm)
	{
		uint16_t value;
		if (pwm > 0) {
			value = pwm;
		}
		else {
			value = -pwm | 0x4000;
		}
		
		{
			xpcc::atomic::Lock lock;
			toFpgaBuffer[motor].value = value;
		}
	}
	
	static inline uint16_t
	getAdc(Adc ch) {
		xpcc::atomic::Lock lock;
		return fromFpgaBuffer[ch];
	}

	static inline void
	setRgbLed(uint16_t r, uint16_t g, uint16_t b)
	{
		xpcc::atomic::Lock lock;
		
		toFpgaBuffer[1].value = r;
		toFpgaBuffer[2].value = g;
		toFpgaBuffer[3].value = b;
	}
	
	static inline uint16_t
	getEncoder(Encoder encoder)
	{
		xpcc::atomic::Lock lock;
		return fromFpgaBuffer[encoder];
	}
	
	static inline uint16_t
	getButtons()
	{
		xpcc::atomic::Lock lock;
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
