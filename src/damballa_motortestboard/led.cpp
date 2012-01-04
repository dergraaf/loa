
#include <xpcc/architecture.hpp>

#include "led.hpp"
#include "fpga.hpp"

using namespace xpcc::stm32;

// ----------------------------------------------------------------------------
static void
convertHsvToRgb(const ColorHsv& hsv, ColorRgb& rgb)
{
	uint16_t vs = hsv.value * hsv.saturation;
	uint16_t h6 = 6 * hsv.hue;
	
	uint8_t p = ((hsv.value << 8) - vs) >> 8;
	uint8_t i = h6 >> 8;
	uint16_t f = ((i | 1) << 8) - h6;
	if (i & 1) {
		f = -f;
	}
	
	uint8_t u = (((uint32_t) hsv.value << 16) - (uint32_t) vs * f) >> 16;
	uint8_t r = hsv.value;
	uint8_t g = hsv.value;
	uint8_t b = hsv.value;
	switch(i) {
		case 0: g = u; b = p; break;
		case 1: r = u; b = p; break;
		case 2: r = p; b = u; break;
		case 3: r = p; g = u; break;
		case 4: r = u; g = p; break;
		case 5: g = p; b = u; break;
	}
	
	rgb.red = r;
	rgb.green = g;
	rgb.blue = b;
}

// ----------------------------------------------------------------------------
GPIO__OUTPUT(LedRed, A, 0);			// TIM2_CH1
GPIO__OUTPUT(LedBlue, A, 1);		// TIM2_CH2
GPIO__OUTPUT(LedGreen, A, 2);		// TIM2_CH3

GPIO__OUTPUT(LedBacklight, A, 3);	// TIM2_CH4

// ----------------------------------------------------------------------------
void
Led::initialize()
{
	Timer2::enable();
	
	Timer2::setMode(Timer2::CENTER_ALIGNED_3);
	Timer2::setPrescaler(2);
	Timer2::setOverflow(65535);
	
	Timer2::configureOutputChannel(1, Timer2::OUTPUT_PWM, 0);
	Timer2::configureOutputChannel(2, Timer2::OUTPUT_PWM, 0);
	Timer2::configureOutputChannel(3, Timer2::OUTPUT_PWM, 0);
	Timer2::configureOutputChannel(4, Timer2::OUTPUT_PWM, 0);
	
	Timer2::applyAndReset();
	Timer2::start();
	
	LedRed::setAlternateFunction(AF_TIM2, PUSH_PULL);
	LedBlue::setAlternateFunction(AF_TIM2, PUSH_PULL);
	LedGreen::setAlternateFunction(AF_TIM2, PUSH_PULL);
	LedBacklight::setAlternateFunction(AF_TIM2, PUSH_PULL);
}

// ----------------------------------------------------------------------------
void
Led::setRgb(RgbLed led, ColorRgb color)
{
	if (led == LED1)
	{
		Timer2::setCompareValue(1, color.red * color.red);
		Timer2::setCompareValue(2, color.blue * color.blue);
		Timer2::setCompareValue(3, color.green * color.green);
	}
	else
	{
		Fpga::setRgbLed(
				color.red * color.red,
				color.green * color.green,
				color.blue * color.blue);
	}
}

void
Led::setHsv(RgbLed led, ColorHsv color)
{
	ColorRgb rgb;
	convertHsvToRgb(color, rgb);
	setRgb(led, rgb);
}

// ----------------------------------------------------------------------------
void
Led::setBlue(uint8_t intensity)
{
	Timer2::setCompareValue(4, intensity * intensity);
}
