
#include <xpcc/debug.hpp>

#include "damballa.hpp"

#undef XPCC_LOG_LEVEL
#define	XPCC_LOG_LEVEL xpcc::log::DEBUG

// ----------------------------------------------------------------------------
xpcc::stm32::Can1 loa::can;
xpcc::stm32::Spi1 loa::fpga::spi;

loa::SpiFlash loa::spiFlash;
//loa::SpiFlash loa::spiFlash(100000);
xpcc::At45db0x1d<loa::SpiFlash, loa::CsFlash> loa::dataflash;

using namespace loa;
using namespace xpcc::stm32;

// ----------------------------------------------------------------------------
bool
loa::Damballa::initialize()
{
	if (Core::Clock::enableHse(Core::Clock::HSE_BYPASS)) {
		Core::Clock::enablePll(Core::Clock::PLL_HSE, 25, 336);
		Core::Clock::switchToPll();
	}
	
	XPCC_LOG_DEBUG << "." << xpcc::endl;
	
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
	/*spiFlash.configureTxPin(spiFlash.REMAP_PD8);
	spiFlash.configureRxPin(spiFlash.REMAP_PD9);
	spiFlash.configureCkPin(spiFlash.REMAP_PD10);*/
	
	bool success = true;
	success &= dataflash.initialize();
	if (success) {
		success &= configureFpga();
	}
	
	deassertFpgaConfiguration();
	
	fpga::Cs::setOutput(xpcc::gpio::HIGH);
	fpga::spi.configurePins(xpcc::stm32::Spi1::REMAP_PA5_PA6_PA7);
	fpga::spi.initialize(xpcc::stm32::Spi1::MODE_0, xpcc::stm32::Spi1::PRESCALER_8);	// 10.5 MHz
	
	// release Reset to start the FPGA operation
	fpga::Reset::set();
	
	// check if we could read a fixed value from the FPGA
	uint16_t sw = readWord(0);
	if ((sw & 0xfff0) != 0xabc0) {
		success = false;
	}
	
	//can.configurePins(can.REMAP_PD0_PD1);
	//can.initialize(xpcc::can::BITRATE_125_KBPS);
	
	// display some blinking lights to indicate the configuration
	// is finished and the microcontroller is ready
	if (success)
	{
		uint8_t pattern = 0;
		for (uint32_t i = 0; i < 4; ++i) {
			pattern = (pattern >> 1) | 0x8;
			Leds::write(pattern);
			writeWord(0x0000, pattern);
			xpcc::delay_ms(50);
		}
		for (uint32_t i = 0; i < 4; ++i) {
			pattern = (pattern >> 1) & 0xf;
			Leds::write(pattern);
			writeWord(0x0000, pattern);
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
loa::Damballa::load()
{
	fpga::Load::set();
	xpcc::delay_us(1);	// FIXME should be shorter!
	//asm volatile ("nop.w");
	fpga::Load::reset();
}

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
 * Device  | Configuration | Configuration
 *         |  Size [Bits]  |  Size [Bytes]
 * ------- | ------------- | --------------
 * XC3S50  |     439,264   |     54,908
 * XC3S200 |   1,047,616   |    130,952
 * XC3S400 |   1,699,136   |    212,392
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
	
	XPCC_LOG_DEBUG << "configure FPGA" << xpcc::endl;
	
	// Reset FPGA => starts configuration
	ProgB::reset();
	
	{
		// wait until InitB and Done go low
		uint32_t counter = 0;
		while (fpga::InitB::read() == xpcc::gpio::HIGH ||
				Done::read() == xpcc::gpio::HIGH)
		{
			xpcc::delay_us(1);
			if (counter++ > 1000) {
				// Timeout (1ms) reached, FPGA is not responding abort configuration
				XPCC_LOG_ERROR << "FPGA not responding during reset!" << xpcc::endl;
				return false;
			}
		}
	}
	
	xpcc::delay_us(1);
	ProgB::set();
	
	// Wait until INIT_B goes high
	uint32_t counter = 0;
	while (fpga::InitB::read() == xpcc::gpio::LOW)
	{
		xpcc::delay_us(1);
		if (counter++ > 1000) {
			// Timeout (1ms) reached, FPGA is not responding abort configuration
			XPCC_LOG_ERROR << "FPGA not responding!" << xpcc::endl;
			return false;
		}
	}
	
	// wait 0.5..4µs before starting the configuration
	xpcc::delay_us(4);
	
	uint8_t buffer[256];
	loa::dataflash.readPageFromMemory(0, buffer, sizeof(buffer));
	
	uint32_t pos = 0;
	uint32_t offset = 0;
	do {
		uint8_t byte = buffer[offset];
		
		//XPCC_LOG_DEBUG.printf("%02x,", byte);
		
		// write byte
		for (uint_fast8_t i = 0; i < 8; i++)
		{
			// MSB first
			if (byte & 0x80) {
				Din::set();
			}
			else {
				Din::reset();
			}
			byte <<= 1;
			
			Cclk::set();
			Cclk::reset();
			
			if (Done::read() == xpcc::gpio::HIGH) {
				XPCC_LOG_DEBUG << "FPGA configuration successful" << xpcc::endl;
				XPCC_LOG_ERROR << "addr=" << pos << xpcc::endl;
				break;
			}
			
			if (fpga::InitB::read() == xpcc::gpio::LOW) {
				// error in configuration
				XPCC_LOG_ERROR << "FPGA configuration aborted!" << xpcc::endl;
				XPCC_LOG_ERROR << "done=" << Done::read() << xpcc::endl;
				XPCC_LOG_ERROR << "i=" << i << xpcc::endl;
				XPCC_LOG_ERROR << "addr=" << pos << xpcc::endl;
				XPCC_LOG_ERROR << "offset=" << offset << xpcc::endl;
				return false;
			}
		}
		
		offset++;
		pos++;
		if (offset == 256) {
			offset = 0;
			loa::dataflash.readPageFromMemory(pos, buffer, sizeof(buffer));
		}
		
		if (pos > 212392+100) {
			XPCC_LOG_DEBUG << "FPGA configuration failed!" << xpcc::endl;
			return false;
		}
	} while (Done::read() == xpcc::gpio::LOW);
	
	// TODO see Xilinx UG332 if there are more clock cycles needed
	for (uint_fast8_t i = 0; i < 10; ++i) {
		Cclk::set();
		//xpcc::delay_us(1);
		Cclk::reset();
		//xpcc::delay_us(1);
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
