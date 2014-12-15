-------------------------------------------------------------------------------
-- Title      : Onewire Master Configuration Package
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-13
-------------------------------------------------------------------------------
-- Copyright (c) 2014, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.onewire_pkg.all;

package onewire_cfg_pkg is
  -- Onewire bus timing, taken from DS18B20 datasheet
  -- literal values are for 50MHz system clock
  constant bus_reset_cycles : integer := 24000;
  constant bus_reset_wait_for_response : integer := 4500;

  constant bus_write_zero : integer := 4000;
  constant bus_write_zero_gap : integer := 1000;

  constant bus_write_one : integer := 100;
  constant bus_write_one_gap : integer := 4900;

  constant bus_read_pulse : integer := 100;
  constant bus_read_delay : integer := 550;
  constant bus_read_gap : integer := 4350;

  -- fine xst doesn't support physical constants 
  --constant clk_period       : time    := 20 ns;
  --constant bus_reset_cycles : integer := 480 us / clk_period;
  --constant bus_reset_wait_for_response : integer := 90 us / clk_period;

  --constant bus_write_zero : integer := 80 us / clk_period;
  --constant bus_write_zero_gap : integer := 20 us / clk_period;

  --constant bus_write_one : integer := 2 us / clk_period;
  --constant bus_write_one_gap : integer := 98 us / clk_period;

  --constant bus_read_pulse : integer := 2 us / clk_period;
  --constant bus_read_delay : integer := 11 us / clk_period;
  --constant bus_read_gap : integer := 87 us / clk_period;
end onewire_cfg_pkg;


