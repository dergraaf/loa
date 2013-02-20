-------------------------------------------------------------------------------
-- Title      : Testbench for design "imotor_uart_tx"
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

entity imotor_uart_tx_tb is

end entity imotor_uart_tx_tb;

-------------------------------------------------------------------------------

architecture behavourial of imotor_uart_tx_tb is

   -- component generics

   -- component ports

   -- clock
   signal clk : std_logic := '1';

   signal start    : std_logic := '0';  -- Start signal for transmission
   signal clock_tx : std_logic := '0';  -- Bit clock transmitter
   

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

   
   DUT : entity work.imotor_uart_tx
      generic map (
         START_BITS => 1,
         DATA_BITS  => 8,
         STOP_BITS  => 1,
         PARITY     => Odd)
      port map (
         data_in_p     => "00101100",
         start_in_p    => start,
         clock_tx_in_p => clock_tx,
         clk           => clk);

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
