-------------------------------------------------------------------------------
-- Title      : Testbench for design "uart"
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
entity uart_tb is
end entity uart_tb;

-------------------------------------------------------------------------------
architecture behavourial of uart_tb is

   -- component ports
   signal txd : std_logic := '1';
   signal rxd : std_logic := '1';
   signal rxd_combined : std_logic := '1';

   signal din  : std_logic_vector(7 downto 0) := (others => '0');
   signal dout : std_logic_vector(7 downto 0) := (others => '0');

   signal empty  : std_logic := '1';
   signal re     : std_logic := '0';
   signal we     : std_logic := '0';
   signal error  : std_logic := '0';
   signal full   : std_logic := '0';
   signal clk_en : std_logic := '0';
   signal clk    : std_logic := '0';
   
begin
   rxd_combined <= rxd and txd;
   
   -- component instantiation
   dut : uart
      port map (
         txd_p   => txd,
         rxd_p   => rxd_combined,
         din_p   => din,
         empty_p => empty,
         re_p    => re,
         dout_p  => dout,
         we_p    => we,
         error_p => error,
         full_p  => full,
         clk_en  => clk_en,
         clk     => clk);
   
   -- clock generation
   clk <= not clk after 10 ns;

   -- Generate a bit clock
   bitclock : process
   begin
      wait until rising_edge(clk);
      clk_en <= '1';
      wait until rising_edge(clk);
      clk_en <= '0';
   end process bitclock;

   -- waveform generation
   waveform : process
   begin
      wait until rising_edge(clk);

      -- transmission from extern
      uart_transmit(rxd, "001111100", 5000000);
      wait for 10 us;
      uart_transmit(rxd, "101011100", 5000000);
      wait for 1 us;
      uart_transmit(rxd, "101011101", 5000000);
      
      wait;
   end process waveform;

   fifo : process
   begin
      wait for 3 us;

      empty <= '0';
      din  <= "00000000";
      wait until falling_edge(re);
      din  <= "11001010";
      wait until falling_edge(re);
      din  <= "00001011";
      wait until falling_edge(re);
      empty <= '1';

      wait for 2 us;
      
      wait;
   end process fifo;

end architecture behavourial;
