-------------------------------------------------------------------------------
-- Title      : Mobile Beacon
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2012-03-31
-- Last update: 2012-04-14
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

use work.peripheral_register_pkg.all;
use work.motor_control_pkg.all;
use work.deadtime_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.uss_tx_pkg.all;
use work.ir_tx_pkg.all;
use work.utils_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- Connections to the STM32F407
      -- SPI
      cs_np  : in  std_logic;
      sck_p  : in  std_logic;
      miso_p : out std_logic;
      mosi_p : in  std_logic;

      irq_p : out std_logic;            -- Inform STM about new data

      -- hardwired
      -- tbd

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
      ir_rx1_spi_in_p : in  adc_ltc2351_spi_in_type;

      reset_n : in std_logic;
      clk     : in std_logic
      );
end toplevel;

architecture structural of toplevel is

   constant BASE_ADDR_REG    : natural := 16#0000#;
   constant BASE_ADDR_US_TX  : natural := 16#0010#;
   constant BASE_ADDR_IR_TX  : natural := 16#0020#;
   constant BASE_ADDR_IR0_RX : natural := 16#0030#;
   constant BASE_ADDR_IR1_RX : natural := 16#0040#;
   constant BASE_ADDR_US_RX  : natural := 16#0050#;

   signal reset_r : std_logic_vector(1 downto 0) := (others => '0');
   signal reset   : std_logic;

   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);

   signal irq : std_logic := '0';

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
   signal bus_register_out : busdevice_out_type;
   signal bus_adc_ir0_out  : busdevice_out_type;
   signal bus_adc_ir1_out  : busdevice_out_type;
   signal bus_adc_us_out   : busdevice_out_type;
   signal bus_ir_tx_out    : busdevice_out_type;
   

   

begin

   ----------------------------------------------------------------------------
   bus_i.data <= bus_register_out.data or
                 bus_adc_ir0_out.data or
                 -- bus_adc_ir1_out.data or
                 bus_adc_us_out.data or
                 bus_ir_tx_out.data;

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

         reset => reset,
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
   preg : peripheral_register
      generic map (
         BASE_ADDRESS => BASE_ADDR_REG)
      port map (
         dout_p => register_out,
         din_p  => register_in,
         bus_o  => bus_register_out,
         bus_i  => bus_o,
         reset  => reset,
         clk    => clk);

   register_in <= x"abc" & "0000";

   -- no LEDs at FPGA at beacon-digi.brd
   --led_np <= not register_out(3 downto 0);

   ----------------------------------------------------------------------------
   -- US TX
   uss_tx_module_1 : uss_tx_module
      generic map (
         BASE_ADDRESS => BASE_ADDR_US_TX)
      port map (
         uss_tx0_out_p    => us_tx0_p,
         uss_tx1_out_p    => us_tx1_p,
         uss_tx2_out_p    => us_tx2_p,
         modulation_p     => "111",     -- uss_modulation,
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

   ----------------------------------------------------------------------------
   -- IR RX ADC readout 0
   adc_ir_rx_0 : adc_ltc2351_module
      generic map (
         BASE_ADDRESS => BASE_ADDR_IR0_RX)
      port map (
         adc_out_p    => ir_rx_spi_out_p,
         adc_in_p     => ir_rx0_spi_in_p,
         bus_o        => bus_adc_ir0_out,
         bus_i        => bus_o,
         adc_values_o => open,
         done_o       => irq_p,
         reset        => reset,
         clk          => clk);

   ----------------------------------------------------------------------------
   -- IR RX ADC readout 1
   us_rx_spi_out_p.sck <= 'Z';
   us_rx_spi_out_p.conv <= 'Z';

   ----------------------------------------------------------------------------
   -- US RX ADC readout

   ----------------------------------------------------------------------------
   -- Modulation



end structural;
