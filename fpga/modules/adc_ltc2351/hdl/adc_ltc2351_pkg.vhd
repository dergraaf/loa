-------------------------------------------------------------------------------
-- Title      : Components package 
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : 
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-10
-- Last update: 2012-04-18
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bus_pkg.all;

-------------------------------------------------------------------------------

package adc_ltc2351_pkg is

   -- The LTC2351 is a 14-bit ADC
   type adc_ltc2351_values_type is array (natural range <>) of std_logic_vector(13 downto 0);

   -- The LTC2351 is configured by port pins, no real SPI
   type adc_ltc2351_spi_out_type is record
      conv : std_logic;
      sck  : std_logic;
   end record;

   -- The LTC2351 outputs it's data on a single pin, no real SPI
   type adc_ltc2351_spi_in_type is record
      sdo : std_logic;
   end record;

   -- ---------------------------------------------------------------------------
   -- Component declarations
   -- ---------------------------------------------------------------------------
   component adc_ltc2351
      port (
         -- signal to and from real hardware
         adc_out : out adc_ltc2351_spi_out_type;
         adc_in  : in  adc_ltc2351_spi_in_type;

         -- signals to other logic in FPGA
         start_p  : in  std_logic;
         values_p : out adc_ltc2351_values_type(5 downto 0);
         done_p   : out std_logic;

         -- reset and clock
         reset : in std_logic;
         clk   : in std_logic
         );
   end component;

   component adc_ltc2351_model
-- this overwrites the init from adc_ltc2351_model.vhd
--     generic (
--        DATA_CH1 : std_logic_vector(13 downto 0);
--        DATA_CH2 : std_logic_vector(13 downto 0);
--        DATA_CH3 : std_logic_vector(13 downto 0);
--        DATA_CH4 : std_logic_vector(13 downto 0);
--        DATA_CH5 : std_logic_vector(13 downto 0);
--        DATA_CH6 : std_logic_vector(13 downto 0));
      port (
         sck  : in  std_logic;
         conv : in  std_logic;
         sdo  : out std_logic := 'Z');
   end component;

   component adc_ltc2351_module
      generic (
         BASE_ADDRESS : integer range 0 to 32767);
      port (
         adc_out_p    : out adc_ltc2351_spi_out_type;
         adc_in_p     : in  adc_ltc2351_spi_in_type;
         bus_o        : out busdevice_out_type;
         bus_i        : in  busdevice_in_type;
         adc_values_o : out adc_ltc2351_values_type(5 downto 0);
         done_p       : out std_logic;
         reset        : in  std_logic;
         clk          : in  std_logic);
   end component;

end adc_ltc2351_pkg;

-------------------------------------------------------------------------------
