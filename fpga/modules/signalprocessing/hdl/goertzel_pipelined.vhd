-------------------------------------------------------------------------------
-- Title      : Fixed point implementation of Goertzel's Algorithm
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-15
-- Last update: 2012-04-21
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Fixed point implementation of Goertzel's Algorithm to detect a
-- fixed frequency in an analog signal. Multiple channels and frequencies are
-- calculated pipelined to save resources (especially hardware multiplier).
--
-- This does not implement the calculation
-- of the magnitude of the signal at the end of one block.
-- Mind overflows!
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

entity goertzel_pipelined is
   generic (
      -- Width of ADC input
      -- Due to overflow prevention: Not as wide as the internal width of
      -- calculations. Set in the signalprocessing_pkg.vhd
      -- INPUT_WIDTH : natural := 14;

      -- Width of internal calculations
      -- Remember that internal multiplier are at most 18 bits wide (in Xilinx Spartan)
      -- CALC_WIDTH : natural := 18;

      -- Fixed point data format
      Q : natural := 13;

      -- Number of samples used to detect a frequency.
      -- After SAMPLES samples new samples are available. 
      SAMPLES : natural := 250;

      -- Number of Channels
      CHANNELS : natural := 12;

      -- Number of Frequencies
      FREQUENCIES : natural := 2
      );
   port (
      -- Goertzel Coefficient calculated by
      -- c = 2 cos(2 pi f_signal / f_sample)
      coefs_p : in goertzel_coefs_type(FREQUENCIES-1 downto 0);

      -- Values from ADC
      inputs_p : in goertzel_inputs_type(CHANNELS-1 downto 0);

      -- clock enable input, is high when new value from ADC is available.
      start_p : in std_logic;

      results_p : out goertzel_results_type(CHANNELS-1 downto 0, FREQUENCIES-1 downto 0);

      -- clock enable outut, is high when new results are available
      done_p : out std_logic;

      clk : in std_logic
      );

end goertzel_pipelined;

architecture behavioural of goertzel_pipelined is

   ----------------------------------------------------------------------------
   -- Types
   ----------------------------------------------------------------------------
   type goertzel_state_type is (
      IDLE,
      CALC
      );

   type goertzel_type is record
      state           : goertzel_state_type;
      channel         : natural range 0 to CHANNELS-1;
      frequency       : natural range 0 to FREQUENCIES-1;
      sample_count    : natural range 0 to SAMPLES-1;
      done            : std_logic;
      delay_ch0_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch0_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch1_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch1_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch2_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch2_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch3_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch3_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch4_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch4_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch5_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch5_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch6_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch6_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch7_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch7_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch8_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch8_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch9_f0_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch9_f0_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch10_f0_0 : signed(CALC_WIDTH-1 downto 0);
      delay_ch10_f0_1 : signed(CALC_WIDTH-1 downto 0);
      delay_ch11_f0_0 : signed(CALC_WIDTH-1 downto 0);
      delay_ch11_f0_1 : signed(CALC_WIDTH-1 downto 0);

      delay_ch0_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch0_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch1_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch1_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch2_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch2_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch3_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch3_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch4_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch4_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch5_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch5_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch6_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch6_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch7_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch7_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch8_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch8_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch9_f1_0  : signed(CALC_WIDTH-1 downto 0);
      delay_ch9_f1_1  : signed(CALC_WIDTH-1 downto 0);
      delay_ch10_f1_0 : signed(CALC_WIDTH-1 downto 0);
      delay_ch10_f1_1 : signed(CALC_WIDTH-1 downto 0);
      delay_ch11_f1_0 : signed(CALC_WIDTH-1 downto 0);
      delay_ch11_f1_1 : signed(CALC_WIDTH-1 downto 0);

      result_ch0_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch0_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch1_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch1_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch2_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch2_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch3_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch3_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch4_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch4_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch5_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch5_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch6_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch6_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch7_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch7_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch8_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch8_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch9_f0_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch9_f0_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch10_f0_0 : signed(CALC_WIDTH-1 downto 0);
      result_ch10_f0_1 : signed(CALC_WIDTH-1 downto 0);
      result_ch11_f0_0 : signed(CALC_WIDTH-1 downto 0);
      result_ch11_f0_1 : signed(CALC_WIDTH-1 downto 0);

      result_ch0_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch0_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch1_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch1_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch2_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch2_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch3_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch3_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch4_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch4_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch5_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch5_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch6_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch6_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch7_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch7_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch8_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch8_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch9_f1_0  : signed(CALC_WIDTH-1 downto 0);
      result_ch9_f1_1  : signed(CALC_WIDTH-1 downto 0);
      result_ch10_f1_0 : signed(CALC_WIDTH-1 downto 0);
      result_ch10_f1_1 : signed(CALC_WIDTH-1 downto 0);
      result_ch11_f1_0 : signed(CALC_WIDTH-1 downto 0);
      result_ch11_f1_1 : signed(CALC_WIDTH-1 downto 0);

--      results      : goertzel_results_type(CHANNELS-1 downto 0, FREQUENCIES-1 downto 0);
--      delays       : goertzel_results_type(CHANNELS-1 downto 0, FREQUENCIES-1 downto 0);
   end record;

   ----------------------------------------------------------------------------
   -- Internal signals
   ----------------------------------------------------------------------------
   signal r, rin : goertzel_type := (
      state           => IDLE,
      channel         => 0,
      frequency       => 0,
      sample_count    => 0,
      done            => '0',
      
      delay_ch0_f0_0  => (others => '0'),
      delay_ch0_f0_1  => (others => '0'),
      delay_ch1_f0_0  => (others => '0'),
      delay_ch1_f0_1  => (others => '0'),
      delay_ch2_f0_0  => (others => '0'),
      delay_ch2_f0_1  => (others => '0'),
      delay_ch3_f0_0  => (others => '0'),
      delay_ch3_f0_1  => (others => '0'),
      delay_ch4_f0_0  => (others => '0'),
      delay_ch4_f0_1  => (others => '0'),
      delay_ch5_f0_0  => (others => '0'),
      delay_ch5_f0_1  => (others => '0'),
      delay_ch6_f0_0  => (others => '0'),
      delay_ch6_f0_1  => (others => '0'),
      delay_ch7_f0_0  => (others => '0'),
      delay_ch7_f0_1  => (others => '0'),
      delay_ch8_f0_0  => (others => '0'),
      delay_ch8_f0_1  => (others => '0'),
      delay_ch9_f0_0  => (others => '0'),
      delay_ch9_f0_1  => (others => '0'),
      delay_ch10_f0_0 => (others => '0'),
      delay_ch10_f0_1 => (others => '0'),
      delay_ch11_f0_0 => (others => '0'),
      delay_ch11_f0_1 => (others => '0'),

      delay_ch0_f1_0  => (others => '0'),
      delay_ch0_f1_1  => (others => '0'),
      delay_ch1_f1_0  => (others => '0'),
      delay_ch1_f1_1  => (others => '0'),
      delay_ch2_f1_0  => (others => '0'),
      delay_ch2_f1_1  => (others => '0'),
      delay_ch3_f1_0  => (others => '0'),
      delay_ch3_f1_1  => (others => '0'),
      delay_ch4_f1_0  => (others => '0'),
      delay_ch4_f1_1  => (others => '0'),
      delay_ch5_f1_0  => (others => '0'),
      delay_ch5_f1_1  => (others => '0'),
      delay_ch6_f1_0  => (others => '0'),
      delay_ch6_f1_1  => (others => '0'),
      delay_ch7_f1_0  => (others => '0'),
      delay_ch7_f1_1  => (others => '0'),
      delay_ch8_f1_0  => (others => '0'),
      delay_ch8_f1_1  => (others => '0'),
      delay_ch9_f1_0  => (others => '0'),
      delay_ch9_f1_1  => (others => '0'),
      delay_ch10_f1_0 => (others => '0'),
      delay_ch10_f1_1 => (others => '0'),
      delay_ch11_f1_0 => (others => '0'),
      delay_ch11_f1_1 => (others => '0'),

      result_ch0_f0_0  => (others => '0'),
      result_ch0_f0_1  => (others => '0'),
      result_ch1_f0_0  => (others => '0'),
      result_ch1_f0_1  => (others => '0'),
      result_ch2_f0_0  => (others => '0'),
      result_ch2_f0_1  => (others => '0'),
      result_ch3_f0_0  => (others => '0'),
      result_ch3_f0_1  => (others => '0'),
      result_ch4_f0_0  => (others => '0'),
      result_ch4_f0_1  => (others => '0'),
      result_ch5_f0_0  => (others => '0'),
      result_ch5_f0_1  => (others => '0'),
      result_ch6_f0_0  => (others => '0'),
      result_ch6_f0_1  => (others => '0'),
      result_ch7_f0_0  => (others => '0'),
      result_ch7_f0_1  => (others => '0'),
      result_ch8_f0_0  => (others => '0'),
      result_ch8_f0_1  => (others => '0'),
      result_ch9_f0_0  => (others => '0'),
      result_ch9_f0_1  => (others => '0'),
      result_ch10_f0_0 => (others => '0'),
      result_ch10_f0_1 => (others => '0'),
      result_ch11_f0_0 => (others => '0'),
      result_ch11_f0_1 => (others => '0'),

      result_ch0_f1_0  => (others => '0'),
      result_ch0_f1_1  => (others => '0'),
      result_ch1_f1_0  => (others => '0'),
      result_ch1_f1_1  => (others => '0'),
      result_ch2_f1_0  => (others => '0'),
      result_ch2_f1_1  => (others => '0'),
      result_ch3_f1_0  => (others => '0'),
      result_ch3_f1_1  => (others => '0'),
      result_ch4_f1_0  => (others => '0'),
      result_ch4_f1_1  => (others => '0'),
      result_ch5_f1_0  => (others => '0'),
      result_ch5_f1_1  => (others => '0'),
      result_ch6_f1_0  => (others => '0'),
      result_ch6_f1_1  => (others => '0'),
      result_ch7_f1_0  => (others => '0'),
      result_ch7_f1_1  => (others => '0'),
      result_ch8_f1_0  => (others => '0'),
      result_ch8_f1_1  => (others => '0'),
      result_ch9_f1_0  => (others => '0'),
      result_ch9_f1_1  => (others => '0'),
      result_ch10_f1_0 => (others => '0'),
      result_ch10_f1_1 => (others => '0'),
      result_ch11_f1_0 => (others => '0'),
      result_ch11_f1_1 => (others => '0')

--      results      => (others => (others => (others => (others => '0')))),
--      delays       => (others => (others => (others => (others => '0'))))
      );

   ----------------------------------------------------------------------------
   -- Debugging signals (variables can't be plotted in GTKwave)
   ----------------------------------------------------------------------------
   signal dbg_coef_s   : signed(CALC_WIDTH-1 downto 0)  := (others => '0');
   signal dbg_input_s  : signed(INPUT_WIDTH-1 downto 0) := (others => '0');
   signal dbg_delay1_s : signed(CALC_WIDTH-1 downto 0)  := (others => '0');
   signal dbg_delay2_s : signed(CALC_WIDTH-1 downto 0)  := (others => '0');
   
   
begin  -- behavioural
   ----------------------------------------------------------------------------
   -- Mapping of signals
   ----------------------------------------------------------------------------
   done_p <= r.done;

--   results_p <= r.results;

   results_p(0, 0)(0)  <= r.result_ch0_f0_0;
   results_p(0, 0)(1)  <= r.result_ch0_f0_1;
   results_p(1, 0)(0)  <= r.result_ch1_f0_0;
   results_p(1, 0)(1)  <= r.result_ch1_f0_1;
   results_p(2, 0)(0)  <= r.result_ch2_f0_0;
   results_p(2, 0)(1)  <= r.result_ch2_f0_1;
   results_p(3, 0)(0)  <= r.result_ch3_f0_0;
   results_p(3, 0)(1)  <= r.result_ch3_f0_1;
   results_p(4, 0)(0)  <= r.result_ch4_f0_0;
   results_p(4, 0)(1)  <= r.result_ch4_f0_1;
   results_p(5, 0)(0)  <= r.result_ch5_f0_0;
   results_p(5, 0)(1)  <= r.result_ch5_f0_1;
   results_p(6, 0)(0)  <= r.result_ch6_f0_0;
   results_p(6, 0)(1)  <= r.result_ch6_f0_1;
   results_p(7, 0)(0)  <= r.result_ch7_f0_0;
   results_p(7, 0)(1)  <= r.result_ch7_f0_1;
   results_p(8, 0)(0)  <= r.result_ch8_f0_0;
   results_p(8, 0)(1)  <= r.result_ch8_f0_1;
   results_p(9, 0)(0)  <= r.result_ch9_f0_0;
   results_p(9, 0)(1)  <= r.result_ch9_f0_1;
   results_p(10, 0)(0) <= r.result_ch10_f0_0;
   results_p(10, 0)(1) <= r.result_ch10_f0_1;
   results_p(11, 0)(0) <= r.result_ch11_f0_0;
   results_p(11, 0)(1) <= r.result_ch11_f0_1;

   results_p(0, 1)(0)  <= r.result_ch0_f1_0;
   results_p(0, 1)(1)  <= r.result_ch0_f1_1;
   results_p(1, 1)(0)  <= r.result_ch1_f1_0;
   results_p(1, 1)(1)  <= r.result_ch1_f1_1;
   results_p(2, 1)(0)  <= r.result_ch2_f1_0;
   results_p(2, 1)(1)  <= r.result_ch2_f1_1;
   results_p(3, 1)(0)  <= r.result_ch3_f1_0;
   results_p(3, 1)(1)  <= r.result_ch3_f1_1;
   results_p(4, 1)(0)  <= r.result_ch4_f1_0;
   results_p(4, 1)(1)  <= r.result_ch4_f1_1;
   results_p(5, 1)(0)  <= r.result_ch5_f1_0;
   results_p(5, 1)(1)  <= r.result_ch5_f1_1;
   results_p(6, 1)(0)  <= r.result_ch6_f1_0;
   results_p(6, 1)(1)  <= r.result_ch6_f1_1;
   results_p(7, 1)(0)  <= r.result_ch7_f1_0;
   results_p(7, 1)(1)  <= r.result_ch7_f1_1;
   results_p(8, 1)(0)  <= r.result_ch8_f1_0;
   results_p(8, 1)(1)  <= r.result_ch8_f1_1;
   results_p(9, 1)(0)  <= r.result_ch9_f1_0;
   results_p(9, 1)(1)  <= r.result_ch9_f1_1;
   results_p(10, 1)(0) <= r.result_ch10_f1_0;
   results_p(10, 1)(1) <= r.result_ch10_f1_1;
   results_p(11, 1)(0) <= r.result_ch11_f1_0;
   results_p(11, 1)(1) <= r.result_ch11_f1_1;

   ----------------------------------------------------------------------------
   -- Sequential part of FSM
   ----------------------------------------------------------------------------
   seq_proc : process (clk)
   begin  -- process seq_proc
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   ----------------------------------------------------------------------------
   -- Transitions and actions of FSM
   ----------------------------------------------------------------------------
   comb_proc : process (coefs_p, inputs_p, r, start_p)
      variable v        : goertzel_type;
      variable prod1    : signed(2*CALC_WIDTH-1 downto 0) := (others => '0');
      variable prod1_sc : signed(CALC_WIDTH-1 downto 0)   := (others => '0');
      variable sum1     : signed(CALC_WIDTH-1 downto 0)   := (others => '0');

      variable coef   : signed(CALC_WIDTH-1 downto 0) := (others => '0');
      variable delay1 : signed(CALC_WIDTH-1 downto 0) := (others => '0');
      variable delay2 : signed(CALC_WIDTH-1 downto 0) := (others => '0');

      variable input : signed(INPUT_WIDTH-1 downto 0) := (others => '0');

      variable channel   : natural range CHANNELS-1 downto 0    := 0;
      variable frequency : natural range FREQUENCIES-1 downto 0 := 0;

   begin  -- process comb_proc
      v := r;

      channel   := r.channel;
      frequency := r.frequency;

      v.done := '0';                    -- done is a clock enable and is only
                                        -- high for one period

      -- multiplex inputs
      coef  := signed(coefs_p(r.frequency));
      input := inputs_p(r.channel);

      -- This does not work with ISE
--      delay1 := r.delays(r.channel, r.frequency)(0);
--      delay2 := r.delays(r.channel, r.frequency)(1);
-- Do it manually instaed:
      case frequency is
         when 0 =>
            case channel is
               when 0 =>
                  delay1 := r.delay_ch0_f0_0;
                  delay2 := r.delay_ch0_f0_1;
               when 1 =>
                  delay1 := r.delay_ch1_f0_0;
                  delay2 := r.delay_ch1_f0_1;
               when 2 =>
                  delay1 := r.delay_ch2_f0_0;
                  delay2 := r.delay_ch2_f0_1;
               when 3 =>
                  delay1 := r.delay_ch3_f0_0;
                  delay2 := r.delay_ch3_f0_1;
               when 4 =>
                  delay1 := r.delay_ch4_f0_0;
                  delay2 := r.delay_ch4_f0_1;
               when 5 =>
                  delay1 := r.delay_ch5_f0_0;
                  delay2 := r.delay_ch5_f0_1;
               when 6 =>
                  delay1 := r.delay_ch6_f0_0;
                  delay2 := r.delay_ch6_f0_1;
               when 7 =>
                  delay1 := r.delay_ch7_f0_0;
                  delay2 := r.delay_ch7_f0_1;
               when 8 =>
                  delay1 := r.delay_ch8_f0_0;
                  delay2 := r.delay_ch8_f0_1;
               when 9 =>
                  delay1 := r.delay_ch9_f0_0;
                  delay2 := r.delay_ch9_f0_1;
               when 10 =>
                  delay1 := r.delay_ch10_f0_0;
                  delay2 := r.delay_ch10_f0_1;
               when 11 =>
                  delay1 := r.delay_ch11_f0_0;
                  delay2 := r.delay_ch11_f0_1;
               when others => null;
            end case;
         when 1 =>
            case channel is
               when 0 =>
                  delay1 := r.delay_ch0_f1_0;
                  delay2 := r.delay_ch0_f1_1;
               when 1 =>
                  delay1 := r.delay_ch1_f1_0;
                  delay2 := r.delay_ch1_f1_1;
               when 2 =>
                  delay1 := r.delay_ch2_f1_0;
                  delay2 := r.delay_ch2_f1_1;
               when 3 =>
                  delay1 := r.delay_ch3_f1_0;
                  delay2 := r.delay_ch3_f1_1;
               when 4 =>
                  delay1 := r.delay_ch4_f1_0;
                  delay2 := r.delay_ch4_f1_1;
               when 5 =>
                  delay1 := r.delay_ch5_f1_0;
                  delay2 := r.delay_ch5_f1_1;
               when 6 =>
                  delay1 := r.delay_ch6_f1_0;
                  delay2 := r.delay_ch6_f1_1;
               when 7 =>
                  delay1 := r.delay_ch7_f1_0;
                  delay2 := r.delay_ch7_f1_1;
               when 8 =>
                  delay1 := r.delay_ch8_f1_0;
                  delay2 := r.delay_ch8_f1_1;
               when 9 =>
                  delay1 := r.delay_ch9_f1_0;
                  delay2 := r.delay_ch9_f1_1;
               when 10 =>
                  delay1 := r.delay_ch10_f1_0;
                  delay2 := r.delay_ch10_f1_1;
               when 11 =>
                  delay1 := r.delay_ch11_f1_0;
                  delay2 := r.delay_ch11_f1_1;
               when others => null;
            end case;
				when others => null;
      end case;

      -- debug signals
      dbg_coef_s   <= coef;
      dbg_input_s  <= input;
      dbg_delay1_s <= delay1;
      dbg_delay2_s <= delay2;

      -- iterate channels and frquencies
      case r.state is
         when IDLE =>
            if start_p = '1' then
               v.state := CALC;

               if r.sample_count = SAMPLES-1 then
                  v.sample_count := 0;

                  -- one packet of SAMPLES samples done, store results of current packet
--                  v.results := v.delays;
                  v.result_ch0_f0_0  := v.delay_ch0_f0_0;
                  v.result_ch0_f0_1  := v.delay_ch0_f0_1;
                  v.result_ch1_f0_0  := v.delay_ch1_f0_0;
                  v.result_ch1_f0_1  := v.delay_ch1_f0_1;
                  v.result_ch2_f0_0  := v.delay_ch2_f0_0;
                  v.result_ch2_f0_1  := v.delay_ch2_f0_1;
                  v.result_ch3_f0_0  := v.delay_ch3_f0_0;
                  v.result_ch3_f0_1  := v.delay_ch3_f0_1;
                  v.result_ch4_f0_0  := v.delay_ch4_f0_0;
                  v.result_ch4_f0_1  := v.delay_ch4_f0_1;
                  v.result_ch5_f0_0  := v.delay_ch5_f0_0;
                  v.result_ch5_f0_1  := v.delay_ch5_f0_1;
                  v.result_ch6_f0_0  := v.delay_ch6_f0_0;
                  v.result_ch6_f0_1  := v.delay_ch6_f0_1;
                  v.result_ch7_f0_0  := v.delay_ch7_f0_0;
                  v.result_ch7_f0_1  := v.delay_ch7_f0_1;
                  v.result_ch8_f0_0  := v.delay_ch8_f0_0;
                  v.result_ch8_f0_1  := v.delay_ch8_f0_1;
                  v.result_ch9_f0_0  := v.delay_ch9_f0_0;
                  v.result_ch9_f0_1  := v.delay_ch9_f0_1;
                  v.result_ch10_f0_0 := v.delay_ch10_f0_0;
                  v.result_ch10_f0_1 := v.delay_ch10_f0_1;
                  v.result_ch11_f0_0 := v.delay_ch11_f0_0;
                  v.result_ch11_f0_1 := v.delay_ch11_f0_1;

                  v.result_ch0_f1_0  := v.delay_ch0_f1_0;
                  v.result_ch0_f1_1  := v.delay_ch0_f1_1;
                  v.result_ch1_f1_0  := v.delay_ch1_f1_0;
                  v.result_ch1_f1_1  := v.delay_ch1_f1_1;
                  v.result_ch2_f1_0  := v.delay_ch2_f1_0;
                  v.result_ch2_f1_1  := v.delay_ch2_f1_1;
                  v.result_ch3_f1_0  := v.delay_ch3_f1_0;
                  v.result_ch3_f1_1  := v.delay_ch3_f1_1;
                  v.result_ch4_f1_0  := v.delay_ch4_f1_0;
                  v.result_ch4_f1_1  := v.delay_ch4_f1_1;
                  v.result_ch5_f1_0  := v.delay_ch5_f1_0;
                  v.result_ch5_f1_1  := v.delay_ch5_f1_1;
                  v.result_ch6_f1_0  := v.delay_ch6_f1_0;
                  v.result_ch6_f1_1  := v.delay_ch6_f1_1;
                  v.result_ch7_f1_0  := v.delay_ch7_f1_0;
                  v.result_ch7_f1_1  := v.delay_ch7_f1_1;
                  v.result_ch8_f1_0  := v.delay_ch8_f1_0;
                  v.result_ch8_f1_1  := v.delay_ch8_f1_1;
                  v.result_ch9_f1_0  := v.delay_ch9_f1_0;
                  v.result_ch9_f1_1  := v.delay_ch9_f1_1;
                  v.result_ch10_f1_0 := v.delay_ch10_f1_0;
                  v.result_ch10_f1_1 := v.delay_ch10_f1_1;
                  v.result_ch11_f1_0 := v.delay_ch11_f1_0;
                  v.result_ch11_f1_1 := v.delay_ch11_f1_1;

                  v.done := '1';

                  -- reset all delay registers
--                  v.delays := (others => (others => (others => (others => '0'))));
                  v.delay_ch0_f0_0  := (others => '0');
                  v.delay_ch0_f0_1  := (others => '0');
                  v.delay_ch1_f0_0  := (others => '0');
                  v.delay_ch1_f0_1  := (others => '0');
                  v.delay_ch2_f0_0  := (others => '0');
                  v.delay_ch2_f0_1  := (others => '0');
                  v.delay_ch3_f0_0  := (others => '0');
                  v.delay_ch3_f0_1  := (others => '0');
                  v.delay_ch4_f0_0  := (others => '0');
                  v.delay_ch4_f0_1  := (others => '0');
                  v.delay_ch5_f0_0  := (others => '0');
                  v.delay_ch5_f0_1  := (others => '0');
                  v.delay_ch6_f0_0  := (others => '0');
                  v.delay_ch6_f0_1  := (others => '0');
                  v.delay_ch7_f0_0  := (others => '0');
                  v.delay_ch7_f0_1  := (others => '0');
                  v.delay_ch8_f0_0  := (others => '0');
                  v.delay_ch8_f0_1  := (others => '0');
                  v.delay_ch9_f0_0  := (others => '0');
                  v.delay_ch9_f0_1  := (others => '0');
                  v.delay_ch10_f0_0 := (others => '0');
                  v.delay_ch10_f0_1 := (others => '0');
                  v.delay_ch11_f0_0 := (others => '0');
                  v.delay_ch11_f0_1 := (others => '0');

                  v.delay_ch0_f1_0  := (others => '0');
                  v.delay_ch0_f1_1  := (others => '0');
                  v.delay_ch1_f1_0  := (others => '0');
                  v.delay_ch1_f1_1  := (others => '0');
                  v.delay_ch2_f1_0  := (others => '0');
                  v.delay_ch2_f1_1  := (others => '0');
                  v.delay_ch3_f1_0  := (others => '0');
                  v.delay_ch3_f1_1  := (others => '0');
                  v.delay_ch4_f1_0  := (others => '0');
                  v.delay_ch4_f1_1  := (others => '0');
                  v.delay_ch5_f1_0  := (others => '0');
                  v.delay_ch5_f1_1  := (others => '0');
                  v.delay_ch6_f1_0  := (others => '0');
                  v.delay_ch6_f1_1  := (others => '0');
                  v.delay_ch7_f1_0  := (others => '0');
                  v.delay_ch7_f1_1  := (others => '0');
                  v.delay_ch8_f1_0  := (others => '0');
                  v.delay_ch8_f1_1  := (others => '0');
                  v.delay_ch9_f1_0  := (others => '0');
                  v.delay_ch9_f1_1  := (others => '0');
                  v.delay_ch10_f1_0 := (others => '0');
                  v.delay_ch10_f1_1 := (others => '0');
                  v.delay_ch11_f1_0 := (others => '0');
                  v.delay_ch11_f1_1 := (others => '0');


               else
                  v.sample_count := r.sample_count + 1;
               end if;
            end if;
            
         when CALC =>
            -- calculating, only use the multiplexed signals

            prod1    := delay1 * coef;
            prod1_sc := prod1((Q + CALC_WIDTH - 1) downto Q);

            -- TODO detect overflow

            sum1 := input + prod1_sc - delay2;

            delay2 := delay1;
            delay1 := sum1;

            -- advance frequency and channel
            if r.channel = CHANNELS-1 then
               v.channel := 0;

               if r.frequency = FREQUENCIES-1 then
                  v.frequency := 0;
                  v.state     := IDLE;
               else
                  v.frequency := r.frequency + 1;
               end if;
            else
               v.channel := r.channel + 1;
            end if;
      end case;

      -- multiplex output

      -- This crashes lame ISE
      --     v.delays(r.channel, r.frequency)(0) := delay1;
      --     v.delays(r.channel, r.frequency)(1) := delay2;

      case frequency is
         when 0 =>
            case channel is
               when 0 =>
                  v.delay_ch0_f0_0 := delay1;
                  v.delay_ch0_f0_1 := delay2;
               when 1 =>
                  v.delay_ch1_f0_0 := delay1;
                  v.delay_ch1_f0_1 := delay2;
               when 2 =>
                  v.delay_ch2_f0_0 := delay1;
                  v.delay_ch2_f0_1 := delay2;
               when 3 =>
                  v.delay_ch3_f0_0 := delay1;
                  v.delay_ch3_f0_1 := delay2;
               when 4 =>
                  v.delay_ch4_f0_0 := delay1;
                  v.delay_ch4_f0_1 := delay2;
               when 5 =>
                  v.delay_ch5_f0_0 := delay1;
                  v.delay_ch5_f0_1 := delay2;
               when 6 =>
                  v.delay_ch6_f0_0 := delay1;
                  v.delay_ch6_f0_1 := delay2;
               when 7 =>
                  v.delay_ch7_f0_0 := delay1;
                  v.delay_ch7_f0_1 := delay2;
               when 8 =>
                  v.delay_ch8_f0_0 := delay1;
                  v.delay_ch8_f0_1 := delay2;
               when 9 =>
                  v.delay_ch9_f0_0 := delay1;
                  v.delay_ch9_f0_1 := delay2;
               when 10 =>
                  v.delay_ch10_f0_0 := delay1;
                  v.delay_ch10_f0_1 := delay2;
               when 11 =>
                  v.delay_ch11_f0_0 := delay1;
                  v.delay_ch11_f0_1 := delay2;
               when others => null;
            end case;
         when 1 =>
            case channel is
               when 0 =>
                  v.delay_ch0_f1_0 := delay1;
                  v.delay_ch0_f1_1 := delay2;
               when 1 =>
                  v.delay_ch1_f1_0 := delay1;
                  v.delay_ch1_f1_1 := delay2;
               when 2 =>
                  v.delay_ch2_f1_0 := delay1;
                  v.delay_ch2_f1_1 := delay2;
               when 3 =>
                  v.delay_ch3_f1_0 := delay1;
                  v.delay_ch3_f1_1 := delay2;
               when 4 =>
                  v.delay_ch4_f1_0 := delay1;
                  v.delay_ch4_f1_1 := delay2;
               when 5 =>
                  v.delay_ch5_f1_0 := delay1;
                  v.delay_ch5_f1_1 := delay2;
               when 6 =>
                  v.delay_ch6_f1_0 := delay1;
                  v.delay_ch6_f1_1 := delay2;
               when 7 =>
                  v.delay_ch7_f1_0 := delay1;
                  v.delay_ch7_f1_1 := delay2;
               when 8 =>
                  v.delay_ch8_f1_0 := delay1;
                  v.delay_ch8_f1_1 := delay2;
               when 9 =>
                  v.delay_ch9_f1_0 := delay1;
                  v.delay_ch9_f1_1 := delay2;
               when 10 =>
                  v.delay_ch10_f1_0 := delay1;
                  v.delay_ch10_f1_1 := delay2;
               when 11 =>
                  v.delay_ch11_f1_0 := delay1;
                  v.delay_ch11_f1_1 := delay2;
               when others => null;
            end case;
				when others => null;
      end case;
      rin <= v;

   end process comb_proc;

end behavioural;
