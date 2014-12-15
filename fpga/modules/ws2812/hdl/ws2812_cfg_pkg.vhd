-------------------------------------------------------------------------------
-- Title      : WS2812 Controller Configuration Package
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

package ws2812_cfg_pkg is

  -- literal values are for 50MHz system clock

  constant reset_cycles : integer := 2750; -- 55 us

  constant one_th_cycles : integer := 35; -- 700ns
  constant one_tl_cycles : integer := 30; -- 600ns

  constant zero_th_cycles : integer := 18; -- 350ns (360ns)
  constant zero_tl_cycles : integer := 40; -- 800ns

end ws2812_cfg_pkg;


