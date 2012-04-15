-------------------------------------------------------------------------------
-- Title      : Package for Infrared transmitter
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_tx_pkg.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-13
-- Last update: 2012-04-14
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

library work;
use work.motor_control_pkg.all;
use work.bus_pkg.all;

package ir_tx_pkg is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component ir_tx_module
    generic (
      BASE_ADDRESS : integer range 0 to 32767);
    port (
      ir_tx_p          : out std_logic;
      modulation_p     : in  std_logic;
      clk_ir_enable_p  : out std_logic;
      bus_o            : out busdevice_out_type;
      bus_i            : in  busdevice_in_type;
      clk              : in  std_logic);
  end component;

end ir_tx_pkg;
