
library ieee;
use ieee.std_logic_1164.all;

package pwm_pkg is
  component pwm
    generic (
      WIDTH : natural);
    port (
      clk_en_p : in  std_logic;
      value_p  : in  std_logic_vector (width - 1 downto 0);
      output_p : out std_logic;
      reset    : in  std_logic;
      clk      : in  std_logic);
  end component;
end package pwm_pkg;

