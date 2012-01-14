
#ifndef LOA_HPP
#define LOA_HPP

#include <xpcc/architecture.hpp>
#include <xpcc/driver/connectivity/software_spi.hpp>
#include <xpcc/driver/storage/at45db0x1d.hpp>

namespace loa
{
	GPIO__OUTPUT(Led1, E, 3);
	GPIO__OUTPUT(Led2, E, 4);
	GPIO__OUTPUT(Led3, E, 5);
	GPIO__OUTPUT(Led4, E, 6);
	
	typedef xpcc::gpio::Nibble<Led1, Led2, Led3, Led4> Leds;
	
	GPIO__INPUT(Button1, C, 13);
	GPIO__INPUT(Button2, E, 15);
	
	GPIO__OUTPUT(CsFlash, D, 11);
	GPIO__OUTPUT(CsSdCard, D, 3);
	
	/**
	 * USART3 configured as SPI Master
	 * 
	 * TX (MOSI) => PD8
	 * RX (MISO) => PD9
	 * CK (SCLK) => PD10
	 */
	//typedef xpcc::stm32::UsartSpi3 SpiFlash;
	GPIO__OUTPUT(Mosi, D, 8);
	GPIO__INPUT(Miso, D, 9);
	GPIO__OUTPUT(Sck, D, 10);
	
	typedef xpcc::SoftwareSpi<Sck, Mosi, Miso, 40000000> SpiFlash;
	extern SpiFlash spiFlash;
	
	extern xpcc::At45db0x1d<SpiFlash, CsFlash> dataflash;
	
	extern xpcc::stm32::Can1 can;
	
	namespace fpga
	{
		/**
		 * Chip Select during normal operation, DIN during configuration
		 */
		GPIO__OUTPUT(Cs, A, 4);
		extern xpcc::stm32::Spi1 spi;
		
		/**
		 * Driven low during before configuration.
		 * 
		 * After it goes high the M[2:0] pins are sampled and the configuration
		 * is started. Holding the pin low stalls the configuration start.
		 * 
		 * During configuration the FPGA indicates the occurrence of a
		 * configuration data error (i.e., CRC error) by asserting INIT_B Low.
		 * After configuration successfully completes, i.e., when the DONE pin
		 * goes High, the INIT_B pin is available as a full user-I/O pin.
		 */
		GPIO__INPUT(InitB, A, 8);
		
		/**
		 * Load/Store 
		 * 
		 * A rising edge stores the encoder values etc.
		 */
		GPIO__OUTPUT(Load, E, 7);
		
		/**
		 * FPGA Reset
		 * 
		 * Low active. Can be used to reset the internal logic of the FPGA.
		 */
		GPIO__OUTPUT(Reset, B, 2);
		
		// TODO
		GPIO__IO(Unused, E, 2);
	}
	
	// ----------------------------------------------------------------------------
	/**
	 * Peripherals of the Damballa Board
	 * 
	 * 
	 */
	class Damballa
	{
	public:
		/**
		 * Initialize the predefined IO-Pins and load the FPGA configuration
		 */
		static bool
		initialize();
		
		/// Load values into the internal buffers (e.g. encoder values)
		static void
		load();
		
		static void
		writeWord(uint16_t address, uint16_t data);
		
		static uint16_t
		readWord(uint16_t address);
		
		/**
		 * Reloads the FPGA configuration from the dataflash into
		 * the FPGA.
		 * 
		 * \return 	\c true if the configuration was successful loaded.
		 */
		static bool
		reconfigureFpga();
		
	private:
		/// Configure the SPI interface to the FPGA
		static void
		configureSpiFpga();
		/**
		 * Load the configuration into the FPGA
		 */
		static bool
		configureFpga();
		
		/**
		 * Puts the pins used for configuration in an safe state to avoid
		 * drawing constant current over one of the pull-up resistors.
		 */
		static void
		deassertFpgaConfiguration();
	};
}

#endif // LOA_HPP
