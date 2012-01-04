
#ifndef LED_HPP
#define LED_HPP

struct ColorRgb
{
	uint8_t red;
	uint8_t green;
	uint8_t blue;
};

struct ColorHsv
{
	uint8_t hue;
	uint8_t saturation;
	uint8_t value;
};

/**
 * Control of the two RGB and the blue LED
 * 
 */
class Led
{
public:
	static void
	initialize();
	
	enum RgbLed
	{
		LED1,
		LED2,
	};
	
	static void
	setRgb(RgbLed led, ColorRgb color);
	
	static void
	setHsv(RgbLed led, ColorHsv color);
	
	static void
	setBlue(uint8_t intensity);
};

#endif // LED_HPP
