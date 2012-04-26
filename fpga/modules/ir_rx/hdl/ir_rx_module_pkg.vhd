-------------------------------------------------------------------------------
-- Title      : Infrared Receiver Package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_pkg.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-15
-- Last update: 2012-04-26
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bus_pkg.all;
use work.adc_ltc2351_pkg.all;

-------------------------------------------------------------------------------

package ir_rx_module_pkg is

   type ir_rx_module_spi_out_type is array (1 downto 0) of adc_ltc2351_spi_out_type;
   type ir_rx_module_spi_in_type is array (1 downto 0) of adc_ltc2351_spi_in_type;
   
   component ir_rx_module is
      generic (
         BASE_ADDRESS_COEFS   : integer range 0 to 32767;
         BASE_ADDRESS_RESULTS : integer range 0 to 32767);
      port (
         adc_out_p     : out ir_rx_module_spi_out_type;
         adc_in_p      : in  ir_rx_module_spi_in_type;
         adc_values_p  : out adc_ltc2351_values_type(11 downto 0);
         sync_p        : out std_logic;
         bus_o         : out busdevice_out_type;
         bus_i         : in  busdevice_in_type;
         done_p        : out std_logic;
         ack_p         : in  std_logic;
         clk_sample_en : in  std_logic;
         clk           : in  std_logic);
   end component ir_rx_module;
   
end ir_rx_module_pkg;
