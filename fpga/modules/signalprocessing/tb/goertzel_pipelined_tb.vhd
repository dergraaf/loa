-------------------------------------------------------------------------------
-- Title      : Testbench for design "goertzel_pipelined"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipelined_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-15
-- Last update: 2012-04-20
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
use ieee.math_real.all;

library work;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity goertzel_pipelined_tb is

end goertzel_pipelined_tb;

-------------------------------------------------------------------------------

architecture tb of goertzel_pipelined_tb is

   -- component generics
   constant SAMPLES     : natural := 250;

   constant CHANNELS    : natural := 3;
   constant FREQUENCIES : natural := 2;
   constant Q           : natural := 13;

   -- clock
   signal clk : std_logic := '1';

   -- calculate Goertzel Coefficient
   -- TODO Calculate with math_real
   --
   -- Find two different frequencies in signal
   -- 
   --           +-< frequency
   --           |
   constant COEF0 : unsigned := to_unsigned(2732, CALC_WIDTH);
   constant COEF1 : unsigned := to_unsigned(2532, CALC_WIDTH);

   constant COEFS : goertzel_coefs_type(FREQUENCIES-1 downto 0) := (COEF1, COEF0);

   -- component ports
   signal inputs_s  : goertzel_inputs_type(CHANNELS-1 downto 0)                          := (others => (others => '0'));
   signal start_s   : std_logic                                                          := '0';
   signal results_s : goertzel_results_type(CHANNELS-1 downto 0, FREQUENCIES-1 downto 0) := (others => (others => (others => (others => '0'))));
   signal done_s    : std_logic                                                          := '0';

   -- signal generation for testbench
   signal PHASE0 : real := 0.0;
   signal PHASE1 : real := 0.0;
   signal PHASE2 : real := 0.0;

   constant SCALE  : real := 2.0**7 - 10.0;
   constant OFFSET : real := 2.0**13;

   constant FSAMPLE  : real := 75000.0;  -- Sample Frequency in Hertz
   constant FSIGNAL0 : real := 16750.0;  -- Signal Frequency in Hertz
   constant FSIGNAL1 : real := 16700.0;  -- Signal Frequency in Hertz
   constant FSIGNAL2 : real := 16600.0;  -- Signal Frequency in Hertz

   signal PHASE_INCREMENT0 : real := 2.0 * 3.1415 * FSIGNAL0 / FSAMPLE;
   signal PHASE_INCREMENT1 : real := 2.0 * 3.1415 * FSIGNAL1 / FSAMPLE;
   signal PHASE_INCREMENT2 : real := 2.0 * 3.1415 * FSIGNAL2 / FSAMPLE;

   -- debugging signal for goertzel
   type   goertzel_values_type is array (CHANNELS-1 downto 0, FREQUENCIES-1 downto 0) of real;
   signal goertzel_values_s : goertzel_values_type := (others => (others => 0.0));
   
begin  -- tb

   goertzel_pipelined_1 : goertzel_pipelined
      generic map (
         Q           => 13,
         SAMPLES     => 1000,
         CHANNELS    => CHANNELS,
         FREQUENCIES => FREQUENCIES)
      port map (
         coefs_p   => COEFS,
         inputs_p  => inputs_s,
         start_p   => start_s,
         results_p => results_s,
         done_p    => done_s,
         clk       => clk);

   -- clock generation
   clk <= not clk after 20 ns;

   -- every 5 clock cycles a start_p signal from ADC
   start_gen_proc : process
   begin  -- process start_gen_proc
      start_s <= '0';
      wait until clk = '1';
      start_s <= '1';
      wait until clk = '1';
      start_s <= '0';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';      
   end process start_gen_proc;

   -- Test signal waveform generation
   WaveGen_Proc : process
   begin
      for n in 0 to 10000 loop
         wait until start_s = '1';
         -- signed values from three ADC channels
         inputs_s(0) <= to_signed(integer(SCALE * sin(PHASE0)), INPUT_WIDTH);
         inputs_s(1) <= to_signed(integer(SCALE * sin(PHASE1)), INPUT_WIDTH);
         inputs_s(2) <= to_signed(integer(SCALE * sin(PHASE2)), INPUT_WIDTH);

         PHASE0 <= PHASE0 + PHASE_INCREMENT0;
         PHASE1 <= PHASE1 + PHASE_INCREMENT1;
         PHASE2 <= PHASE2 + PHASE_INCREMENT2;
      end loop;

      -- end, do not repeat pattern
      wait for 10 ms;
   end process WaveGen_Proc;

   -- Calculate Goertzel Value in this test bench. This will not be implemented
   -- in VHDL. It is done in the processor in floating point.
   GoertzelCheck_proc : process      
      variable d1 : real := 0.0;
      variable d2 : real := 0.0;
      variable c  : real := 0.0;
      
   begin  -- process GoertzelCheck_proc
      wait until done_s = '1';

      -- new values are available in the result registers
      -- convert results from Q-format to real
      for ch in 0 to CHANNELS-1 loop
         for fr in 0 to FREQUENCIES-1 loop         
            d1 := real(to_integer(results_s(ch, fr)(0))) / 2.0**(Q-2);
            d2 := real(to_integer(results_s(ch, fr)(1))) / 2.0**(Q-2);
            c  := real(to_integer(coefs(fr))) / 2.0**Q;

            -- calculate goertzel value
            goertzel_values_s(ch, fr) <= d1**2 + d2**2 - (d2 * d1 * c);
         end loop;  -- fr
      end loop;  -- ch
   end process GoertzelCheck_proc;
end tb;
