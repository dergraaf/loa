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

begin  -- architecture behavourial

   -- component instantiation
   DUT: entity work.imotor_uart_tx
      generic map (
         START_BITS => 1,
         DATA_BITS  => 8,
         STOP_BITS  => 2,
         PARITY => None)
      port map (
         clk => clk);
   
   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc: process
   begin
      -- insert signal assignments here
      
      wait until clk = '1';
   end process WaveGen_Proc;

end architecture behavourial;
