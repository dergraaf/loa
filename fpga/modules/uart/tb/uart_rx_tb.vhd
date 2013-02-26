-------------------------------------------------------------------------------
-- Title      : Testbench for design "uart_rx"
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

library work;
use work.uart_pkg.all;

-------------------------------------------------------------------------------
entity uart_rx_tb is
end entity uart_rx_tb;

-------------------------------------------------------------------------------
architecture behavourial of uart_rx_tb is

   -- component ports
   signal rxd       : std_logic := '1';
   signal data      : std_logic_vector(7 downto 0);
   signal we        : std_logic;
   signal error     : std_logic;
   signal full      : std_logic := '1';
   signal clk_rx_en : std_logic := '0';
   signal clk       : std_logic := '0';
begin

   -- component instantiation
   dut : entity work.uart_rx
      port map (
         rxd_p     => rxd,
         data_p    => data,
         we_p      => we,
         error_p   => error,
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

      -- start
      rxd <= '0';
      wait for 100 ns;
      -- bit 0
      rxd <= '0';
      wait for 100 ns;
      -- bit 1
      rxd <= '0';
      wait for 100 ns;
      -- bit 2
      rxd <= '1';
      wait for 100 ns;
      -- bit 3
      rxd <= '1';
      wait for 100 ns;
      -- bit 4
      rxd <= '1';
      wait for 100 ns;
      -- bit 5
      rxd <= '1';
      wait for 100 ns;
      -- bit 6
      rxd <= '1';
      wait for 100 ns;
      -- bit 7
      rxd <= '0';
      wait for 100 ns;
      -- parity
      rxd <= '0';
      wait for 100 ns;
      -- end
      rxd <= '1';
      wait for 100 ns;
      wait;
      
   end process waveform;

end architecture behavourial;
