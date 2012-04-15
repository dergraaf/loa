-------------------------------------------------------------------------------
-- Title      : Testbench for design "ir_rx_module"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_module_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-15
-- Last update: 2012-04-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.ir_rx_module_pkg.all;

-------------------------------------------------------------------------------

entity ir_rx_module_tb is

end ir_rx_module_tb;

-------------------------------------------------------------------------------

architecture tb of ir_rx_module_tb is

   -- component generics
   constant BASE_ADDRESS : integer := 16#0800#;

   -- component ports
   signal adc_out_p     : ir_rx_module_spi_out_type;
   signal adc_in_p      : ir_rx_module_spi_in_type;
   signal adc_values    : adc_ltc2351_values_type(11 downto 0);
   signal sync_p        : std_logic;
   signal bus_o         : busdevice_out_type;
   signal bus_i         : busdevice_in_type;
   signal done_p        : std_logic;
   signal ack_p         : std_logic;
   signal clk_sample_en : std_logic;

  -- clock
  signal clk : std_logic := '1';

begin  -- tb

   -- component instantiation
   DUT: ir_rx_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         adc_out_p     => adc_out_p,
         adc_in_p      => adc_in_p,
         adc_values    => adc_values,
         sync_p        => sync_p,
         bus_o         => bus_o,
         bus_i         => bus_i,
         done_p        => done_p,
         ack_p         => ack_p,
         clk_sample_en => clk_sample_en,
         clk           => clk);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here

    wait until clk = '1';
  end process WaveGen_Proc;

   

end tb;
