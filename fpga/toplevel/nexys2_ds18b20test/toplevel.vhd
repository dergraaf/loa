-------------------------------------------------------------------------------
-- Title      : Toplevel to test the DS18b20 Reader on a Nexys2 Board
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- SW0 - Enables the temperature aquisition
-- SW1 - Toggles between the display of the two lower, of the two upper nibbles 
--       of the read value.
--
--  JA1 (upper left corner, view at mating face)
--
--             UP
--  *---*---*---*---*---*---* 
--  |VCC|GND|   |   |   | OW|
--  *---*---*---*---*---*---*
--  |VCC|GND|   |   |   |   |
--  *---*---*---*---*---*---*
--            PCB
--
--    Onwire bus needs external Pull-Up, 4k7 recommended by datasheet.
--
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

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library work;
use work.onewire_pkg.all;
use work.ds18b20_pkg.all;


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
  port(
    led : out   std_logic_vector(7 downto 0);
    sw  : in    std_logic_vector(1 downto 0);
    ow  : inout std_logic;
    clk : in    std_logic               -- 50MHz
    );
end toplevel;

architecture Behavioral of toplevel is
  
  signal ow_out      : onewire_out_type;
  signal ow_in       : onewire_in_type;
  signal ds18b20_in  : ds18b20_in_type;
  signal ds18b20_out : ds18b20_out_type;

  signal onewire_bus_in  : onewire_bus_in_type;
  signal onewire_bus_out : onewire_bus_out_type;

  
begin
  -----------------------------------------------------------------------------
  -- tristate driver
  -----------------------------------------------------------------------------
  onewire_bus_in.d <= ow;
  ow               <= '0' when onewire_bus_out.en_driver = '1' else 'Z';
  --ow <= onewire_bus_out.d when onewire_bus_out.en_driver = '1' else 'Z';

  -----------------------------------------------------------------------------
  -- outuput lower bits of temperature reading to leds
  -- sw1 shifts the reading by 4 bit.
  -----------------------------------------------------------------------------
  process(ds18b20_out, sw)
  begin
    if sw(1) = '0' then
      led <= ds18b20_out.value(7 downto 0);
    else
      led <= ds18b20_out.value(11 downto 4);
    end if;
  end process;
  -----------------------------------------------------------------------------
  -- enable system with switch 0
  -----------------------------------------------------------------------------
  ds18b20_in.refresh <= sw(0);

  onewire_1 : onewire
    port map (
      onewire_in      => ow_in,
      onewire_out     => ow_out,
      onewire_bus_in  => onewire_bus_in,
      onewire_bus_out => onewire_bus_out,
      clk             => clk);

  ds18b20_1 : ds18b20
    port map (
      ow_out      => ow_out,
      ow_in       => ow_in,
      ds18b20_in  => ds18b20_in,
      ds18b20_out => ds18b20_out,
      clk         => clk);

end Behavioral;

