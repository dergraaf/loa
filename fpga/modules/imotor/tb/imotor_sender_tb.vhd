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
   signal clock_tx_s      : std_logic := '0';

   signal imotor_input_s : imotor_input_type(1 downto 0) := (x"0403", x"0201");

   signal data_tx_s : std_logic_vector(7 downto 0);
   
   signal start_tx_s : std_logic;
   signal busy_tx_s  : std_logic;
   signal txd_out_s  : std_logic;

begin  -- architecture behavourial

   -- component instantiation

   imotor_sender_1 : entity work.imotor_sender
      generic map (
         DATA_WORDS => 2,
         DATA_WIDTH => 8)
      port map (
         data_in_p   => imotor_input_s,
         data_out_p  => data_tx_s,
         start_out_p => start_tx_s,
         busy_in_p   => busy_tx_s,
         start_in_p  => start_message_s,
         clk         => clk);

   imotor_timer_1 : imotor_timer
      generic map (
         CLOCK          => 50E6,
         BAUD           => 10E6,
         SEND_FREQUENCY => 1E5)
      port map (
         clock_tx_out_p   => clock_tx_s,
         clock_send_out_p => start_message_s,
         clk              => clk);

   imotor_uart_tx_1 : entity work.imotor_uart_tx
      generic map (
         START_BITS => 1,
         DATA_BITS  => 8,
         STOP_BITS  => 1,
         PARITY     => None)
      port map (
         data_in_p     => data_tx_s,
         start_in_p    => start_tx_s,
         busy_out_p    => busy_tx_s,
         txd_out_p     => txd_out_s,
         clock_tx_in_p => clock_tx_s,
         clk           => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';

      wait until false;

   end process WaveGen_Proc;

end architecture behavourial;
