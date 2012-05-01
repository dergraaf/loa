-------------------------------------------------------------------------------
-- Title      : Mobile Beacon
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Authors    : Fabian Greif  <fabian.greif@rwth-aachen.de>, strongly-typed
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2012-03-31
-- Last update: 2012-05-01
-- Platform   : Spartan 3A-200
-------------------------------------------------------------------------------
-- Description:
-- ...
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.spislave_pkg.all;

use work.reg_file_pkg.all;
use work.motor_control_pkg.all;
use work.deadtime_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.uss_tx_pkg.all;
use work.ir_tx_pkg.all;
use work.utils_pkg.all;
use work.signalprocessing_pkg.all;
use work.ir_rx_module_pkg.all;

use work.memory_map_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- Connections to the STM32F407
      -- SPI
      cs_np  : in  std_logic;
      sck_p  : in  std_logic;
      miso_p : out std_logic;
      mosi_p : in  std_logic;

      -- hardwired
      ir_irq_p : out std_logic;
      us_irq_p : out std_logic;

      ir_ack_p : in std_logic;
      us_ack_p : in std_logic;

      -- 4 MBit SRAM CY7C1049DV33-10ZSXI (428-1982-ND)
      sram_addr_p : out   std_logic_vector(18 downto 0);
      sram_data_p : inout std_logic_vector(7 downto 0);
      sram_oe_np  : out   std_logic;
      sram_we_np  : out   std_logic;
      sram_ce_np  : out   std_logic;

      -- US TX
      us_tx0_p : out half_bridge_type;
      us_tx1_p : out half_bridge_type;
      us_tx2_p : out half_bridge_type;

      -- US RX: one LTC2351 ADC
      us_rx_spi_in_p  : in  adc_ltc2351_spi_in_type;
      us_rx_spi_out_p : out adc_ltc2351_spi_out_type;

      -- IR TX
      ir_tx_p : out std_logic;

      -- IR RX: two LTC2351 ADC
      ir_rx_spi_out_p : out adc_ltc2351_spi_out_type;
      ir_rx0_spi_in_p : in  adc_ltc2351_spi_in_type;

      ir_rx1_spi_in_p : in adc_ltc2351_spi_in_type;

      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is

   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);

   -- Modulation
   signal mod_cnt             : natural                      := 0;
   signal modulation_us       : std_logic_vector(2 downto 0) := (others => '0');
   signal clk_modulation_us_s : std_logic                    := '0';

   -- Synchronise inputs
   signal ir_ack_r : std_logic_vector(1 downto 0) := (others => '0');
   signal ir_ack   : std_logic;

   signal us_ack_r : std_logic_vector(1 downto 0) := (others => '0');
   signal us_ack   : std_logic;

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
   signal bus_register_out         : busdevice_out_type;
   signal bus_adc_ir0_out          : busdevice_out_type;
   signal bus_adc_ir1_out          : busdevice_out_type;
   signal bus_adc_us_out           : busdevice_out_type;
   signal bus_ir_tx_out            : busdevice_out_type;
   signal bus_ir_rx_out            : busdevice_out_type;
   signal bus_ir_rx_adc_values_out : busdevice_out_type;

   -- Common clock enable for ADCs
   signal clk_adc_en_s : std_logic;

   -- Connections to and from the IR ADCs
   signal ir_rx_module_spi_out : ir_rx_module_spi_out_type;
   signal ir_rx_module_spi_in  : ir_rx_module_spi_in_type;

   signal adc_values_ltc_s : adc_ltc2351_values_type(11 downto 0);
   signal adc_values_reg_s : reg_file_type(15 downto 0);

begin

   ----------------------------------------------------------------------------
   bus_i.data <= bus_register_out.data or
                 bus_adc_ir0_out.data or
                 --bus_adc_ir1_out.data or
                 bus_ir_rx_out.data or
                 bus_adc_us_out.data or
                 bus_ir_rx_adc_values_out.data or
                 bus_ir_tx_out.data;
   ----------------------------------------------------------------------------

   -- TODO generic CHANNELS
   copy_values : for ii in 0 to 11 generate
      adc_values_reg_s(ii) <= "00" & adc_values_ltc_s(ii);
   end generate copy_values;

   ----------------------------------------------------------------------------

   -- SPI connection to the STM32F4xx and Busmaster
   -- for the internal bus
   spi : spi_slave
      port map (
         miso_p => miso_p,
         mosi_p => mosi_p,
         sck_p  => sck_p,
         csn_p  => cs_np,

         bus_o => bus_o,
         bus_i => bus_i,

         reset => '0',
         clk   => clk);

   ----------------------------------------------------------------------------
   -- 4 MBit SRAM CY7C1049DV33-10ZSXI (428-1982-ND)
   sram_data_p <= (others => 'Z');
   sram_addr_p <= (others => 'Z');
   sram_ce_np  <= 'Z';
   sram_we_np  <= 'Z';
   sram_oe_np  <= 'Z';

   ----------------------------------------------------------------------------
   -- Register
   -- some test data to test FPGA STM communication
   preg : peripheral_register
      generic map (
         BASE_ADDRESS => BASE_ADDR_REG)
      port map (
         dout_p => register_out,
         din_p  => register_in,
         bus_o  => bus_register_out,
         bus_i  => bus_o,
         reset  => '0',
         clk    => clk);

   register_in <= x"abc" & "0000";

   ----------------------------------------------------------------------------
   -- Modulation
   ----------------------------------------------------------------------------
   clock_divider_mod : clock_divider
      generic map (
         DIV => 5000)                   -- 10 kHz <> 100 usec
      port map (
         clk_out_p => clk_modulation_us_s,
         clk       => clk);

   us_modulation_proc : process (clk)
      variable cnt : natural := 0;


      
   begin  -- process us_modulation_proc
      if rising_edge(clk) then
         if clk_modulation_us_s = '1' then
            if cnt = 100 then
               cnt := 0;
            else
               cnt := cnt + 1;
            end if;
         end if;
      end if;

      mod_cnt <= cnt;
   end process us_modulation_proc;

   Modulation_us <= "111" when (mod_cnt < 3) else "000";


   ----------------------------------------------------------------------------
   -- US TX
   ----------------------------------------------------------------------------
   uss_tx_module_1 : uss_tx_module
      generic map (
         BASE_ADDRESS => BASE_ADDR_US_TX)
      port map (
         uss_tx0_out_p    => us_tx0_p,
         uss_tx1_out_p    => us_tx1_p,
         uss_tx2_out_p    => us_tx2_p,
         modulation_p     => modulation_us,
         clk_uss_enable_p => open,
         bus_o            => bus_adc_us_out,
         bus_i            => bus_o,
         clk              => clk);

   ----------------------------------------------------------------------------
   -- IR TX
   ir_tx_module_1 : ir_tx_module
      generic map (
         BASE_ADDRESS => BASE_ADDR_IR_TX)
      port map (
         ir_tx_p         => ir_tx_p,
         modulation_p    => '1',        -- modulation_p,
         clk_ir_enable_p => open,
         bus_o           => bus_ir_tx_out,
         bus_i           => bus_o,
         clk             => clk);

   ------------------------------------------------------------------------------

   -- direct access to the ADC values
   reg_file_adc_values : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDR_IR_RX_ADC,
         REG_ADDR_BIT => 4)             -- 2**4 = 16 values
      port map (
         bus_o => bus_ir_rx_adc_values_out,
         bus_i => bus_o,
         reg_o => open,
         reg_i => adc_values_reg_s,
         reset => '0',
         clk   => clk);

   ------------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   -- Common sample Clock for US RX and IR RX
   -- 50 MHz / 200 = 250 kHz
   -- 50 MHz / 500 = 100 kHz
   -- 50 MHz / 667 =  75 kHz
   ----------------------------------------------------------------------------

   clock_divider_adc : clock_divider
      generic map (
         DIV => 667)
      port map (
         clk_out_p => clk_adc_en_s,
         clk       => clk);


   ----------------------------------------------------------------------------
   -- US RX ADC readout
   ----------------------------------------------------------------------------
   us_rx_spi_out_p.sck  <= 'Z';
   us_rx_spi_out_p.conv <= 'Z';

   us_irq_p <= 'Z';

   -- SPI of both ADCs has common CONV and SCK
   ir_rx_spi_out_p        <= ir_rx_module_spi_out(0);
   ir_rx_module_spi_in(0) <= ir_rx0_spi_in_p;
   ir_rx_module_spi_in(1) <= ir_rx1_spi_in_p;

   ir_rx_module_0 : ir_rx_module
      generic map (
         BASE_ADDRESS_COEFS   => BASE_ADDR_IR_RX_COEFS,
         BASE_ADDRESS_RESULTS => BASE_ADDR_IR_RX_RESULTS)
      port map (
         adc_out_p     => ir_rx_module_spi_out,
         adc_in_p      => ir_rx_module_spi_in,
         adc_values_p  => adc_values_ltc_s,
         sync_p        => open,
         bus_o         => bus_ir_rx_out,
         bus_i         => bus_o,
-- debug         done_p        => ir_irq_p,
-- debug         ack_p         => ir_ack,
         done_p        => open,
         ack_p         => '0',
         clk_sample_en => clk_adc_en_s,
         clk           => clk);



   ----------------------------------------------------------------------------
   -- Modulation
   ----------------------------------------------------------------------------



   ----------------------------------------------------------------------------
   -- synchronize acknowledge signals
   ----------------------------------------------------------------------------
   process (clk)
   begin
      if rising_edge(clk) then
         ir_ack_r <= ir_ack_r(0) & ir_ack_p;
         us_ack_r <= us_ack_r(0) & us_ack_p;
      end if;
   end process;

   ir_ack <= ir_ack_r(1);
   us_ack <= us_ack_r(1);
   
end structural;
