
library ieee;
use ieee.std_logic_1164.all;

package utils_pkg is
  component clock_divider is
    generic (
      DIVIDER : positive := 2
      );
    port (
      clk_out_p : out std_logic;
      clk       : in  std_logic
      );
  end component;
end package utils_pkg;
