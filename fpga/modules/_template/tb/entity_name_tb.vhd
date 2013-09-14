-------------------------------------------------------------------------------
-- Title      : Title String Testbench
-------------------------------------------------------------------------------
-- Author     : AUTHOR
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013, AUTHOR
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity entity_name_tb is

end entity entity_name_tb;

-------------------------------------------------------------------------------

architecture behavourial of entity_name_tb is

   -- component generics
   constant PARAM : natural := 42;

   -- component ports

   -- clock
   signal Clk : std_logic := '1';

begin  -- architecture behavourial

   -- component instantiation
   DUT: entity work.entity_name
      generic map (
         PARAM => PARAM)
      port map (
         clk => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc: process
   begin
      -- insert signal assignments here
      
      wait until Clk = '1';
   end process WaveGen_Proc;

end architecture behavourial;
