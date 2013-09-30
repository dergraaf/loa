-------------------------------------------------------------------------------
-- Title      : Testbench for serialiser
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity serialiser_tb is

end serialiser_tb;

-------------------------------------------------------------------------------

architecture tb of serialiser_tb is

   use work.utils_pkg.all;

   -- Component generics
   constant BITPATTERN_WIDTH : integer := 16;

   -- Signals for component ports
   signal pattern   : std_logic_vector(BITPATTERN_WIDTH - 1 downto 0) := (others => '0');
   signal bitstream : std_logic;

   signal clk_bit : std_logic := '0';
   signal clk     : std_logic := '0';

begin  -- tb

   ---------------------------------------------------------------------------
   -- component instatiation
   ---------------------------------------------------------------------------

   serialiser_1 : entity work.serialiser
      generic map (
         BITPATTERN_WIDTH => BITPATTERN_WIDTH)
      port map (
         pattern_in_p    => pattern,
         bitstream_out_p => bitstream,
         clk_bit         => clk_bit,
         clk             => clk);

   -------------------------------------------------------------------------------
   -- Stimuli
   -------------------------------------------------------------------------------

   -- clock generation, 50 MHz
   clk <= not clk after 10 ns;

   -- Bit clock
   -- 50 MHz / 25000 = 2 kHz
   -- For testbench 200 kHz
   fractional_clock_divider_1 : entity work.fractional_clock_divider
      generic map (
         DIV => 250,
         MUL => 1)
      port map (
         clk_out_p => clk_bit,
         clk       => clk);

   pattern <= x"8000";

end tb;
