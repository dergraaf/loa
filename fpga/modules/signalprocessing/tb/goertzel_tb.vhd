-------------------------------------------------------------------------------
-- Title      : Testbench for design "goertzel"
-------------------------------------------------------------------------------
-- Author     : strongly-typed
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

entity goertzel_tb is

end goertzel_tb;

-------------------------------------------------------------------------------

architecture tb of goertzel_tb is

   -- component generics
   constant SAMPLES     : natural := 250;
   constant INPUT_WIDTH : natural := 14;
   constant CALC_WIDTH  : natural := 18;
   constant Q           : natural := 13;

   -- component ports
   signal start_p     : std_logic;
   signal adc_value_p : signed(INPUT_WIDTH-1 downto 0) := (others => '0');
   signal result_p    : goertzel_result_type;
   signal done_s      : std_logic;

   -- clock
   signal clk : std_logic := '1';

   -- signal generation
   signal PHASE : real := 0.0;

   constant SCALE  : real := 2.0**7 - 10.0;
   constant OFFSET : real := 2.0**13;

   constant FSAMPLE : real := 75000.0;  -- Sample Frequency in Hertz
   constant FSIGNAL : real := 16750.0;  -- Signal Frequency in Hertz

   signal PHASE_INCREMENT : real := 2.0 * 3.1415 * FSIGNAL / FSAMPLE;

   -- calculate Goertzel Coefficient
   -- TODO
   constant COEF : unsigned := to_unsigned(2732, CALC_WIDTH);

   -- debugging signal for goertzel
   signal goertzel_value_s : real := 0.0;

   
begin  -- tb

   -- component instantiation
   DUT : goertzel
      generic map (
         Q           => Q,
         SAMPLES     => SAMPLES
         )
      port map (
         clk         => clk,
         coef_p      => COEF,
         start_p     => start_p,
         adc_value_p => adc_value_p,
         result_p    => result_p,
         done_p      => done_s
         );

   -- clock generation
   clk <= not clk after 20 ns;

   -- every 5 clock cycles a start_p signal from ADC
   start_gen_proc : process
   begin  -- process start_gen_proc
      start_p <= '0';
      wait until clk = '1';
      start_p <= '1';
      wait until clk = '1';
      start_p <= '0';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
   end process start_gen_proc;

   -- Test signal waveform generation
   WaveGen_Proc : process
   begin
      for n in 0 to 10000 loop
         wait until start_p = '1';

         -- raw ADC values
         -- adc_value_p   <= std_logic_vector(to_unsigned(integer(offset + scale*sin(phase)), 14));

         -- signed values
         adc_value_p <= to_signed(integer(SCALE * sin(PHASE)), INPUT_WIDTH);

         -- test
         -- adc_value_p <= "00000000001000";       

         PHASE <= PHASE + PHASE_INCREMENT;
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
      -- only the upper 16 bits of result_p are stored, so do not shift by 18
      -- bits. 

      d1 := real(to_integer(result_p(0))) / 2.0**(Q-2);
      d2 := real(to_integer(result_p(1))) / 2.0**(Q-2);
      c  := real(to_integer(coef)) / 2.0**Q;

      -- calculate goertzel value
      goertzel_value_s <= d1**2 + d2**2 - (d2 * d1 * c);
      
      
   end process GoertzelCheck_proc;

   
   
end tb;
