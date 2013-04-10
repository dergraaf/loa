-------------------------------------------------------------------------------
-- Title      : Testbench for design "imotor_transceiver"
-- Project    : 
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_transceiver_tb is

end entity imotor_transceiver_tb;

-------------------------------------------------------------------------------

architecture tb of imotor_transceiver_tb is

   -- component generics
   constant DATA_WORDS_SEND : positive := 2;
   constant DATA_WORDS_READ : positive := 3;
   constant DATA_WIDTH      : positive := 16;

   constant CLOCK          : positive := 50000000;
   constant BAUD           : positive := 1000000;
   constant SEND_FREQUENCY : positive := 5000;

   -- component ports
   signal data_in_p  : imotor_input_type(DATA_WORDS_SEND - 1 downto 0);
   signal data_out_p : imotor_output_type(DATA_WORDS_READ - 1 downto 0);
   signal tx_out_p   : std_logic;
   signal rx_in_p    : std_logic;

   signal rx_in_can : std_logic;
   signal rx_in     : std_logic := '1';

   signal imotor_clock_s : imotor_timer_type;

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : entity work.imotor_transceiver
      generic map (
         DATA_WORDS_SEND => DATA_WORDS_SEND,
         DATA_WORDS_READ => DATA_WORDS_READ,
         DATA_WIDTH      => DATA_WIDTH)
      port map (
         data_in_p  => data_in_p,
         data_out_p => data_out_p,
         tx_out_p   => tx_out_p,
         rx_in_p    => rx_in_can,
         timer_in_p => imotor_clock_s,
         clk        => clk);

   imotor_timer : entity work.imotor_timer
      generic map (
         CLOCK          => CLOCK,
         BAUD           => BAUD,
         SEND_FREQUENCY => SEND_FREQUENCY)
      port map (
         clock_out_p => imotor_clock_s,
         clk         => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   rx_in_can <= '0' when rx_in = '0' or tx_out_p = '0' else '1';

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';
   end process WaveGen_Proc;



end architecture tb;

-------------------------------------------------------------------------------

configuration imotor_transceiver_tb_tb_cfg of imotor_transceiver_tb is
   for tb
   end for;
end imotor_transceiver_tb_tb_cfg;

-------------------------------------------------------------------------------
