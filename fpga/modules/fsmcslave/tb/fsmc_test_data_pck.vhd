
library ieee;
use ieee.std_logic_1164.all;

library work;

package fsmc_test_data_pkg is
   constant N_TEST_DATA : natural := 20;
   subtype test_data_t is std_logic_vector(15 downto 0);
   type test_data_lut_t is array (0 to N_TEST_DATA-1) of test_data_t;
   constant TEST_DATA : test_data_lut_t := (
      X"1993", X"00ff", X"ff00", X"1234", X"0a0a",
      X"0e1f", X"9876", X"e3e1", X"dead", X"face",
      X"dead", X"baad", X"00ba", X"b10c", X"0000",
      X"cafe", X"d00d", X"dead", X"babe", X"c0de"
      );

end package fsmc_test_data_pkg;
