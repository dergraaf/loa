-------------------------------------------------------------------------------
-- Title      : Ultrasound Receiver Package
-- Project    : 
-------------------------------------------------------------------------------
-- File       : us_rx_module_pkg.vhd
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bus_pkg.all;
use work.adc_ltc2351_pkg.all;

-------------------------------------------------------------------------------

package us_rx_module_pkg is

   component us_rx_module is
      generic (
         BASE_ADDRESS : integer range 0 to 16#7FFF#);
      port (
         bus_o_p           : out busdevice_out_type;
         bus_i_p           : in  busdevice_in_type;
         clk_sample_en_i_p : in  std_logic;
         timestamp_i_p     : in  timestamp_type;
         clk               : in  std_logic);
   end component us_rx_module;
   
end package us_rx_module_pkg;
