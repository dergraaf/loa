-------------------------------------------------------------------------------
-- Title      : Module for Receiver for infrared beacons
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_module.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-13
-- Last update: 2012-04-15
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

-------------------------------------------------------------------------------

entity ir_rx_module is

   -- Memory map
   -- 
   -- offset | R/W | Description
   -- -------+------------------
   --     +0 |   W | Goertzel Coefficient
   --     +1 |   R |
   generic (
      BASE_ADDRESS : integer range 0 to 32767  -- Base address at the internal data bus
      );

   port (
      -- Ports to two ADCs
      -- signals to and from real hardware
      adc_out_p : out ir_rx_module_spi_out_type;
      adc_in_p  : in  ir_rx_module_spi_in_type;

      -- Raw values of last ADC conversions (two ADCs with six channels each)
      adc_values : out adc_ltc2351_values_type(11 downto 0);

      -- Extracted sync signal
      sync_p : out std_logic;

      -- signals to and from the internal parallel bus
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      -- Handshake interface to STM when new data is available
      done_p : out std_logic;
      ack_p  : in  std_logic;

      -- Sampling clock enable (expected to be 250 kHz)
      clk_sample_en : in std_logic;

      clk : in std_logic
      );

end ir_rx_module;

architecture structural of ir_rx_module is

   ----------------------------------------------------------------------------
   -- Internal signal declaration
   ----------------------------------------------------------------------------

   signal adc_start_s : std_logic := '0';
   signal adc_done_s : std_logic                       := '0';

begin  -- structural

   ----------------------------------------------------------------------------
   -- Connect components
   ----------------------------------------------------------------------------
   adc_start_s <= clk_sample_en;

   ----------------------------------------------------------------------------
   -- Component Instantiation
   ----------------------------------------------------------------------------

   -- Two ADCs
   adc_ltc2351_0 : adc_ltc2351
      port map (
         adc_out  => adc_out_p(0),
         adc_in   => adc_in_p(0),
         start_p  => adc_start_s,
         values_p => adc_values(5 downto 0),
         done_p   => adc_done_s,
         reset    => '0',
         clk      => clk);

   adc_ltc2351_1 : adc_ltc2351
      port map (
         adc_out  => adc_out_p(1),
         adc_in   => adc_in_p(1),
         start_p  => adc_start_s,
         values_p => adc_values(11 downto 6),
         done_p   => open,
         reset    => '0',
         clk      => clk);

   -- 12 Goertzel algorithms

   -- Sync extraction

end structural;
