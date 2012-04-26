-------------------------------------------------------------------------------
-- Title      : Testbench for design "ir_rx_module"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_module_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-15
-- Last update: 2012-04-26
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
   constant BASE_ADDRESS_RESULTS : integer := 16#0800#;
   constant BASE_ADDRESS_COEFS   : integer := 16#0010#;

   -- component ports
   signal adc_out_p     : ir_rx_module_spi_out_type;
   signal adc_in_p      : ir_rx_module_spi_in_type;
   signal adc_values_s  : adc_ltc2351_values_type(11 downto 0);
   signal sync_p        : std_logic;
   signal bus_o         : busdevice_out_type;
   signal bus_i         : busdevice_in_type;
   signal done_p        : std_logic;
   signal ack_p         : std_logic;
   signal clk_sample_en : std_logic;

   signal adc_values_test        : std_logic_vector(13 downto 0);
   signal adc_values_test_signed : signed(13 downto 0);

   -- clock
   signal clk : std_logic := '1';

begin  -- tb

   ir_rx_module_1 : entity work.ir_rx_module
      generic map (
         BASE_ADDRESS_COEFS   => BASE_ADDRESS_COEFS,
         BASE_ADDRESS_RESULTS => BASE_ADDRESS_RESULTS)
      port map (
         adc_out_p     => adc_out_p,
         adc_in_p      => adc_in_p,
         adc_values_p  => open,
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
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';
      clk_sample_en <= '1';
      wait until clk = '1';



      wait for 10 ms;
   end process WaveGen_Proc;

   adc_values_test_signed <= signed(adc_values_test) - to_signed(16#2000#, 14);

   adc_proc : process
   begin  -- process adc_proc
      wait until clk = '1';
      adc_values_test <= "00000000000000";
      wait until clk = '1';
      adc_values_test <= "11111111111111";
      wait until clk = '1';
      adc_values_test <= "01111111111111";
      wait until clk = '1';
      adc_values_test <= "10000000000000";

      wait for 10 ms;
      
   end process adc_proc;

   ack_proc : process
   begin  -- process ack_proc
      ack_p <= '0';
      wait for 90 us;
      ack_p <= '1';
      wait for 5 us;
      ack_p <= '0';
      

   end process ack_proc;
   

end tb;
