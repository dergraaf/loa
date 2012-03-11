-------------------------------------------------------------------------------
-- Title      : Testbench for design "adc_mcp3008"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_mcp3008_tb.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2012-02-11
-- Last update: 2012-02-16
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Simulates a single cycle measurement. Is not self-checking.
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-02-11  1.0      calle   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity adc_mcp3008_tb is

end adc_mcp3008_tb;

-------------------------------------------------------------------------------

architecture tb of adc_mcp3008_tb is

  use work.adc_mcp3008_pkg.all;

  -- Component generics
  constant DELAY : natural := 5;

  -- component ports
  signal miso_p     : std_logic;
  signal mosi_p     : std_logic;
  signal cs_np      : std_logic;
  signal sck_p      : std_logic;
  signal start_p    : std_logic;
  signal adc_mode_p : std_logic;
  signal channel_p  : std_logic_vector(2 downto 0);
  signal value_p    : std_logic_vector(9 downto 0);
  signal done_p     : std_logic;
  signal reset      : std_logic;

  signal adc_i : adc_mcp3008_spi_in_type;
  signal adc_o : adc_mcp3008_spi_out_type;

  --signal clk        : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : adc_mcp3008
    generic map (
      DELAY => 5)
    port map (
      adc_out    => adc_o,
      adc_in     => adc_i,
      start_p    => start_p,
      adc_mode_p => adc_mode_p,
      channel_p  => channel_p,
      value_p    => value_p,
      done_p     => done_p,
      reset      => reset,
      clk        => clk);


  adc_i.miso <= miso_p;
  mosi_p     <= adc_o.mosi;
  cs_np      <= adc_o.cs_n;
  sck_p      <= adc_o.sck;

  -----------------------------------------------------------------------------
  -- clock and reset generation
  -----------------------------------------------------------------------------
  Clk <= not Clk after 10 ns;

  process
  begin
    reset <= '1';
    wait for 22 ns;
    reset <= '0';
    wait for 1 ms;
  end process;


  -----------------------------------------------------------------------------
  -- this is the bus/command side of the ADC I/F
  -----------------------------------------------------------------------------

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    start_p    <= '0';
    adc_mode_p <= '1';
    channel_p  <= "011";
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    start_p    <= '1';
    wait until Clk = '1';
    start_p    <= '0';
    wait until Clk = '1';

    wait for 1 ms;
  end process WaveGen_Proc;



  -----------------------------------------------------------------------------
  -- ADC side stimulus
  -----------------------------------------------------------------------------
  
  process
  begin
    miso_p <= 'Z';

    wait until cs_np = '0';

    wait until sck_p = '1';
    wait until sck_p = '0';
    wait until sck_p = '0';
    wait until sck_p = '0';
    wait until sck_p = '0';
    wait until sck_p = '0';
    wait until sck_p = '0';

    -- leading zero of mcp3008
    miso_p <= '0';
    wait until sck_p = '0';

    -- actual MSB of conversion
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '0';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '0';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '0';
    wait until sck_p = '0';
    miso_p <= '0';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '0';
    wait until sck_p = '0';
    miso_p <= '1';

    wait until sck_p = '0';
    miso_p <= 'Z';

    wait for 1 ms;
  end process;
  
end tb;

-------------------------------------------------------------------------------

configuration adc_mcp3008_tb_tb_cfg of adc_mcp3008_tb is
  for tb
  end for;
end adc_mcp3008_tb_tb_cfg;

-------------------------------------------------------------------------------
