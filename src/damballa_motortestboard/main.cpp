
#include <xpcc/architecture.hpp>
#include <xpcc/workflow.hpp>
#include <xpcc/debug.hpp>

#include "loa/damballa.hpp"

#include "uplink.hpp"
#include "fpga.hpp"
#include "led.hpp"
#include "control.hpp"
#include "ui.hpp"

xpcc::stm32::Uart5 uart5(115200);
xpcc::IODeviceWrapper<xpcc::stm32::Uart5> loggerDevice(uart5);

// Set all four logger streams to use the UART
xpcc::log::Logger xpcc::log::debug(loggerDevice);
xpcc::log::Logger xpcc::log::info(loggerDevice);
xpcc::log::Logger xpcc::log::warning(loggerDevice);
xpcc::log::Logger xpcc::log::error(loggerDevice);

using namespace xpcc::stm32;

// ----------------------------------------------------------------------------
MAIN_FUNCTION
{
	uart5.configurePins(uart5.REMAP_PC12_PD2);
	
	// Initialize predefined IO-Pins and load the FPGA configuration
	loa::Damballa::initialize();
	
	xpcc::stm32::SysTickTimer::enable();
	
	Fpga::initialize();
	Uplink::initialize();
	Led::initialize();
	Ui::initialize();
	Control::initialize();
	
	XPCC_LOG_INFO << "Motortestboard ready ..." << xpcc::endl;
	
	int16_t speed = 0;
	uint16_t servo1 = 32768;
	ColorHsv color = { 0, 255, 100 };
	ColorHsv color2 = { 10, 255, 100 };
	xpcc::PeriodicTimer<> timer(20);
	xpcc::PeriodicTimer<> timer2(500);
	while (1)
	{
		if (timer.isExpired())
		{
			color.hue++;
			color2.hue++;
			
			Led::setHsv(Led::LED1, color);
			Led::setHsv(Led::LED2, color2);
			
			//servo1 = 34150 + (11 - encoder6) * 2845;*/
			//Fpga::setServo(Fpga::SERVO1, servo1);
		}
		
		if (timer2.isExpired())
		{
			loa::Led1::toggle();
			
			//uint16_t buttons = Fpga::getButtons() & 0x000f;
			//XPCC_LOG_DEBUG << "l=" << static_cast<int16_t>(Ui::getEncoder(Ui::ENCODER_6) - 12) << xpcc::endl;
			//XPCC_LOG_DEBUG << "r=" << static_cast<int16_t>(Ui::getEncoder(Ui::ENCODER_7) - 12) << xpcc::endl;
			
			XPCC_LOG_DEBUG << "l=" << Control::getSpeed(Control::DRIVE_LEFT) << xpcc::endl;
			XPCC_LOG_DEBUG << "r=" << Control::getSpeed(Control::DRIVE_RIGHT) << xpcc::endl;
			
			// set PWM for BLDC2
			//loa::Damballa::writeWord(0x0020, 512 + speed);
		}
		
		Uplink::update();
		
		// TODO remove this
		Fpga::update();
	}
}
