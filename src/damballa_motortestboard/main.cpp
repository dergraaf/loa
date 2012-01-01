
#include <xpcc/architecture.hpp>
#include <xpcc/workflow.hpp>
#include <xpcc/debug.hpp>

#include <xpcc/driver/connectivity/sab.hpp>

#include "loa/damballa.hpp"

GPIO__OUTPUT(LedRed, A, 0);			// TIM2_CH1
GPIO__OUTPUT(LedBlue, A, 1);		// TIM2_CH2
GPIO__OUTPUT(LedGreen, A, 2);		// TIM2_CH3

GPIO__OUTPUT(LedBacklight, A, 3);	// TIM2_CH4

xpcc::stm32::Uart5 uart5(115200);
xpcc::IODeviceWrapper<xpcc::stm32::Uart5> loggerDevice(uart5);

// Set all four logger streams to use the UART
xpcc::log::Logger xpcc::log::debug(loggerDevice);
xpcc::log::Logger xpcc::log::info(loggerDevice);
xpcc::log::Logger xpcc::log::warning(loggerDevice);
xpcc::log::Logger xpcc::log::error(loggerDevice);

using namespace xpcc::stm32;

// ----------------------------------------------------------------------------
static void
initRgbLed()
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

static void
setColorRgb(const ColorRgb& color)
{
	Timer2::setCompareValue(1, color.red * color.red);
	Timer2::setCompareValue(2, color.blue * color.blue);
	Timer2::setCompareValue(3, color.green * color.green);
}

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
// wrapper class for the A/D converter
/*class DataFlashConnector : public xpcc::sab::Callable
{
public:
	DataFlashConnector() :
		segment(0)
	{
	}
    
	void
	setSegment(xpcc::sab::Response& response, const uint16_t *newSegment)
	{
		segment = *newSegment;
		response.send();
	}
	
	void
	storeSegment(xpcc::sab::Response& response, const uint8_t *data)
	{
		response.send(segment);
		segment++;
	}
	
private:
	uint16_t segment;
};

DataFlashConnector dataFlashConnector;

// ----------------------------------------------------------------------------
// create a list of all possible actions
FLASH_STORAGE(xpcc::sab::Action actionList[]) =
{
	SAB__ACTION( 's', dataFlashConnector,	DataFlashConnector::setSegment,		2 ),
	SAB__ACTION( 'S', dataFlashConnector,	DataFlashConnector::storeSegment,	32 ),
};

xpcc::stm32::Uart5 uart5(115200);

// wrap the type definition inside a typedef to make the code more readable
typedef xpcc::sab::Slave< xpcc::sab::Interface< xpcc::stm32::Uart5 > > Slave;*/

// ----------------------------------------------------------------------------
MAIN_FUNCTION
{
	// Initialize predefined IO-Pins and load the FPGA configuration
	loa::Damballa::initialize();
	
	xpcc::stm32::SysTickTimer::enable();
	
	uart5.configurePins(uart5.REMAP_PC12_PD2);
	
	initRgbLed();
	
	// initialize ABP interface
	/*Slave slave(0x02,
			xpcc::accessor::asFlash(actionList),
			sizeof(actionList) / sizeof(xpcc::sab::Action));
	*/
	
	loa::Damballa::writeWord(0x0070, 0x7fff);
	
	int16_t speed = 0;
	uint16_t encoder2 = 0;
	uint16_t encoder6 = 11;
	uint16_t servo1 = 32768;
	ColorHsv color = { 0, 255, 100 };
	ColorHsv color2 = { 10, 255, 100 };
	xpcc::PeriodicTimer<> timer(20);
	xpcc::PeriodicTimer<> timer2(500);
	while (1)
	{
		if (timer.isExpired())
		{
			ColorRgb rgb;
			
			color.hue++;
			convertHsvToRgb(color, rgb);
			setColorRgb(rgb);
			
			color2.hue++;
			convertHsvToRgb(color2, rgb);
			
			loa::Damballa::writeWord(0x0001, rgb.red * rgb.red);		// red
			loa::Damballa::writeWord(0x0002, rgb.green * rgb.green);	// green
			loa::Damballa::writeWord(0x0003, rgb.blue * rgb.blue);	// blue
			
			// Encoders + Servos
			loa::Damballa::load();
			
			encoder2 = loa::Damballa::readWord(0x0022) % (24*4);
			encoder6 = loa::Damballa::readWord(0x0060) + 11*4;
			encoder6 = ((encoder6 % (24*4) + 2) % (24*4)) / 4;
			
			servo1 = 34150 + (11 - encoder6) * 2845;
			loa::Damballa::writeWord(0x0070, servo1);
		}
		
		if (timer2.isExpired())
		{
			loa::Led1::toggle();
			uint16_t sw = loa::Damballa::readWord(0x0000) & 0x000f;
			XPCC_LOG_DEBUG << "sw: " << sw << xpcc::endl;
			
			XPCC_LOG_DEBUG << "enc2: " << encoder2 << xpcc::endl;
			XPCC_LOG_DEBUG << "enc6: " << encoder6 << xpcc::endl;
			XPCC_LOG_DEBUG << "servo: " << servo1 << xpcc::endl;
			
			if (!loa::Button1::read()) {
				if (speed < 500) {
					speed += 40;
				}
			}
			if (!loa::Button2::read()) {
				if (speed > -500) {
					speed -= 40;
				}
			}
			
			// set PWM for BLDC2
			loa::Damballa::writeWord(0x0020, 512 + speed);
		}
		
		// decode received messages etc.
		//slave.update();
	}
}
