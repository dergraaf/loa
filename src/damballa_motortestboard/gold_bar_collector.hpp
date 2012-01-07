
#ifndef GOLD_BAR_COLLECTOR_HPP
#define GOLD_BAR_COLLECTOR_HPP

#include <xpcc/workflow.hpp>

class GoldBarCollector : public xpcc::pt::Protothread
{
public:
	GoldBarCollector();
	
	void
	initialize();
	
	void
	collect();
	
	bool
	run();
	
private:
	static const int16_t preparePosition = -8190;	// Warteposition vor dem Aufnehmen
	static const int16_t collectPosition = -24000;	// Ausgefahrene Position
	static const int16_t retractPosition = 1500;		
	static const int16_t storePosition = 0;			// Position in der der Goldbarren gehalten wird
	
	bool doCollect;
	xpcc::Timeout<> timeout;
};

#endif // GOLD_BAR_COLLECTOR_HPP
