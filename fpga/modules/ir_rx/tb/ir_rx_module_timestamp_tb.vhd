-------------------------------------------------------------------------------
-- Title      : Testbench for design "ir_rx_module" with timestamps
------------------------------------------------------------------------------
-- File       : ir_rx_module_timestamp_tb.vhd
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
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity ir_rx_module_timestamp_tb is

end ir_rx_module_timestamp_tb;

-------------------------------------------------------------------------------

architecture tb of ir_rx_module_timestamp_tb is

   -- component generics
   constant BASE_ADDRESS_RESULTS   : integer := 16#0800#;
   constant BASE_ADDRESS_COEFS     : integer := 16#0010#;
   constant BASE_ADDRESS_TIMESTAMP : integer := 16#0100#;

   constant TIMESTAMP_WIDTH : natural := 48;

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

   -- timestamp
   signal timestamp_s : timestamp_type;

   -- clock
   signal clk : std_logic := '1';

begin  -- tb

   ir_rx_module_1 : entity work.ir_rx_module
      generic map (
         BASE_ADDRESS_COEFS     => BASE_ADDRESS_COEFS,
         BASE_ADDRESS_RESULTS   => BASE_ADDRESS_RESULTS,
         BASE_ADDRESS_TIMESTAMP => BASE_ADDRESS_TIMESTAMP,
         SAMPLES                => 10)
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

   timestamp_1 : entity work.timestamp_generator
      port map (
         timestamp_o_p => timestamp_s,
         clk           => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- Trigger ADC conversions
   WaveGen_Proc : process
   begin
      wait until clk = '1';
      if done_p = '0' then
         clk_sample_en <= '1';
      end if;
      wait until clk = '1';
      clk_sample_en <= '0';
      wait
         for 7 us;
   end process WaveGen_Proc;

   -- Acknowledge if the module is finished
   ack_proc : process
   begin  -- process ack_proc
      wait until done_p = '1';
      wait
         for 5 us;
      ack_p <= '1';
      wait
         for 1 us;
      ack_p <= '0';
   end process ack_proc;


end tb;
