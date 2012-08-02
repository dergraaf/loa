-------------------------------------------------------------------------------
-- Title      : Fixed point implementation of Goertzel's Algorithm
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-15
-- Last update: 2012-08-01
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Fixed point implementation of Goertzel's Algorithm to detect a
-- fixed frequency in an analog signal. This does not implement the calculation
-- of the magnitude of the signal at the end of one block.
-- Mind overflows!
-- This implementation only calulates one channel and one frequency. For each
-- channel and each frequency this needs another multiplier. So this is not
-- used any more. 
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

entity goertzel is
   generic (
      -- Width of ADC input
      -- Due to overflow prevention: Not as wide as the internal width of
      -- calculations. 
      INPUT_WIDTH : natural := 14;

      -- Width of internal calculations
      -- Remember that internal multiplier are 18 bits wide (in Xilinx Spartan)
      CALC_WIDTH : natural := 18;

      -- Fixed point data format
      Q : natural := 13;

      -- Number of samples used to detect a frequency.
      -- After SAMPLES samples new goertzel values are available. 
      SAMPLES : natural := 250
      );
   port (
      coef_p : in unsigned(CALC_WIDTH-1 downto 0);

      start_p : in std_logic;           -- clock enable, is high when new value
                                        -- from ADC is available. 

      adc_value_p : in signed(INPUT_WIDTH-1 downto 0);

      result_p : out goertzel_result_type;
      done_p   : out std_logic;         -- clock enable outut, is high when new
                                        -- result was generated

      clk : in std_logic
      );

end goertzel;

architecture behavioural of goertzel is

   ----------------------------------------------------------------------------
   -- Types
   ----------------------------------------------------------------------------
   type goertzel_state_type is (
      IDLE,
      CALC1
      );

   type goertzel_type is record
      state        : goertzel_state_type;
      done         : std_logic;
      delay0       : signed(CALC_WIDTH-1 downto 0);
      delay1       : signed(CALC_WIDTH-1 downto 0);
      delay2       : signed(CALC_WIDTH-1 downto 0);
      result       : goertzel_result_type;
      sample_count : natural;
      
   end record;

   ----------------------------------------------------------------------------
   -- Internal signals
   ----------------------------------------------------------------------------
   signal r, rin : goertzel_type := (
      state        => IDLE,
      sample_count => 1,
      done         => '0',
      delay0       => (others => '0'),
      delay1       => (others => '0'),
      delay2       => (others => '0'),
      result       => (others => (others => '0'))
      );

begin  -- behavioural
   ----------------------------------------------------------------------------
   -- Mapping of signals
   ----------------------------------------------------------------------------
   done_p   <= r.done;
   result_p <= r.result;

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
   comb_proc : process (adc_value_p, coef_p, r, rin, start_p)
      variable v        : goertzel_type;
      variable prod1    : signed(2*CALC_WIDTH-1 downto 0) := (others => '0');
      variable prod1_sc : signed(CALC_WIDTH-1 downto 0)   := (others => '0');
      variable coef     : signed(CALC_WIDTH-1 downto 0);

   begin  -- process comb_proc
      v    := r;
      coef := signed(coef_p);

      case r.state is
         when IDLE =>
            v.done := '0';
            if start_p = '1' then
               v.state := CALC1;

               -- prod1 := (self.history[1] * coef);
               prod1    := r.delay1 * coef;
               prod1_sc := prod1((Q + CALC_WIDTH - 1) downto Q);

               -- self.history[0]   = float(self.input.get())/(2**self.Q) + prod1   - self.history[2]
               v.delay0 := adc_value_p + prod1_sc - r.delay2;

               -- remember old values
               v.delay1 := v.delay0;
               v.delay2 := r.delay1;

               if r.sample_count = SAMPLES then
                  v.sample_count := 0;

                  -- store results of current packet, only the upper 16 bits
                  -- for STM. 
                  v.result(0) := v.delay1;
                  v.result(1) := v.delay2;
                  v.done      := '1';

                  -- reset delay registers
                  v.delay1 := (others => '0');
                  v.delay2 := (others => '0');
               else
                  v.sample_count := r.sample_count + 1;
               end if;
            end if;
         when CALC1 =>
            v.state := IDLE;
      end case;

      rin <= v;
     
   end process comb_proc;

end behavioural;
