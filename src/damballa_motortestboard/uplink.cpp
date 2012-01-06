
#include <xpcc/architecture.hpp>
#include <xpcc/driver/connectivity/sab.hpp>
#include <xpcc/driver/connectivity/sab2/interface.hpp>

#include <xpcc/debug/logger.hpp>

#include "uplink.hpp"
#include "loa/damballa.hpp"

// ----------------------------------------------------------------------------
class DataFlashConnector : public xpcc::sab::Callable
{
public:
	DataFlashConnector() :
		segment(0)
	{
	}
    
	void
	getBitfileSize(xpcc::sab::Response& response)
	{
		loa::Led2::toggle();
		XPCC_LOG_DEBUG << "bitsize" << xpcc::endl;
		
		/* 
		 * XC3S50  =   439,264 Bits =  54,908 Bytes
		 * XC3S200 = 1,047,616 Bits = 130,952 Bytes
		 * XC3S400 = 1,699,136 Bits = 212,392 Bytes
		 */
		int32_t bitfileSize = 212392;
		response.send(bitfileSize);
	}
	
	void
	setSegment(xpcc::sab::Response& response, const uint16_t *newSegment)
	{
		loa::Led3::toggle();
		XPCC_LOG_DEBUG << "segment=" << *newSegment << xpcc::endl;
		
		segment = *newSegment;
		response.send();
	}
	
	void
	storeSegment(xpcc::sab::Response& response, const uint8_t *data)
	{
		loa::Led4::toggle();
		XPCC_LOG_DEBUG << "store=" << segment << xpcc::endl;
		
		uint16_t offset = segment % 8;
		
		loa::dataflash.waitUntilReady();
		loa::dataflash.writeToBuffer(xpcc::at45db::BUFFER_0, offset * 32, data, 32);
		
		if (offset == 7) {
			XPCC_LOG_DEBUG << "write page" << xpcc::endl;
			// page finished
			uint16_t pageAddress = segment / 8;
			
			loa::dataflash.waitUntilReady();
			loa::dataflash.copyBufferToPage(xpcc::at45db::BUFFER_0, pageAddress);
		}
		
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
	SAB__ACTION('b', dataFlashConnector,	DataFlashConnector::getBitfileSize, 0 ),
	SAB__ACTION('s', dataFlashConnector,	DataFlashConnector::setSegment,		2 ),
	SAB__ACTION('S', dataFlashConnector,	DataFlashConnector::storeSegment,	32 ),
};

static xpcc::stm32::BufferedUsart1 uart1(115200);

// wrap the type definition inside a typedef to make the code more readable
typedef xpcc::sab::Slave< xpcc::sab2::Interface< xpcc::stm32::BufferedUsart1 > > Slave;

// initialize ABP interface
static Slave slave(0x02,
		xpcc::accessor::asFlash(actionList),
		sizeof(actionList) / sizeof(xpcc::sab::Action));

// ----------------------------------------------------------------------------
void
Uplink::initialize()
{
	uart1.configurePins(uart1.REMAP_PB6_PB7);
}

// ----------------------------------------------------------------------------
void
Uplink::update()
{
	// decode received messages etc.
	slave.update();
}
