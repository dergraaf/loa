-------------------------------------------------------------------------------
-- Title      : Testbench for design "imotor_receiver"
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_receiver_tb is
end entity imotor_receiver_tb;

-------------------------------------------------------------------------------

architecture behavourial of imotor_receiver_tb is

   -- component generics

   -- Component ports

   -- clock
   signal clk : std_logic := '1';

   signal clock_s : imotor_timer_type;

   signal imotor_input_s : imotor_input_type(1 downto 0) := (x"0403", x"0201");

   signal data_tx_s : std_logic_vector(7 downto 0);

   signal start_tx_s : std_logic;
   signal busy_tx_s  : std_logic;
   signal txd_out_s  : std_logic;

begin  -- architecture behavourial

   -- component instantiation

   imotor_timer_1 : imotor_timer
      generic map (
         CLOCK          => 50E6,
         BAUD           => 10E6,
         SEND_FREQUENCY => 1E5)
      port map (
         clock_out_p => clock_s,
         clk         => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';

      wait until false;

   end process WaveGen_Proc;

end architecture behavourial;
