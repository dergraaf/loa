-------------------------------------------------------------------------------
-- Title      : Two ADCs
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_adcs.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-27
-- Last update: 2012-04-28
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


entity ir_rx_adcs is
   
   generic (
      CHANNELS : positive := 12);

   port (
      clk_sample_en : in std_logic;

      -- Ports to two ADCs
      -- signals to and from real hardware
      adc_out_p : out ir_rx_module_spi_out_type;
      adc_in_p  : in  ir_rx_module_spi_in_type;

      adc_values_p : out adc_ltc2351_values_type;
      adc_done_p   : out std_logic;
      clk          : in  std_logic);

end ir_rx_adcs;

architecture structural of ir_rx_adcs is

   signal adc_values_s : adc_ltc2351_values_type(CHANNELS-1 downto 0);
   signal adc_done_s   : std_logic;
   
begin  -- structural

   adc_values_p <= adc_values_s;
   adc_done_p   <= adc_done_s;

   -- Two ADCs
   adc_ltc2351_0 : adc_ltc2351
      port map (
         adc_out  => adc_out_p(0),
         adc_in   => adc_in_p(0),
         start_p  => clk_sample_en,
         values_p => adc_values_s(5 downto 0),
         done_p   => adc_done_s,
         reset    => '0',
         clk      => clk
         );

   adc_ltc2351_1 : adc_ltc2351
      port map (
         adc_out  => adc_out_p(1),
         adc_in   => adc_in_p(1),
         start_p  => clk_sample_en,
         values_p => adc_values_s(11 downto 6),
         done_p   => open,
         reset    => '0',
         clk      => clk
         );

end structural;
