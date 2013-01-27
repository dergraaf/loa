-------------------------------------------------------------------------------
-- Title      : Testbench for design "goertzel_control_unit"
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity goertzel_control_unit_tb is

end entity goertzel_control_unit_tb;

-------------------------------------------------------------------------------

architecture tb of goertzel_control_unit_tb is

   -- component generics
   constant SAMPLES     : positive := 5;
   constant FREQUENCIES : positive := 2;
   constant CHANNELS    : positive := 3;

   -- component ports
   signal start_p    : std_logic                    := '0';
   signal ready_p    : std_logic                    := '0';
   signal bram_addr  : std_logic_vector(7 downto 0) := (others => '0');
   signal bram_we    : std_logic                    := '0';
   signal mux_delay1 : std_logic                    := '0';
   signal mux_delay2 : std_logic                    := '0';
   signal mux_coef   : natural range FREQUENCIES-1 downto 0;
   signal mux_input  : natural range CHANNELS-1 downto 0;

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : entity work.goertzel_control_unit
      generic map (
         SAMPLES     => SAMPLES,
         FREQUENCIES => FREQUENCIES,
         CHANNELS    => CHANNELS)
      port map (
         start_p      => start_p,
         ready_p      => ready_p,
         bram_addr_p  => bram_addr,
         bram_we_p    => bram_we,
         mux_delay1_p => mux_delay1,
         mux_delay2_p => mux_delay2,
         mux_coef_p   => mux_coef,
         mux_input_p  => mux_input,
         clk          => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin

      -- some delay
      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';

      -- New 12 new samples from ADCs received: start control unit!
      start_p <= '1';
      wait until clk = '0';
      start_p <= '0';

      -- wait until all samples for all frequencies are processed and the
      -- address counter was reset to 0
      wait until bram_addr = "00000000";

      -- restart
   end process WaveGen_Proc;

   

end architecture tb;
