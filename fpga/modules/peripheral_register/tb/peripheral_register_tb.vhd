-------------------------------------------------------------------------------
-- Title      : Testbench for design "peripheral_register"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : peripheral_register_tb.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2011-10-26
-- Last update: 2011-10-27
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

-------------------------------------------------------------------------------

entity peripheral_register_tb is

end peripheral_register_tb;

-------------------------------------------------------------------------------

architecture tb of peripheral_register_tb is

  component peripheral_register
    port (
      din_p  : in  std_logic_vector(15 downto 0);
      dout_p : out std_logic_vector(15 downto 0);
      we_p   : in  std_logic;
      re_p   : in  std_logic;
      reset  : in  std_logic;
      clk    : in  std_logic);
  end component;

  -- component ports
  signal din   : std_logic_vector(15 downto 0);
  signal dout  : std_logic_vector(15 downto 0);
  signal we    : std_logic;
  signal re    : std_logic;
  signal reset : std_logic;
  signal clk   : std_logic := '1';


begin  -- tb

  -- component instantiation
  DUT : peripheral_register
    port map (
      din_p  => din,
      dout_p => dout,
      we_p   => we,
      re_p   => re,
      reset  => reset,
      clk    => clk);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    din   <= (others => '0');
    we    <= '0';
    re    <= '0';
    reset <= '1';

    wait for 20 ns;

    wait until Clk = '1';
    reset <= '0';

    wait until Clk = '1';
    re <= '1';

    wait until Clk = '1';
    re <= '0';

    wait until Clk = '1';

    wait until Clk = '1';
    din <= X"1234";
    we  <= '1';

    wait until Clk = '1';
    din <= X"0000";
    we <= '0';

    wait until Clk = '1';

    wait until Clk = '1';

    wait until Clk = '1';
    re <= '1';

    wait until Clk = '1';
    re <= '0';

    wait for 1 ms;
    
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration peripheral_register_tb_tb_cfg of peripheral_register_tb is
  for tb
  end for;
end peripheral_register_tb_tb_cfg;

-------------------------------------------------------------------------------
