
#include <xpcc/architecture.hpp>
#include <xpcc/utils/template_metaprogramming.hpp>

#include "loa/damballa.hpp"
#include "fpga.hpp"

// ----------------------------------------------------------------------------
const uint16_t Fpga::fromFpgaAddress[] = {
	0x0000,		// 0: Buttons
	0x0012,		// 1: Encoder BLDC1
	0x0013,		// 2: Encoder Timing BLDC1
	0x0022,		// 3: Encoder BLDC2
	0x0023,		// 4: Encoder Timing BLDC2
	0x0032,		// 5: Encoder DC3
	0x0042,		// 6: Encoder DC4
	0x0060,		// 7: Encoder 6
	0x0080,     // 8: ADC ch 0
	0x0081,     // 9: ADC ch 1
	0x0082,     // 10: ADC ch 2
	0x0083,     // 11: ADC ch 3
	0x0084,     // 12: ADC ch 4
	0x0085,     // 13: ADC ch 5
	0x0086,     // 14: ADC ch 6
	0x0087,     // 15: ADC ch 7
};
static const uint16_t fpgaReadEntries = sizeof(Fpga::fromFpgaAddress) / sizeof(Fpga::fromFpgaAddress[0]);

uint16_t Fpga::fromFpgaBuffer[sizeof(fromFpgaAddress) / sizeof(fromFpgaAddress[0])];

// Values send to the FPGA
Fpga::SpiWriteFormat Fpga::toFpgaBuffer[] = {
	{ 0x0000 | 0x8000, 0 },	// 0: LEDs in lower four bits
	{ 0x0001 | 0x8000, 0 },	// 1: PWM RGB Led Red
	{ 0x0002 | 0x8000, 0 },	// 2: PWM RGB Led Green
	{ 0x0003 | 0x8000, 0 },	// 3: PWM RGB Led Blue
	{ 0x0010 | 0x8000, 0 },	// 4: PWM BLDC1
	{ 0x0020 | 0x8000, 0 },	// 5: PWM BLDC2
	{ 0x0030 | 0x8000, 0 },	// 6: PWM DC3
	{ 0x0040 | 0x8000, 0 },	// 7: PWM DC4
	{ 0x0070 | 0x8000, 0 },	// 8: Servo 1
	{ 0x0071 | 0x8000, 0 },	// 9: Servo 2
	{ 0x0072 | 0x8000, 0 },	// 10: Servo 3
	{ 0x0080 | 0x8000, 0 }, // 11: ADC mask
};
static const uint16_t fpgaWriteEntries = sizeof(Fpga::toFpgaBuffer) / sizeof(Fpga::toFpgaBuffer[0]);

using namespace xpcc::stm32;

// ----------------------------------------------------------------------------
static void
dummyHandler()
{
	// do nothing
}

Fpga::Handler controlHandler = &dummyHandler;

extern "C" void
TIM6_DAC_IRQHandler(void)
{
	Timer6::resetInterruptFlag(Timer6::FLAG_UPDATE);
	
	// Sample Encoder values
	loa::Damballa::load();
	
	for (uint32_t i = 0; i < fpgaReadEntries; ++i) {
		Fpga::fromFpgaBuffer[i] = loa::Damballa::readWord(Fpga::fromFpgaAddress[i]);
	}
	
	controlHandler();
	
	for (uint32_t i = 0; i < fpgaWriteEntries; ++i) {
		loa::Damballa::writeWord(Fpga::toFpgaBuffer[i].address, Fpga::toFpgaBuffer[i].value);
	}
}

// ----------------------------------------------------------------------------
void
Fpga::initialize()
{
	XPCC__STATIC_ASSERT(sizeof(fromFpgaAddress) == sizeof(fromFpgaBuffer),
			"Check buffer size!");
	
	// Set Timer 6 to generate interrupts every 1ms
	Timer6::enable();
	Timer6::setMode(Timer6::UP_COUNTER);
	Timer6::setPeriod(1000);
	
	Timer6::enableInterruptVector(true, 10);
	Timer6::enableInterrupt(Timer6::INTERRUPT_UPDATE);
	
	Timer6::start();
}

// ----------------------------------------------------------------------------
void
Fpga::enable(bool enable)
{
	if (enable) {
		Timer6::enableInterrupt(Timer6::INTERRUPT_UPDATE);
	}
	else {
		Timer6::disableInterrupt(Timer6::INTERRUPT_UPDATE);
	}
}

// ----------------------------------------------------------------------------
void
Fpga::attachHandler(Handler handler)
{
	controlHandler = handler;
}
