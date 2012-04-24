-------------------------------------------------------------------------------
-- Title      : Edge Detect
-- Project    : 
-------------------------------------------------------------------------------
-- File       : edge_detect.vhd
-- Author     : Lothar Miller
-- Company    : 
-- Created    : 2012-04-23
-- Last update: 2012-04-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: See http://www.lothar-miller.de/s9y/categories/18-Flankenerkennung
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity edge_detect is
   port (async_sig : in  std_logic;
         clk       : in  std_logic;
         rise      : out std_logic;
         fall      : out std_logic);
end;

architecture RTL of edge_detect is
begin
   process
      variable sr : std_logic_vector (3 downto 0) := "0000";
   begin
      wait until rising_edge(clk);
      -- detect edge
      rise <= not sr(3) and sr(2);
      fall <= not sr(2) and sr(3);
      -- read input into shift register
      sr   := sr(2 downto 0) & async_sig;
   end process;
end architecture;
