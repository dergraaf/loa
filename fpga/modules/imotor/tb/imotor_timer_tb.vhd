-------------------------------------------------------------------------------
-- Title      : Testbench for design "entity_name"
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity imotor_timer_tb is

end entity imotor_timer_tb;

-------------------------------------------------------------------------------

architecture behavourial of imotor_timer_tb is

   -- component generics
   constant PARAM : natural := 42;

   -- component ports

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture behavourial

   -- component instantiation
   DUT : entity work.imotor_timer
      generic map (
         CLOCK          => 50E6,
         BAUD           => 1E6,
         SEND_FREQUENCY => 1E3)
      port map (
         clk => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here
      
      wait until clk = '1';
   end process WaveGen_Proc;

end architecture behavourial;
