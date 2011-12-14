-------------------------------------------------------------------------------
-- Title      : Testbench for design "spi_slave"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spi_slave_tb.vhd
-- Author     : cjt@users.sourceforge.net
-- Company    : 
-- Created    : 2011-07-31
-- Last update: 2011-12-14
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-07-31  1.0      calle   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.spislave_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------

entity spi_slave_tb is
  
end spi_slave_tb;

-------------------------------------------------------------------------------

architecture tb of spi_slave_tb is

  -- component ports
  signal mosi  : std_logic;
  signal miso  : std_logic;
  signal sck   : std_logic;
  signal csn   : std_logic;
  signal reset : std_logic := '1';
  signal clk   : std_logic := '1';

  signal bus_o : busmaster_out_type;
  signal bus_i : busmaster_in_type;

begin  -- tb

  DUT : spi_slave port map (
    --ireg    => open,
    --bit_cnt => open,

    miso_p => miso,
    mosi_p => mosi,
    sck_p  => sck,
    csn_p  => csn,

    bus_o   => bus_o,
    bus_i   => bus_i,

    reset => reset,
    clk   => clk);

  -- clock generation
  Clk <= not Clk after 5.0 ns;

  bus_i.data <= x"1234";

  process
  begin
    wait for 25 ns;
    reset <= '0';
  end process;

  process
    variable d : std_logic_vector(31 downto 0);
    
  begin
    wait until (reset = '0');
    csn  <= '1';
    sck  <= '0';
    mosi <= '0';
    wait for 50 ns;
    csn  <= '0';
    wait for 100 ns;

    d := X"70000000";

    for i in 31 downto 0 loop
      sck  <= '0';
      mosi <= d(i);
      wait for 50 ns;
      sck  <= '1';
      wait for 50 ns;
      
    end loop;  -- i
    sck  <= '0';
    wait for 50 ns;
    csn  <= '1';
    sck  <= '0';
    mosi <= 'Z';

    wait for 50 ns;
    csn <= '0';
    wait for 50 ns;

    d := X"80ff" & X"ff55";

    for i in 31 downto 0 loop
      sck  <= '0';
      mosi <= d(i);
      wait for 50 ns;
      sck  <= '1';
      wait for 50 ns;
      
    end loop;  -- i


    if false then
      sck  <= '0';
      wait for 50 ns;
      csn  <= '1';
      mosi <= 'Z';
      wait for 50 ns;
      csn <= '0';
      wait for 50 ns;
    end if;

    d := X"8f0f" & X"1234";

    for i in 31 downto 0 loop
      sck  <= '0';
      mosi <= d(i);
      wait for 50 ns;
      sck  <= '1';
      wait for 50 ns;
      
    end loop;  -- i

    sck  <= '0';
    wait for 50 ns;
    csn  <= '1';
    mosi <= 'Z';


    
  end process;

end tb;

