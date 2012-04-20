-------------------------------------------------------------------------------
-- Title      : Fixed point implementation of Goertzel's Algorithm
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-15
-- Last update: 2012-04-20
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
      state        : goertzel_state_type;
      channel      : natural range 0 to CHANNELS-1;
      frequency    : natural range 0 to FREQUENCIES-1;
      sample_count : natural range 0 to SAMPLES-1;
      done         : std_logic;
      results      : goertzel_results_type(CHANNELS-1 downto 0, FREQUENCIES-1 downto 0);
      delays       : goertzel_results_type(CHANNELS-1 downto 0, FREQUENCIES-1 downto 0);
   end record;

   ----------------------------------------------------------------------------
   -- Internal signals
   ----------------------------------------------------------------------------
   signal r, rin : goertzel_type := (
      state        => IDLE,
      channel      => 0,
      frequency    => 0,
      sample_count => 0,
      done         => '0',
      results      => (others => (others => (others => (others => '0')))),
      delays       => (others => (others => (others => (others => '0'))))
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
   done_p    <= r.done;
   results_p <= r.results;

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
   comb_proc : process (r, start_p)
      variable v        : goertzel_type;
      variable prod1    : signed(2*CALC_WIDTH-1 downto 0) := (others => '0');
      variable prod1_sc : signed(CALC_WIDTH-1 downto 0)   := (others => '0');
      variable sum1     : signed(CALC_WIDTH-1 downto 0)   := (others => '0');

      variable coef   : signed(CALC_WIDTH-1 downto 0) := (others => '0');
      variable delay1 : signed(CALC_WIDTH-1 downto 0) := (others => '0');
      variable delay2 : signed(CALC_WIDTH-1 downto 0) := (others => '0');

      variable input : signed(INPUT_WIDTH-1 downto 0) := (others => '0');

   begin  -- process comb_proc
      v := r;

      v.done := '0';                    -- done is a clock enable and is only
                                        -- high for one period

      -- multiplex inputs
      coef   := signed(coefs_p(r.frequency));
      input  := inputs_p(r.channel);
      delay1 := r.delays(r.channel, r.frequency)(0);
      delay2 := r.delays(r.channel, r.frequency)(1);

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
                  v.results := v.delays;

                  v.done := '1';

                  -- reset all delay registers
                  v.delays := (others => (others => (others => (others => '0'))));
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

            -- multiplex output
            v.delays(r.channel, r.frequency)(0) := delay1;
            v.delays(r.channel, r.frequency)(1) := delay2;

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

      rin <= v;

   end process comb_proc;

end behavioural;
