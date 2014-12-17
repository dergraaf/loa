-------------------------------------------------------------------------------
-- Title      : IR Remote Shutter release for Canon DSLR - Controller Package
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-16
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

package ir_canon_pkg is

  type ir_canon_out_type is record
    ired : std_logic;
    busy : std_logic;
  end record;

  type ir_canon_in_type is record
    trigger : std_logic;
  end record;

  component ir_canon
    port (
      ir_canon_in  : in  ir_canon_in_type;
      ir_canon_out : out ir_canon_out_type;
      clk          : in  std_logic);
  end component;
  
end ir_canon_pkg;


