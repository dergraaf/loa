-------------------------------------------------------------------------------
-- Title      : Toplevel to test "ir_canon" on a Nexys2 Board
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
--
--  JD1 (upper right corner, view at mating face)
--
--             UP
--  *---*---*---*---*---*---* 
--  |VCC|GND|   |   |   |OUT|
--  *---*---*---*---*---*---*
--  |VCC|GND|   |   |   |   |
--  *---*---*---*---*---*---*
--            PCB
--
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
use work.ir_canon_pkg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel is
  port(
    btn  : in  std_logic;
    o   : out std_logic;
    clk : in  std_logic                 -- 50MHz
    );
end toplevel;

architecture Behavioral of toplevel is
  
  signal ir_canon_in  : ir_canon_in_type;
  signal ir_canon_out : ir_canon_out_type;

  signal btn_sync : std_logic_vector(1 downto 0) := "00";

begin
  -----------------------------------------------------------------------------
  -- Output driver
  -----------------------------------------------------------------------------
  o <= ir_canon_out.ired;

  ir_canon_in.trigger <= btn_sync(1);

  process(clk)
  begin
    if rising_edge(clk) then
      btn_sync <= btn_sync(0) & btn;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- IR_CANON Controller
  -----------------------------------------------------------------------------
  ir_canon_1 : ir_canon
    port map (
      ir_canon_in  => ir_canon_in,
      ir_canon_out => ir_canon_out,
      clk          => clk);

end Behavioral;

