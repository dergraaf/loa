-------------------------------------------------------------------------------
-- Title      : Testbench for design "ir_rx_module"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_module_tb.vhd
-- Author     : strongly-typed
-- Created    : 2012-04-15
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
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.ir_rx_module_pkg.all;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity ir_rx_module_tb is

end ir_rx_module_tb;

-------------------------------------------------------------------------------

architecture tb of ir_rx_module_tb is

   -- component generics
   constant BASE_ADDRESS_RESULTS   : integer := 16#0800#;
   constant BASE_ADDRESS_COEFS     : integer := 16#0010#;
   constant BASE_ADDRESS_TIMESTAMP : integer := 16#0100#;

   -- component ports
   signal adc_out_p : ir_rx_module_spi_out_type;
   signal adc_in_p  : ir_rx_module_spi_in_type := (others => (others => '0'));
   signal sync_p    : std_logic                := '0';
   signal bus_o     : busdevice_out_type       := (data   => (others => '0'));
   signal bus_i : busdevice_in_type := (addr => (others => '0'),
                                        data => (others => '0'),
                                        we   => '0',
                                        re   => '0');
   signal done_p        : std_logic := '0';
   signal ack_p         : std_logic := '0';
   signal clk_sample_en : std_logic := '0';

   signal adc_values_test        : std_logic_vector(13 downto 0) := (others => '0');
   signal adc_values_test_signed : signed(13 downto 0)           := (others => '0');

   signal offset : signed(13 downto 0) := "10000000000000";

   signal timestamp_s : timestamp_type := (others => '0');

   -- clock
   signal clk : std_logic := '1';

begin  -- tb

   ir_rx_module_1 : entity work.ir_rx_module
      generic map (
         BASE_ADDRESS_COEFS     => BASE_ADDRESS_COEFS,
         BASE_ADDRESS_RESULTS   => BASE_ADDRESS_RESULTS,
         BASE_ADDRESS_TIMESTAMP => BASE_ADDRESS_TIMESTAMP)
      port map (
         adc_o_p           => adc_out_p,
         adc_i_p           => adc_in_p,
         adc_values_o_p    => open,
         sync_o_p          => sync_p,
         bus_o_p           => bus_o,
         bus_i_p           => bus_i,
         done_o_p          => done_p,
         ack_i_p           => ack_p,
         clk_sample_en_i_p => clk_sample_en,
         timestamp_i_p     => timestamp_s,
         clk               => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';
      clk_sample_en <= '1';
      wait until clk = '1';


      -- do not repeat
      wait;
   end process WaveGen_Proc;

   adc_values_test_signed <= signed(adc_values_test) - offset;

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

      -- do not repeat
      wait;
      
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
