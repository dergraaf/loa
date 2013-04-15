-------------------------------------------------------------------------------
-- Title      : Testbench for design "uart_rx"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif
-- Standard   : VHDL'x
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.uart_pkg.all;
use work.uart_tb_pkg.all;

-------------------------------------------------------------------------------
entity uart_rx_tb is
end entity uart_rx_tb;

-------------------------------------------------------------------------------
architecture behavourial of uart_rx_tb is

   -- component ports
   signal rxd       : std_logic := '1';
   signal disable : std_logic := '0';
   signal data      : std_logic_vector(7 downto 0);
   signal we        : std_logic;
   signal rx_error  : std_logic;
   signal full      : std_logic := '1';
   signal clk_rx_en : std_logic := '0';
   signal clk       : std_logic := '0';
   
begin

   -- component instantiation
   dut : entity work.uart_rx
      port map (
         rxd_p     => rxd,
         disable_p => disable,
         data_p    => data,
         we_p      => we,
         error_p   => rx_error,
         full_p    => full,
         clk_rx_en => clk_rx_en,
         clk       => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- Generate a bit clock
   bitclock : process
   begin
      clk_rx_en <= '1';
      wait until rising_edge(clk);
--      clk_rx_en <= '1';
--      wait until rising_edge(clk);
--      clk_rx_en <= '0';
--      wait for 40 ns;
   end process bitclock;

   -- waveform generation
   waveform : process
   begin
      wait until rising_edge(clk);

      -- glitch
      rxd <= '0';
      wait until rising_edge(clk);
      rxd <= '1';
      wait for 100 ns;

      -- correct transmission
      uart_transmit(rxd, "001111100", 10000000);
      --wait for 200 ns;

      -- check slightly off baudrates
      uart_transmit(rxd, "001111100", 10500000);
      --wait for 200 ns;
      uart_transmit(rxd, "001111100",  9700000);
      --wait for 200 ns;

      -- send a wrong parity bit
      uart_transmit(rxd, "101111100", 10000000);
      wait for 200 ns;
      
      wait;
      
   end process waveform;

end architecture behavourial;
