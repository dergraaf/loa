-------------------------------------------------------------------------------
-- Title      : Testbench for design "adc_ltc2351_module"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_ltc2351_module_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-10
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity adc_ltc2351_module_tb is

end adc_ltc2351_module_tb;

-------------------------------------------------------------------------------

architecture tb of adc_ltc2351_module_tb is

  use work.adc_ltc2351_pkg.all;
  use work.reg_file_pkg.all;
  use work.bus_pkg.all;


  --component adc_ltc2351_module
  --  generic (
  --    BASE_ADDRESS : integer range 0 to 32767);
  --  port (
  --    adc_out_p : out adc_ltc2351_spi_out_type;
  --    adc_in_p  : in  adc_ltc2351_spi_in_type;
  --    bus_o     : out busdevice_out_type;
  --    bus_i     : in  busdevice_in_type;
  --    reset     : in  std_logic;
  --    clk       : in  std_logic);
  --end component;

  -- component generics
  constant BASE_ADDRESS : integer range 0 to 32767 := 0;

  -- component ports
  signal adc_out_p : adc_ltc2351_spi_out_type;
  signal adc_in_p  : adc_ltc2351_spi_in_type;
  signal bus_o     : busdevice_out_type;
  signal bus_i     : busdevice_in_type;
  signal reset     : std_logic;
  --signal clk       : std_logic;


  signal miso_p : std_logic;
  signal mosi_p : std_logic;
  signal cs_np  : std_logic;
  signal sck_p  : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : adc_ltc2351_module
    generic map (
      BASE_ADDRESS => BASE_ADDRESS)
    port map (
      adc_out_p    => adc_out_p,
      adc_in_p     => adc_in_p,
      bus_o        => bus_o,
      bus_i        => bus_i,
      adc_values_o => open,
      reset        => reset,
      clk          => clk);


  -- clock generation
  Clk <= not Clk after 10 ns;

--  adc_in_p.miso <= miso_p;
--  mosi_p        <= adc_out_p.mosi;
--  cs_np         <= adc_out_p.cs_n;
  sck_p         <= adc_out_P.sck;


  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    reset <= '1';
    wait until Clk = '1';
    reset <= '0';
    wait for 100000 ms;
  end process WaveGen_Proc;


  -- waveform generation
  bus_stimulus_proc : process
  begin
    bus_i.addr <= (others => '0');
    bus_i.data <= (others => '0');
    bus_i.re   <= '0';
    bus_i.we   <= '0';

    wait until Clk = '1';


    wait until Clk = '1';
    bus_i.addr <= (others => '0');
    bus_i.data <= "0000" & "0000" & "0000" & "0001";
    bus_i.re   <= '0';
    bus_i.we   <= '1';

    wait until Clk = '1';
    bus_i.we <= '0';

    wait until Clk = '1';
    wait until Clk = '1';


    wait until Clk = '1';
    bus_i.addr(0) <= '1';
    bus_i.data    <= "0000" & "0000" & "0000" & "0001";
    bus_i.re      <= '0';
    bus_i.we      <= '1';

    wait until Clk = '1';
    bus_i.data <= (others => '0');
    bus_i.we   <= '0';


    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';

    -- read the registers
    bus_i.addr(0) <= '0';
    bus_i.re      <= '1';
    wait until Clk = '1';
    bus_i.re      <= '0';
    wait until Clk = '1';


    bus_i.addr(0) <= '1';
    bus_i.re      <= '1';
    wait until Clk = '1';
    bus_i.re      <= '0';
    wait until Clk = '1';

    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';


    -- do the same reads, but the DUT shouldn't react
    bus_i.addr(0) <= '0';
    bus_i.addr(8) <= '0';               -- another address
    bus_i.re      <= '1';
    wait until Clk = '1';
    bus_i.re      <= '0';
    wait until Clk = '1';


    bus_i.addr(0) <= '1';
    bus_i.re      <= '1';
    wait until Clk = '1';
    bus_i.re      <= '0';
    wait until Clk = '1';


    wait for 10000 ns;
    
  end process bus_stimulus_proc;

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

    -- leading zero of ltc2351
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
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';

    wait until sck_p = '0';
    miso_p <= 'Z';





    miso_p <= 'Z';

    wait until cs_np = '0';

    wait until sck_p = '1';
    wait until sck_p = '0';
    wait until sck_p = '0';
    wait until sck_p = '0';
    wait until sck_p = '0';
    wait until sck_p = '0';
    wait until sck_p = '0';

    -- leading zero of ltc2351
    miso_p <= '0';
    wait until sck_p = '0';

    -- actual MSB of conversion
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';
    wait until sck_p = '0';
    miso_p <= '1';

    wait until sck_p = '0';
    miso_p <= 'Z';


  end process;

  

end tb;

-------------------------------------------------------------------------------

configuration adc_ltc2351_module_tb_tb_cfg of adc_ltc2351_module_tb is
  for tb
  end for;
end adc_ltc2351_module_tb_tb_cfg;

-------------------------------------------------------------------------------
