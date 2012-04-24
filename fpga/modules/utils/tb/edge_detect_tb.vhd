-------------------------------------------------------------------------------
-- Title      : Testbench for design "edge_detect"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : edge_detect_tb.vhd
-- Author     : Lothar Miller
-- Company    : 
-- Created    : 2012-04-23
-- Last update: 2012-04-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.utils_pkg.all;

-------------------------------------------------------------------------------

entity edge_detect_tb is

end entity edge_detect_tb;

-------------------------------------------------------------------------------

architecture tb of edge_detect_tb is

   --Inputs
   signal async_sig : std_logic := '0';

   --Outputs
   signal rise : std_logic;
   signal fall : std_logic;

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   uut : edge_detect
      port map (
         async_sig => async_sig,
         clk       => clk,
         rise      => rise,
         fall      => fall);

   -- clock generation
   clk <= not clk after 5 ns;

   -- Create an asynchronous, random signal
   stim : process
      variable seed1, seed2 : positive;
      variable Rand         : real;
      variable IRand        : integer;
   begin
      -- Zufallszahl ziwschen 0 und 1
      uniform(seed1, seed2, rand);
      -- daraus ein Integer zwischen 50 und 150
      irand     := integer((rand*100.0 - 0.5) + 50.0);
      -- und dann diese Zeit abwarten
      wait for irand * 1 ns;
      async_sig <= not async_sig;
   end process;
   
end architecture tb;

-------------------------------------------------------------------------------
