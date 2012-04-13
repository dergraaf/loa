
library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity fractional_clock_divider_variable_tb is
end fractional_clock_divider_variable_tb;

architecture tb of fractional_clock_divider_variable_tb is
   signal clk    : std_logic := '0';
   signal output : std_logic;
begin
   clk <= not clk after 10 ns;          -- 50 Mhz clock

   uut : fractional_clock_divider_variable
      generic map (
         WIDTH => 16)
      port map (
         div => x"05f4",
         mul => x"0001",   
         clk_out_p => output,
         clk       => clk);
end tb;
