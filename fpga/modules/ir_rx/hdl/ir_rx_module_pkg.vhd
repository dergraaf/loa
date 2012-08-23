-------------------------------------------------------------------------------
-- Title      : Infrared Receiver Package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_pkg.vhd
-- Author     : strongly-typed
-- Created    : 2012-04-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bus_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

package ir_rx_module_pkg is

   type ir_rx_module_spi_out_type is array (1 downto 0) of adc_ltc2351_spi_out_type;
   type ir_rx_module_spi_in_type is array (1 downto 0) of adc_ltc2351_spi_in_type;

   component ir_rx_module is
      generic (
         BASE_ADDRESS_COEFS     : integer range 0 to 32767;
         BASE_ADDRESS_RESULTS   : integer range 0 to 32767;
         BASE_ADDRESS_TIMESTAMP : integer range 0 to 32767);
      port (
         adc_o_p           : out ir_rx_module_spi_out_type;
         adc_i_p           : in  ir_rx_module_spi_in_type;
         adc_values_o_p    : out adc_ltc2351_values_type(11 downto 0);
         sync_o_p          : out std_logic;
         bus_o_p           : out busdevice_out_type;
         bus_i_p           : in  busdevice_in_type;
         done_o_p          : out std_logic;
         ack_i_p           : in  std_logic;
         clk_sample_en_i_p : in  std_logic;
         timestamp_i_p     : in  timestamp_type;
         clk               : in  std_logic);
   end component ir_rx_module;

   component ir_rx_adcs
      generic (
         CHANNELS : positive);
      port (
         clk_sample_en_i_p : in  std_logic;
         adc_o_p           : out ir_rx_module_spi_out_type;
         adc_i_p           : in  ir_rx_module_spi_in_type;
         adc_values_o_p    : out adc_ltc2351_values_type;
         adc_done_o_p      : out std_logic;
         clk               : in  std_logic);
   end component;

end ir_rx_module_pkg;
