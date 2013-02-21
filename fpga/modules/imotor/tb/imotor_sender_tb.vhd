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

   signal start_message_s : std_logic := '0';
   signal clock_tx        : std_logic := '0';

   signal imotor_input_s : imotor_input_type(1 downto 0) := ("0000000011111111", "1111111100000000");

begin  -- architecture behavourial

   -- component instantiation

   imotor_sender_1 : entity work.imotor_sender
      generic map (
         DATA_WORDS => 2,
         DATA_WIDTH => 8)
      port map (
         data_in_p  => imotor_input_s,
--         data_out_p  => data_out_p,
-- start_out_p => start_out_p,
         busy_in_p  => '0',
         start_in_p => start_message_s,
         clk        => clk);

   imotor_timer_1 : imotor_timer
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
      start_message_s <= '1';
      wait until clk = '1';
      start_message_s <= '0';

      wait for 10 us;
      start_message_s <= '1';

      wait until false;

   end process WaveGen_Proc;

end architecture behavourial;
