-------------------------------------------------------------------------------
-- Title      : Toplevel to test the WS2812 on a Nexys2 Board
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
--
--  JD1 (upper right corner, view at mating face)
--
--             UP
--  *---*---*---*---*---*---* 
--  |VCC|GND|   |   |   |DAT|
--  *---*---*---*---*---*---*
--  |VCC|GND|   |   |   |   |
--  *---*---*---*---*---*---*
--            PCB
--
--  Tested with 5V and 3.3V.
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
use work.ws2812_pkg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
  port(
    sw  : in  std_logic_vector(1 downto 0);
    o   : out std_logic;
    clk : in  std_logic                 -- 50MHz
    );
end toplevel;

architecture Behavioral of toplevel is
  
  signal ws2812_in        : ws2812_in_type;
  signal ws2812_out       : ws2812_out_type;
  signal ws2812_chain_out : ws2812_chain_out_type;

  signal pixels : ws2812_8x1_in_type := (pixel   =>
                                         (0      => x"111111",
                                          1      => x"110000",
                                          2      => x"111111",
                                          3      => x"001100",
                                          4      => x"111111",
                                          5      => x"000011",
                                          6      => x"111111",
                                          7      => x"050505"),
                                         refresh => '1');

begin
  -----------------------------------------------------------------------------
  -- Output driver
  -----------------------------------------------------------------------------
  o <= ws2812_chain_out.d;

  -----------------------------------------------------------------------------
  -- Choose Color with SW0 & SW1
  -- GGRRBB
  ----------------------------------------------------------------------------
  pixels.pixel(2) <= x"ff0000" when sw(0) = '0' else x"00ff00";
  pixels.pixel(7) <= x"ff0000" when sw(1) = '0' else x"0000ff";

  -----------------------------------------------------------------------------
  -- WS2812 Controller
  -----------------------------------------------------------------------------
  controller_8x1 : ws2812_8x1
    port map (
      pixels     => pixels,
      ws2812_in  => ws2812_in,
      ws2812_out => ws2812_out,
      clk        => clk);

  ws2812_1 : ws2812
    port map (
      ws2812_in        => ws2812_in,
      ws2812_out       => ws2812_out,
      ws2812_chain_out => ws2812_chain_out,
      clk              => clk);

end Behavioral;

