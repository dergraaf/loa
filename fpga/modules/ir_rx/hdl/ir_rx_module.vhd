-------------------------------------------------------------------------------
-- Title      : Module for Receiver for infrared beacons
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_module.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-13
-- Last update: 2012-04-18
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--
-- Two functions:
-- a) Extract sync from IR signal
-- b) Measure frequency component of opponent beacons (with Goertzel algorithm)
--
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.reg_file_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.ir_rx_module_pkg.all;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity ir_rx_module is

   -- Memory map
   -- 
   -- offset | R/W | Description
   -- -------+------------------
   --     +0 |   R | Goertzel Result 0
   --     +1 |   R | Goertzel Result 1
   --     +2 |   W | Goertzel Coefficient

   
   generic (
      BASE_ADDRESS : integer range 0 to 32767  -- Base address at the internal data bus
      );

   port (
      -- Ports to two ADCs
      -- signals to and from real hardware
      adc_out_p : out ir_rx_module_spi_out_type;
      adc_in_p  : in  ir_rx_module_spi_in_type;

      -- Raw values of last ADC conversions (two ADCs with six channels each)
      adc_values_p : out adc_ltc2351_values_type(11 downto 0);

      -- Extracted sync signal
      sync_p : out std_logic;

      -- signals to and from the internal parallel bus
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      -- Handshake interface to STM when new data is available
      done_p : out std_logic;
      ack_p  : in  std_logic;

      -- Sampling clock enable (expected to be 250 kHz or less)
      clk_sample_en : in std_logic;

      clk : in std_logic
      );

end ir_rx_module;

architecture structural of ir_rx_module is
   ----------------------------------------------------------------------------
   -- Constants
   ----------------------------------------------------------------------------

   constant INPUT_WIDTH : natural := 14;
   constant CALC_WIDTH  : natural := 18;
   constant Q           : natural := 13;
   constant SAMPLES     : natural := 250;

   constant COEF : unsigned := to_unsigned(2732, CALC_WIDTH);

   ----------------------------------------------------------------------------
   -- Internal signal declaration
   ----------------------------------------------------------------------------

   signal adc_values_s : adc_ltc2351_values_type(11 downto 0);  -- twelve ADC channels

   -- only for one channel, TODO
   signal adc_value_signed_s : signed(INPUT_WIDTH-1 downto 0);
   signal results_s          : goertzel_result_type;

   signal module_done : std_logic := '0';

   -- TODO Twelve results from Goertzel
   -- TODO: search for two frequencies


   signal adc_start_s : std_logic := '0';
   signal adc_done_s  : std_logic := '0';

   signal reg_o : reg_file_type(7 downto 0);
   signal reg_i : reg_file_type(7 downto 0);

   signal goertzel_done_s : std_logic;
   
begin  -- structural

   ----------------------------------------------------------------------------
   -- Connect components
   ----------------------------------------------------------------------------
   adc_values_p <= adc_values_s;

   reg_i(0) <= std_logic_vector(results_s(0));
   reg_i(1) <= std_logic_vector(results_s(1));
   reg_i(2) <= "00" & std_logic_vector(adc_value_signed_s(13 downto 0));

   done_p <= module_done;

   ----------------------------------------------------------------------------
   -- Component Instantiation
   ----------------------------------------------------------------------------

   -- Register file to present Goertzel values to bus
   reg_file_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => 3              -- 2**3 = 8 registers for 6 ADC values
         )
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_o,
         reg_i => reg_i,
         reset => '0',
         clk   => clk
         );

   -- Two ADCs
   adc_ltc2351_0 : adc_ltc2351
      port map (
         adc_out  => adc_out_p(0),
         adc_in   => adc_in_p(0),
         start_p  => clk_sample_en,
         values_p => adc_values_s(5 downto 0),
         done_p   => adc_done_s,
         reset    => '0',
         clk      => clk
         );

   adc_ltc2351_1 : adc_ltc2351
      port map (
         adc_out  => adc_out_p(1),
         adc_in   => adc_in_p(1),
         start_p  => clk_sample_en,
         values_p => adc_values_s(11 downto 6),
         done_p   => open,
         reset    => '0',
         clk      => clk
         );

   -- 12 Goertzel algorithms

   -- 14-bit ADC value, 0x0000 to 0x3fff, 0x2000 on average
   adc_value_signed_s <= signed(adc_values_s(5)) - to_signed(16#2000#, 14);

   -- Channel 5
   goertzel_5 : goertzel
      generic map (
         INPUT_WIDTH => INPUT_WIDTH,
         CALC_WIDTH  => CALC_WIDTH,
         Q           => Q,
         SAMPLES     => SAMPLES)
      port map (
         clk         => clk,
         coef_p      => COEF,
         start_p     => adc_done_s,
         adc_value_p => adc_value_signed_s,
         result_p    => results_s,
         done_p      => goertzel_done_s
         );

   -- Sync extraction
   -- TODO

   handshake_proc : process (clk)
   begin  -- process handshake_proc
      if rising_edge(clk) then
         if goertzel_done_s = '1' then
            module_done <= '1';
         elsif ack_p = '1' then
            module_done <= '0';
         end if;
      end if;
   end process handshake_proc;



end structural;
