-------------------------------------------------------------------------------
-- Title      : Testbench for design "uart_tx"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif
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
entity uart_tx_tb is
end entity uart_tx_tb;

-------------------------------------------------------------------------------
architecture behavourial of uart_tx_tb is

   -- component ports
   signal txd       : std_logic;
   signal busy : std_logic;
   signal data      : std_logic_vector(7 downto 0) := (others => '0');
   signal empty     : std_logic                    := '1';
   signal re        : std_logic;
   signal clk_tx_en : std_logic                    := '0';
   signal clk       : std_logic                    := '0';
begin

   -- component instantiation
   dut : entity work.uart_tx
      port map (
         txd_p     => txd,
         busy_p    => busy,
         data_p    => data,
         empty_p   => empty,
         re_p      => re,
         clk_tx_en => clk_tx_en,
         clk       => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- Generate a bit clock
   bitclock : process
   begin
      wait until rising_edge(clk);
      clk_tx_en <= '1';
      wait until rising_edge(clk);
      clk_tx_en <= '0';
      wait for 40 ns;
   end process bitclock;

   -- waveform generation
   waveform : process
   begin
      wait until rising_edge(clk);

      empty <= '0';
      data  <= "00000000";              -- partiy = 1
      wait until falling_edge(re);
      data  <= "11001010";              -- partiy = 1
      wait until falling_edge(re);
      data  <= "00001011";              -- partiy = 0
      wait until falling_edge(re);
      empty <= '1';

      wait for 2 us;

      empty <= '0';
      data  <= "11100101";              -- partiy = 0
      wait until falling_edge(re);
      data  <= "11100100";              -- partiy = 1
      wait until falling_edge(re);
      empty <= '1';

      wait;
      
   end process waveform;

end architecture behavourial;
