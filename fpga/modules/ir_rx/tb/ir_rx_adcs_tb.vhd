-------------------------------------------------------------------------------
-- Title      : Testbench for design "ir_rx_adcs"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_adcs_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-27
-- Last update: 2012-04-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.adc_ltc2351_pkg.all;
use work.ir_rx_module_pkg.all;

-------------------------------------------------------------------------------

entity ir_rx_adcs_tb is

end ir_rx_adcs_tb;

-------------------------------------------------------------------------------

architecture tb of ir_rx_adcs_tb is

   component ir_rx_adcs
      generic (
         CHANNELS : positive);
      port (
         clk_sample_en : in  std_logic;
         adc_out_p     : out ir_rx_module_spi_out_type;
         adc_in_p      : in  ir_rx_module_spi_in_type;
         adc_values_p  : out adc_ltc2351_values_type;
         adc_done_p    : out std_logic;
         clk           : in  std_logic);
   end component;

   -- component generics
   constant CHANNELS : positive := 12;

   -- component ports
   signal clk_sample_en : std_logic := '0';
   signal adc_out_s     : ir_rx_module_spi_out_type;
   signal adc_in_s      : ir_rx_module_spi_in_type;
   signal adc_values_s  : adc_ltc2351_values_type(CHANNELS-1 downto 0);
   signal adc_done_s    : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

   -- component instantiation
   DUT: ir_rx_adcs
      generic map (
         CHANNELS => CHANNELS)
      port map (
         clk_sample_en => clk_sample_en,
         adc_out_p     => adc_out_s,
         adc_in_p      => adc_in_s,
         adc_values_p  => adc_values_s,
         adc_done_p    => adc_done_s,
         clk           => clk);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here

    wait until Clk = '0';
    wait until Clk = '0';
    wait until Clk = '0';
    clk_sample_en <= '1';
    wait until clk = '0';
    clk_sample_en <= '0';
    

    wait for 10 ms;
  end process WaveGen_Proc;

   

end tb;

-------------------------------------------------------------------------------

configuration ir_rx_adcs_tb_tb_cfg of ir_rx_adcs_tb is
   for tb
   end for;
end ir_rx_adcs_tb_tb_cfg;

-------------------------------------------------------------------------------
