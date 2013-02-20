-------------------------------------------------------------------------------
-- Title      : Testbench for design "imotor_sender"
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_sender_tb is
end entity imotor_sender_tb;

-------------------------------------------------------------------------------

architecture behavourial of imotor_sender_tb is

   -- component generics

   -- Component ports

   -- clock
   signal clk : std_logic := '1';

   signal start : std_logic := '0';
   signal clock_tx : std_logic := '0';

begin  -- architecture behavourial

   -- component instantiation
   imotor_timer : entity work.imotor_timer
      generic map (
         CLOCK          => 50E6,
         BAUD           => 1E6,
         SEND_FREQUENCY => 1E3)
      port map (
         clock_tx_out_p => clock_tx,
         clk            => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';
      wait for 0.5 us;
      start <= '1';
      wait until clk = '1';
      start <= '0';

      wait for 10 us;
      start <= '1';

      wait until false;
      
   end process WaveGen_Proc;

end architecture behavourial;
