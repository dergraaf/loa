-------------------------------------------------------------------------------
-- Title      : Testbench for design "pwm_module"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : pwm_module_tb.vhd
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : 
-- Created    : 2011-12-13
-- Last update: 2011-12-14
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-12-13  1.0      fabian  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pwm_module_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity pwm_module_tb is
end pwm_module_tb;

-------------------------------------------------------------------------------
architecture tb of pwm_module_tb is

  -- component generics
  constant BASE_ADDRESS : positive := 16;
  constant WIDTH        : positive := 12;
  constant PRESCALER    : positive := 2;

  -- component ports
  signal pwm_p : std_logic;
  signal bus_o : busdevice_out_type;
  signal bus_i : busdevice_in_type := 
    (addr => (others => '0'),
     data => (others => '0'),
     we   => '0',
     re   => '0');
  signal reset : std_logic;
  signal clk   : std_logic := '1';

begin

  -- component instantiation
  DUT : pwm_module
    generic map (
      BASE_ADDRESS => BASE_ADDRESS,
      WIDTH        => WIDTH,
      PRESCALER    => PRESCALER)
    port map (
      pwm_p => pwm_p,
      bus_o => bus_o,
      bus_i => bus_i,
      reset => reset,
      clk   => clk);

  -- clock generation
  clk <= not clk after 10 ns;

  -- reset generation
  reset <= '1', '0' after 50 ns;

  waveform : process
  begin
    wait until falling_edge(reset);
    wait for 20 us;

    -- wrong address
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(20, 15));
    bus_i.data <= x"0123";
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.we   <= '0';

    wait for 30 us;

    -- correct address
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(16, 15));
    bus_i.data <= x"07ff";
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.we   <= '0';

    wait for 30 us;

    -- wrong address
    wait until rising_edge(clk);
    bus_i.addr <= std_logic_vector(to_unsigned(10, 15));
    bus_i.data <= x"0123";
    bus_i.we   <= '1';
    wait until rising_edge(clk);
    bus_i.we   <= '0';
    
  end process waveform;
end tb;
