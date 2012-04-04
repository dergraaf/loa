-------------------------------------------------------------------------------
-- Title      : Mobile Beacon
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2012-03-31
-- Last update: 2012-04-03
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
use work.utils_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- US
      us_tx0_p : out half_bridge_type;
      us_tx1_p : out half_bridge_type;
      us_tx2_p : out half_bridge_type;

      -- IR
      ir_tx_p : out std_logic;

      -- Connections to the STM32F407
      cs_np  : in  std_logic;
      sck_p  : in  std_logic;
      miso_p : out std_logic;
      mosi_p : in  std_logic;

      reset_n : in std_logic;
      clk     : in std_logic
      );
end toplevel;

architecture structural of toplevel is
   signal reset_r : std_logic_vector(1 downto 0) := (others => '0');
   signal reset   : std_logic;

   signal uss_clock_enable : std_logic;  -- 32.8kHz * 2
   signal uss_clock        : std_logic := '0';
   signal uss_clock_n      : std_logic := '1';

   signal uss_tx_high : std_logic;
   signal uss_tx_low  : std_logic;
   
   signal ir_clock_enable : std_logic;
   signal ir_clock        : std_logic := '0';
   
   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
   signal bus_register_out : busdevice_out_type;
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

   bus_i.data <= bus_register_out.data;

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
   --led_np <= not register_out(3 downto 0);

   ----------------------------------------------------------------------------
   -- US Sensors

   -- generates 32.8Khz * 2 (times two because it's a enable signal and
   -- we need to generate a 50% duty-cycle signal later)
   -- 
   -- 50 MHz / 31250 * 41 = 65600 Hz
   uss_clock_generator : fractional_clock_divider
      generic map (
         MUL => 41,
         DIV => 31250)
      port map(
         clk_out_p => uss_clock_enable,
         clk       => clk);

   -- generate a signal with a 50% duty-cycle from the enable signal
   process (clk, uss_clock_enable)
   begin
      if rising_edge(clk) then
         if uss_clock_enable = '1' then
            uss_clock <= not uss_clock;
         end if;
      end if;
   end process;

   uss_clock_n <= not uss_clock;

   deadtime_on : deadtime
      generic map (
         T_DEAD => 250)                  -- 5000ns
      port map (
         in_p  => uss_clock_n,
         out_p => uss_tx_low,
         clk   => clk);

   deadtime_off : deadtime
      generic map (
         T_DEAD => 250)                  -- 5000ns
      port map (
         in_p  => uss_clock,
         out_p => uss_tx_high,
         clk   => clk);

   us_tx0_p.high <= uss_tx_high;
   us_tx1_p.high <= uss_tx_high;
   us_tx2_p.high <= uss_tx_high;

   us_tx0_p.low <= uss_tx_low;
   us_tx1_p.low <= uss_tx_low;
   us_tx2_p.low <= uss_tx_low;

   ----------------------------------------------------------------------------
   -- IR 
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
end structural;
