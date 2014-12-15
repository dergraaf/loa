-------------------------------------------------------------------------------
-- Title      : DS18b20 Reader Package
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

library work;
use work.onewire_pkg.all;

package ds18b20_pkg is

  type ds18b20_out_type is record
    value  : std_logic_vector(15 downto 0);
    update : std_logic;
    err    : std_logic;
  end record;

  type ds18b20_in_type is record
    refresh : std_logic;
  end record;

  component ds18b20
    port (
      ow_out : in  onewire_out_type;
      ow_in  : out onewire_in_type;

      ds18b20_in  : in  ds18b20_in_type;
      ds18b20_out : out ds18b20_out_type;

      clk : in std_logic);
  end component;
  
end ds18b20_pkg;
