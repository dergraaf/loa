
#include <xpcc/architecture/platform.hpp>

using namespace xpcc::stm32;

typedef GpioOutputE5 Led1;
typedef GpioOutputE6 Led2;

// ----------------------------------------------------------------------------
MAIN_FUNCTION
{
	// Static Clock Setup
	typedef Pll<ExternalClock<MHz25>, MHz168, MHz48> clockSource;
	StartupError err =
		SystemClock<clockSource>::enable();

	Led1::setOutput();
	Led2::setOutput();

	while (1)
	{
		Led1::toggle();
		Led2::toggle();
		xpcc::delay_ms(500);
	}

	return 0;
}
