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

package onewire_pkg is

  type onewire_out_type is record
    d    : std_logic_vector(7 downto 0);
    busy : std_logic;
    err  : std_logic;
  end record;

  type onewire_in_type is record
    d         : std_logic_vector(7 downto 0);
    re        : std_logic;
    we        : std_logic;
    reset_bus : std_logic;
  end record;

  type onewire_bus_out_type is record
    d         : std_logic;
    en_driver : std_logic;
  end record;

  type onewire_bus_in_type is record
    d : std_logic;
  end record;

  component onewire
    port (
      onewire_in      : in  onewire_in_type;
      onewire_out     : out onewire_out_type;
      onewire_bus_in  : in  onewire_bus_in_type;
      onewire_bus_out : out onewire_bus_out_type;
      clk             : in  std_logic);
  end component;
  
end onewire_pkg;


