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
-- Tests the ADC LTC2351 module including a simulation of the ADC.
-- It is not self checking. The expected result after an ADC cycle (when done
-- went '1' is that the register file (reg_i(0) to reg_i(5)) contains the
-- predefined ADC values from adc_ltc2351_model.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
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

  -- component generics
  constant BASE_ADDRESS : integer range 0 to 32767 := 0;

  -- component ports
  signal adc_out_p : adc_ltc2351_spi_out_type;
  signal adc_in_p  : adc_ltc2351_spi_in_type;
  signal bus_o     : busdevice_out_type;
  signal bus_i     : busdevice_in_type;
  signal reset     : std_logic;

  signal sck_p  : std_logic;
  signal conv_p : std_logic;
  signal sdo_p  : std_logic;

  -- clock
  signal clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : adc_ltc2351_module
    generic map (
      BASE_ADDRESS => BASE_ADDRESS
      )
    port map (
      adc_out_p    => adc_out_p,
      adc_in_p     => adc_in_p,
      bus_o        => bus_o,
      bus_i        => bus_i,
      adc_values_o => open,
      done_p       => open,
      reset        => reset,
      clk          => clk
      );

  STIM : adc_ltc2351_model
    port map (
      sck  => sck_p,
      conv => conv_p,
      sdo  => sdo_p
      );

  -- --------------------------------------------------------------------------
  -- clock generation
  -----------------------------------------------------------------------------

  clk <= not clk after 10 ns;

  sck_p        <= adc_out_P.sck;
  conv_p       <= adc_out_p.conv;
  adc_in_p.sdo <= sdo_p;

  -- --------------------------------------------------------------------------
  -- waveform generation
  -- --------------------------------------------------------------------------
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    reset <= '1';
    wait until clk = '1';
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

    -- write 0x01 to 0x00
    wait until Clk = '1';
    bus_i.addr <= (others => '0');
    bus_i.data <= "0000" & "0000" & "0000" & "0001";
    bus_i.re   <= '0';
    bus_i.we   <= '1';

    wait until Clk = '1';
    bus_i.we <= '0';

    wait until Clk = '1';
    wait until Clk = '1';

    -- write 0x01 to 0x01
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

end tb;

-------------------------------------------------------------------------------

configuration adc_ltc2351_module_tb_tb_cfg of adc_ltc2351_module_tb is
  for tb
  end for;
end adc_ltc2351_module_tb_tb_cfg;

-------------------------------------------------------------------------------
