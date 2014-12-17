-------------------------------------------------------------------------------
-- Title      : IR Canon Controller Configuration Package
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-14
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

package ir_canon_cfg_pkg is

  -- literal values are for 50MHz system clock
  constant carrier_cycles  : integer := 767;    -- 0.5 * 1/32.6 kHz 
  constant gap_cycles      : integer := 366500;  -- 7.33 ms
  constant hold_off_cycles : integer := 25000000;

end ir_canon_cfg_pkg;


