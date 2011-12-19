-------------------------------------------------------------------------------
-- Title      : Testbench for design "peripheral_register"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : peripheral_register_tb.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2011-10-26
-- Last update: 2011-12-19
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-10-26  1.0      calle   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.peripheral_register_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity peripheral_register_tb is
end peripheral_register_tb;

-------------------------------------------------------------------------------
architecture tb of peripheral_register_tb is

   -- component generics
   constant BASE_ADDRESS : positive := 16#0100#;

   -- component ports
   signal reg : std_logic_vector(15 downto 0) := (others => '0');
   
   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type :=
      (addr => (others => '0'),
       data => (others => '0'),
       we   => '0',
       re   => '0');
   signal reset : std_logic := '1';
   signal clk   : std_logic := '0';

begin
   -- component instantiation
   DUT : peripheral_register
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         dout_p    => reg,
         din_p     => reg,
         bus_o     => bus_o,
         bus_i     => bus_i,
         reset     => reset,
         clk       => clk);

   -- clock generation
   clk <= not clk after 10 NS;

   -- reset generation
   reset <= '1', '0' after 50 NS;

   waveform : process
   begin
      wait until falling_edge(reset);
      wait for 20 NS;
      
      -- wrong address
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0020", bus_i.addr'length)));
      bus_i.data <= x"1234";
      bus_i.re   <= '1';
      wait until rising_edge(clk);
      bus_i.re   <= '0';

      wait for 30 NS;
      
      -- correct address
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
      bus_i.re   <= '1';
      wait until rising_edge(clk);
      bus_i.re   <= '0';

      wait for 30 NS;

      wait until rising_edge(clk);
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';
      wait until rising_edge(clk);
      
      -- generate two read cycles directly following each other
      bus_i.re <= '1';
      wait until rising_edge(clk);
      wait until rising_edge(clk);
      bus_i.re <= '0';

      wait until rising_edge(clk);
      bus_i.data <= x"4321";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait until rising_edge(clk);
      bus_i.re   <= '1';
      wait until rising_edge(clk);
      bus_i.re   <= '0';

      
   end process waveform;
end tb;
