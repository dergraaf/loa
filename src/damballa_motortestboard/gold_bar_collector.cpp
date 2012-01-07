
#include "fpga.hpp"
#include "pins.hpp"

#include "gold_bar_collector.hpp"

// ----------------------------------------------------------------------------
GoldBarCollector::GoldBarCollector() :
	doCollect(false),
	timeout()
{
	pin::GoldBarDetector::setInput(xpcc::stm32::FLOATING);
}

// ----------------------------------------------------------------------------
void
GoldBarCollector::initialize()
{
	Fpga::setServo(Fpga::SERVO1, preparePosition);
}

// ----------------------------------------------------------------------------
void
GoldBarCollector::collect()
{
	doCollect = true;
}

// ----------------------------------------------------------------------------
bool
GoldBarCollector::run()
{
	PT_BEGIN();
	
	while (true)
	{
		PT_WAIT_UNTIL(doCollect);
		
		timeout.restart(300);
		Fpga::setServo(Fpga::SERVO1, preparePosition);
		
		PT_WAIT_UNTIL(timeout.isExpired());
		
		while (!pin::GoldBarDetector::read()) {
			PT_YIELD();
		}
		
		timeout.restart(400);
		Fpga::setServo(Fpga::SERVO1, collectPosition);
		
		PT_WAIT_UNTIL(timeout.isExpired());
		
		timeout.restart(800);
		Fpga::setServo(Fpga::SERVO1, retractPosition);
		
		PT_WAIT_UNTIL(timeout.isExpired());
		
		Fpga::setServo(Fpga::SERVO1, storePosition);
		doCollect = false;
	}
	
	PT_END();
}
