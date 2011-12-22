
library ieee;
use ieee.std_logic_1164.all;

package utils_pkg is
   
   component clock_divider is
      generic (
         DIV : positive);
      port (
         clk_out_p : out std_logic;
         clk       : in  std_logic);
   end component;

   component fractional_clock_divider is
      generic (
         DIV : positive;
         MUL : positive);
      port (
         clk_out_p : out std_logic;
         clk       : in  std_logic);
   end component fractional_clock_divider;
   
end package utils_pkg;
