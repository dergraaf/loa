-------------------------------------------------------------------------------
-- Title      : Testbench for design "uart_tx" and "uart_rx"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Fabian Greif
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.uart_pkg.all;

-------------------------------------------------------------------------------
entity uart_loopback_tb is
end entity uart_loopback_tb;

-------------------------------------------------------------------------------
architecture behavourial of uart_loopback_tb is

   -- component ports
   signal txd       : std_logic;
   signal data_out  : std_logic_vector(7 downto 0) := (others => '0');
   signal empty     : std_logic                    := '1';
   signal re        : std_logic;
   signal clk_tx_en : std_logic                    := '0';

   signal rxd       : std_logic := '1';
   signal data_recv   : std_logic_vector(7 downto 0);
   signal we        : std_logic;
   signal rx_error  : std_logic;
   signal full      : std_logic := '1';
   signal clk_rx_en : std_logic := '0';

   signal clk : std_logic := '0';
begin

   -- component instantiation
   dut_tx : entity work.uart_tx
      port map (
         txd_p     => txd,
         data_p    => data_out,
         empty_p   => empty,
         re_p      => re,
         clk_tx_en => clk_tx_en,
         clk       => clk);

   dut_rx : entity work.uart_rx
      port map (
         rxd_p     => rxd,
         deaf_in_p => '0',
         data_p    => data_recv,
         we_p      => we,
         error_p   => rx_error,
         full_p    => full,
         clk_rx_en => clk_rx_en,
         clk       => clk);

   rxd <= txd;

   -- clock generation
   clk <= not clk after 10 ns;

   -- Generate a bit clock
   bitclock : process
   begin
      wait until rising_edge(clk);
      clk_tx_en <= '1';
      wait until rising_edge(clk);
      clk_tx_en <= '0';
      wait for 60 ns;
   end process bitclock;

   clk_rx_en <= '1';

   -- waveform generation
   waveform : process
   begin
      wait until rising_edge(clk);

      empty    <= '0';
      data_out <= "00000000";           -- partiy = 1
      wait until falling_edge(re);
      data_out <= "11001010";           -- partiy = 1
      wait until falling_edge(re);
      data_out <= "00001011";           -- partiy = 0
      wait until falling_edge(re);
      empty    <= '1';

      wait for 2 us;

      empty    <= '0';
      data_out <= "11100101";           -- partiy = 0
      wait until falling_edge(re);
      data_out <= "11100100";           -- partiy = 1
      wait until falling_edge(re);
      empty    <= '1';

      wait;
      
   end process waveform;

end architecture behavourial;
