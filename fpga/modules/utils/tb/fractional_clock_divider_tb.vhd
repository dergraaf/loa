
library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity fractional_clock_divider_tb is
end fractional_clock_divider_tb;

architecture tb of fractional_clock_divider_tb is
   signal clk    : std_logic := '0';
   signal output : std_logic;
begin
   clk <= not clk after 10 NS;          -- 50 Mhz clock

   uut : fractional_clock_divider
      generic map (
         MUL => 3,
         DIV => 5)
      port map(
         clk_out_p => output,
         clk       => clk);
end tb;
