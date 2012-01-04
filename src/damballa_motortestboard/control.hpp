
#ifndef CONTROL_HPP
#define CONTROL_HPP

#include <stdint.h>

/**
 * Closed loop control of the Brushless Motors
 * 
 * 2000 Steps per Rotation of the Motor (500 Graycode Steps).
 * 4,8:1 Transmission
 * => 2000*4,8 = 9600 Steps per Rotation of the Transmission Shaft
 * 
 * AD8205
 * v = 50V/V
 * for unidirectional operation
 * -> 0V    = 0,05V
 * -> 100mV = 4,8V
 * 
 * R = 0,033 Ohm
 * U_adc = 0..2,5V
 * I_max = U_adc / v / R = 2,5V / 50 / 0,033Ohm = 1,5A
 */
class Control
{
public:
	enum Motor
	{
		DRIVE_RIGHT = 0,
		DRIVE_LEFT = 1,
		MOTOR3 = 2,
		MOTOR4 = 3
	};
	
	static void
	initialize();
	
	//static void
	//setSpeed(Motor motor, int16_t speed);
	
	static inline int16_t
	getSpeed(Motor motor)
	{
		return steps[motor];
	}
	
	//static int16_t
	//getPosition(Motor motor);
	
private:
	static void
	readEncoders();
	
	static void
	run();
	
	static uint16_t encoderLast[4];
	static uint16_t steps[4];
};

#endif // CONTROL_HPP
