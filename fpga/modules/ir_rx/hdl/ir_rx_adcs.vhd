-------------------------------------------------------------------------------
-- Title      : Two ADCs
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_adcs.vhd
-- Author     : strongly-typed
-- Created    : 2012-04-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 strongly-typed
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
      clk_sample_en_i_p : in std_logic;

      -- Ports to two ADCs
      -- signals to and from real hardware
      adc_o_p : out ir_rx_module_spi_out_type;
      adc_i_p : in  ir_rx_module_spi_in_type;

      adc_values_o_p : out adc_ltc2351_values_type;
      adc_done_o_p   : out std_logic;
      clk            : in  std_logic);

end ir_rx_adcs;

architecture structural of ir_rx_adcs is

   signal adc_values_s : adc_ltc2351_values_type(CHANNELS-1 downto 0) := (others => (others => '0'));
   signal adc_done_s   : std_logic;
   
begin  -- structural

   adc_values_o_p <= adc_values_s;
   adc_done_o_p   <= adc_done_s;

   -- Two ADCs
   adc_ltc2351_0 : adc_ltc2351
      port map (
         adc_out  => adc_o_p(0),
         adc_in   => adc_i_p(0),
         start_p  => clk_sample_en_i_p,
         values_p => adc_values_s(5 downto 0),
         done_p   => adc_done_s,
         clk      => clk
         );

   adc_ltc2351_1 : adc_ltc2351
      port map (
         adc_out  => adc_o_p(1),
         adc_in   => adc_i_p(1),
         start_p  => clk_sample_en_i_p,
         values_p => adc_values_s(11 downto 6),
         done_p   => open,
         clk      => clk
         );

end structural;
