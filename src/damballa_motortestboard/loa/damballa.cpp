
#include "damballa.hpp"

// ----------------------------------------------------------------------------
xpcc::stm32::Can1 loa::can;
xpcc::stm32::Spi1 loa::fpga::spi;

loa::SpiFlash loa::spiFlash;
xpcc::At45db0x1d<loa::SpiFlash, loa::CsFlash> loa::dataflash;

using namespace loa;

// ----------------------------------------------------------------------------
bool
loa::Damballa::initialize()
{
	if (xpcc::stm32::Core::Clock::enableHSE(xpcc::stm32::Core::Clock::HSE_BYPASS)) {
		xpcc::stm32::Core::Clock::enablePll(xpcc::stm32::Core::Clock::PLL_HSE, 25, 336);
		xpcc::stm32::Core::Clock::switchToPll();
	}
	
	bool success = true;
	
	Led1::setOutput(xpcc::gpio::LOW);
	Led2::setOutput(xpcc::gpio::LOW);
	Led3::setOutput(xpcc::gpio::LOW);
	Led4::setOutput(xpcc::gpio::LOW);
	
	Button1::setInput(xpcc::stm32::PULLUP);
	Button2::setInput(xpcc::stm32::PULLUP);
	
	fpga::Load::setOutput(xpcc::gpio::LOW);
	fpga::Reset::setOutput(xpcc::gpio::LOW);
	
	// TODO disable NJTRST (PB4)
	
	spiFlash.initialize();
	
	// TODO configure Dataflash
	success &= dataflash.initialize();
	//success &= configureFpga();
	
	deassertFpgaConfiguration();
	
	fpga::Cs::setOutput(xpcc::gpio::HIGH);
	fpga::spi.configurePins(xpcc::stm32::Spi1::REMAP_PA5_PA6_PA7);
	fpga::spi.initialize(xpcc::stm32::Spi1::MODE_0, xpcc::stm32::Spi1::PRESCALER_4);	// 21 MHz
	
	// release Reset to start the FPGA operation
	fpga::Reset::set();
	
	//can.configurePins(can.REMAP_PD0_PD1);
	//can.initialize(xpcc::can::BITRATE_125_KBPS);
	
	// display some blinking lights to indicate the configuration
	// is finished and the microcontroller is ready
	if (success)
	{
		uint8_t pattern = 0;
		for (uint32_t i = 0; i < 4; ++i) {
			pattern = (pattern << 1) | 1;
			Leds::write(pattern);
			xpcc::delay_ms(50);
		}
		for (uint32_t i = 0; i < 4; ++i) {
			pattern = (pattern << 1) & 0xf;
			Leds::write(pattern);
			xpcc::delay_ms(50);
		}
	}
	else {
		uint8_t pattern = 0xf;
		for (uint32_t i = 0; i < 8; ++i) {
			Leds::write(pattern);
			pattern = (~pattern) & 0xf;
			xpcc::delay_ms(50);
		}
	}
	
	return success;
}

// ----------------------------------------------------------------------------
void
loa::Damballa::writeWord(uint16_t address, uint16_t data)
{
	fpga::Cs::reset();
	
	fpga::spi.write((address >> 8) | 0x80);		// write => MSB = '1'
	fpga::spi.write( address & 0xff);
	
	fpga::spi.write(data >> 8);
	fpga::spi.write(data & 0xff);
	
	fpga::Cs::set();
}

uint16_t
loa::Damballa::readWord(uint16_t address)
{
	fpga::Cs::reset();
	
	fpga::spi.write((address >> 8) & ~0x80);	// read => MSB = '0'
	fpga::spi.write( address & 0xff);
	
	uint16_t data;
	
	data  = fpga::spi.write(0) << 8;
	data |= fpga::spi.write(0);
	
	fpga::Cs::set();
	
	return data;
}

// ----------------------------------------------------------------------------
/*
 * Device  | Configuration
 *         |  Size [Bits]
 * ------- | --------------
 * XC3S50  |     439,264
 * XC3S200 |   1,047,616
 * XC3S400 |   1,699,136
 */
namespace
{
	/* Configuration clock.
	 * 
	 * Only used during FPGA configuration!
	 */
	GPIO__OUTPUT(Cclk, E, 0);
	
	/* Driven low during configuration. Goes high after configuration
	 * has finished.
	 * 
	 * Only used during FPGA configuration!
	 */
	GPIO__INPUT(Done, C, 14);
	
	/* Low pulse restarts the configuration process. Open-Drain Output.
	 * 
	 * Only used during FPGA configuration!
	 */
	GPIO__OUTPUT(ProgB, E, 1);
	
	typedef loa::fpga::Cs Din;
}

bool
loa::Damballa::configureFpga()
{
	Cclk::setOutput(xpcc::stm32::PUSH_PULL, xpcc::stm32::SPEED_50MHZ);
	Cclk::reset();
	
	Done::setInput(xpcc::stm32::FLOATING);
	ProgB::setOutput(xpcc::stm32::OPEN_DRAIN, xpcc::stm32::SPEED_50MHZ);
	
	fpga::InitB::setInput(xpcc::stm32::PULLDOWN);
	Din::setOutput(xpcc::stm32::PUSH_PULL, xpcc::stm32::SPEED_50MHZ);
	
	// Reset FPGA => starts configuration
	ProgB::reset();
	xpcc::delay_us(1);
	ProgB::set();
	
	// Wait until INIT_B goes high
	uint32_t counter = 0;
	while (fpga::InitB::read() == xpcc::gpio::LOW)
	{
		xpcc::delay_us(1);
		if (counter++ > 1000) {
			// Timeout (1ms) reached, FPGA is not responding abort configuration
			return false;
		}
	}
	
	// wait 0.5..4µs before starting the configuration
	xpcc::delay_us(4);
	
	uint32_t pos = 0;
	do {
		Din::set(1);	// TODO
		xpcc::delay_us(1);
		Cclk::set();
		Cclk::reset();
		
		pos++;
		
		if (fpga::InitB::read() == xpcc::gpio::LOW) {
			// error in configuration
			return false;
		}
	} while (Done::read() == xpcc::gpio::LOW);
	
	// TODO see Xilinx UG332 if there are more clock cycles needed
	for (uint32_t i = 0; i < 10; ++i) {
		Cclk::set();
		Cclk::reset();
	}
	
	return true;
}

void
loa::Damballa::deassertFpgaConfiguration()
{
	// Cclk has an internal Pull-up to 2,5V => set Cclk to Open-Drain Output
	Cclk::setOutput(xpcc::stm32::OPEN_DRAIN);
	Cclk::set();
}
