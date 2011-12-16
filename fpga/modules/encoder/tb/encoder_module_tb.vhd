-------------------------------------------------------------------------------
-- Title      : Testbench for design "encoder_module"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : encoder_module_tb.vhd
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : 
-- Created    : 2011-12-16
-- Last update: 2011-12-16
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-12-16  1.0      fabian  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.encoder_module_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity encoder_module_tb is
end encoder_module_tb;

-------------------------------------------------------------------------------
architecture tb of encoder_module_tb is

  -- component generics
  constant BASE_ADDRESS : positive := 16#0100#;

  -- component ports
  signal a     : std_logic := '0';
  signal b     : std_logic := '0';
  signal index : std_logic := '0';
  signal load  : std_logic := '0';
  
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
  DUT: encoder_module
    generic map (
      BASE_ADDRESS => BASE_ADDRESS)
    port map (
      a_p     => a,
      b_p     => b,
      index_p => index,
      load_p  => load,
      bus_o   => bus_o,
      bus_i   => bus_i,
      reset   => reset,
      clk     => clk);
 
  -- clock generation
  clk <= not clk after 10 ns;

  -- reset generation
  reset <= '1', '0' after 50 ns;

  waveform : process
  begin
    wait until falling_edge(reset);
    wait for 20 ns;

    for i in 1 to 3 loop
      wait until rising_edge(clk);
      a <= '1';
      wait until rising_edge(clk);
      b <= '1';
      wait until rising_edge(clk);
      a <= '0';
      wait until rising_edge(clk);
      b <= '0';
      wait until rising_edge(clk);
    end loop;  -- i

    wait for 50 ns;
    
    -- wrong address
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(unsigned'(resize(x"0020", bus_i.addr'length)));
    bus_i.data <= x"0000";
    bus_i.re   <= '1';
    wait until rising_edge(clk);
    bus_i.re   <= '0';

    wait for 30 ns;

    -- correct address
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
    bus_i.data <= x"0000";
    bus_i.re   <= '1';
    wait until rising_edge(clk);
    bus_i.re   <= '0';

    wait for 30 ns;

    wait until rising_edge(clk);
    load <= '1';
    wait until rising_edge(clk);
    load <= '0';
    
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
    bus_i.data <= x"0000";
    bus_i.re   <= '1';
    wait until rising_edge(clk);
    bus_i.re   <= '0';
    wait until rising_edge(clk);

    -- generate two read cycles directly following each other
    bus_i.re   <= '1';
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    bus_i.re   <= '0';
    
    -- wrong address
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(unsigned'(resize(x"0110", bus_i.addr'length)));
    bus_i.data <= x"0000";
    bus_i.re   <= '1';
    wait until rising_edge(clk);
    bus_i.re   <= '0';
    
  end process waveform;
end tb;