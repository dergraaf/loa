-------------------------------------------------------------------------------
-- Title      : Testbench for design "us_rx_module"
-------------------------------------------------------------------------------
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity us_rx_module_tb is

end entity us_rx_module_tb;

-------------------------------------------------------------------------------

architecture behavourial of us_rx_module_tb is

   -- component generics
   constant BASE_ADDRESS : natural := 16#0100#;

   -- component ports
   signal bus_o_p : busdevice_out_type;
   signal bus_i_p : busdevice_in_type;

   signal timestamp : timestamp_type;

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture behavourial

   -- component instantiation
   DUT : entity work.us_rx_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         bus_o_p           => bus_o_p,
         bus_i_p           => bus_i_p,
         clk_sample_en_i_p => '0',
         timestamp_i_p     => timestamp,
         clk               => clk);

   -- clock generation 50 MHz
   clk <= not clk after 20 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';
   end process WaveGen_Proc;

end architecture behavourial;
