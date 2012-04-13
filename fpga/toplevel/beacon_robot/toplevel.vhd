-------------------------------------------------------------------------------
-- Title      : Mobile Beacon
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2012-03-31
-- Last update: 2012-04-13
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
      sram_oe_p   : out   std_logic;
      sram_we_p   : out   std_logic;
      sram_ce_p   : out   std_logic;

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
   signal reset_r : std_logic_vector(1 downto 0) := (others => '0');
   signal reset   : std_logic;

   signal ir_clock_enable : std_logic;
   signal ir_clock        : std_logic := '0';

   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);

   signal irq : std_logic := '0';

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
   signal bus_register_out : busdevice_out_type;
   signal bus_adc_ir0_out  : busdevice_out_type;
   signal bus_adc_ir1_out : busdevice_out_type;
   signal bus_adc_us_out : busdevice_out_type;
   
begin
   -- synchronize reset and other signals
   process (clk)
   begin
      if rising_edge(clk) then
         reset_r <= reset_r(0) & reset_n;
      end if;
   end process;

   reset <= not reset_r(1);

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

   bus_i.data <= bus_register_out.data or
                 bus_adc_ir0_out.data or
 --                bus_adc_ir1_out.data or
                 bus_adc_us_out.data;

   ----------------------------------------------------------------------------
   -- Register
   preg : peripheral_register
      generic map (
         BASE_ADDRESS => 16#0000#)
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
   uss_tx_module_1: uss_tx_module
      generic map (
         BASE_ADDRESS => 16#0010#)
      port map (
         uss_tx0_out_p    => us_tx0_p,
         uss_tx1_out_p    => us_tx1_p,
         uss_tx2_out_p    => us_tx2_p,
         modulation_p     => "111", -- modulation_p,
         clk_uss_enable_p => open,
         bus_o            => bus_adc_us_out,
         bus_i            => bus_o,
         clk              => clk);

   ----------------------------------------------------------------------------
   -- IR TX
   -- generates 10Khz * 2 (times two because it's a enable signal and
   -- we need to generate a 50% duty-cycle signal later)
   -- 
   -- 50 MHz / 5000 * 1 = 20000 Hz
   ir_clock_generator : fractional_clock_divider
      generic map (
         MUL => 1,
         DIV => 5000)
      port map(
         clk_out_p => ir_clock_enable,
         clk       => clk);

   -- generate a signal with a 50% duty-cycle from the enable signal
   process (clk, ir_clock_enable)
   begin
      if rising_edge(clk) then
         if ir_clock_enable = '1' then
            ir_clock <= not ir_clock;
         end if;
      end if;
   end process;

   ir_tx_p <= ir_clock;

   ----------------------------------------------------------------------------
   -- IR RX ADC readout 0
   adc_ir_rx_0 : adc_ltc2351_module
      generic map (
         BASE_ADDRESS => 16#0020#)
      port map (
         adc_out_p    => ir_rx_spi_out_p,
         adc_in_p     => ir_rx0_spi_in_p,
         bus_o        => bus_adc_ir0_out,
         bus_i        => bus_o,
         adc_values_o => open,
         done_o       => irq_p,
         reset        => reset,
         clk          => clk);

   
end structural;
