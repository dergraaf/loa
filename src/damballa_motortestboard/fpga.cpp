
#include <xpcc/architecture.hpp>
#include <xpcc/utils/template_metaprogramming.hpp>
#include <xpcc/workflow.hpp>

#include "loa/damballa.hpp"
#include "fpga.hpp"

// ----------------------------------------------------------------------------
const uint16_t Fpga::fromFpgaAddress[] = {
	0x0000,		// 0: Buttons
	0x0012,		// 1: Encoder BLDC1
	0x0022,		// 2: Encoder BLDC2
	0x0032,		// 3: Encoder DC3
	0x0042,		// 4: Encoder DC4
	0x0060,		// 5: Encoder 6
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
};
static const uint16_t fpgaWriteEntries = sizeof(Fpga::toFpgaBuffer) / sizeof(Fpga::toFpgaBuffer[0]);

// ----------------------------------------------------------------------------
static void
dummyHandler()
{
	// do nothing
}

Fpga::Handler controlHandler = dummyHandler;

// TODO replace this with an Interrupt
static xpcc::PeriodicTimer<> timer(1);
void
Fpga::update()
{
	if (timer.isExpired())
	{
		// Sample Encoder values
		loa::Damballa::load();
		
		for (uint32_t i = 0; i < fpgaReadEntries; ++i) {
			fromFpgaBuffer[i] = loa::Damballa::readWord(fromFpgaAddress[i]);
		}
		
		controlHandler();
		
		for (uint32_t i = 0; i < fpgaWriteEntries; ++i) {
			loa::Damballa::writeWord(toFpgaBuffer[i].address, toFpgaBuffer[i].value);
		}
	}
}

// ----------------------------------------------------------------------------
void
Fpga::initialize()
{
	XPCC__STATIC_ASSERT(sizeof(fromFpgaAddress) == sizeof(fromFpgaBuffer), "Check buffer size!");
	
	
}

// ----------------------------------------------------------------------------
void
Fpga::attachHandler(Handler handler)
{
	controlHandler = handler;
}
