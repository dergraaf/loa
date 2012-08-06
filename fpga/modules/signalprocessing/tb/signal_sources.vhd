-------------------------------------------------------------------------------
-- Title      : Common Signal Sources for Testbenches
-- Project    : 
-------------------------------------------------------------------------------
-- File       : signal_sources.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-05-03
-- Last update: 2012-08-05
-- Platform   : 
-- Standard   : VHDL'93/02
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
use work.signal_sources_pkg.all;

entity source_sine is   
   generic (
      DATA_WIDTH         : positive := 10;
      AMPLITUDE          : real     := 1.0;
      SIGNAL_FREQUENCY   : real     := 16000.0;
      SAMPLING_FREQUENCY : real     := 75000.0);
   port (
      start_i  : in  std_logic;
      signal_o : out signed(DATA_WIDTH-1 downto 0));
end entity source_sine;

architecture behavourial of source_sine is

begin  -- architecture behavourial

   WaveGen: process
      variable phase : real := 0.0;
      variable phase_increment : real := MATH_2_PI * SIGNAL_FREQUENCY / SAMPLING_FREQUENCY;
   begin  -- process WaveGen
      phase := phase + phase_increment;
      signal_o <= to_signed(integer(AMPLITUDE * sin(phase)), DATA_WIDTH);
      wait until start_i = '1';
   end process WaveGen;

end architecture behavourial;
