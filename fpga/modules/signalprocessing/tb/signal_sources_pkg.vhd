library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


package signal_sources_pkg is
   component source_sine is
      generic (
         DATA_WIDTH         : positive;
         AMPLITUDE          : real;
         SIGNAL_FREQUENCY   : real;
         SAMPLING_FREQUENCY : real);
      port (
         start_i  : in  std_logic;
         signal_o : out signed(DATA_WIDTH-1 downto 0));
   end component source_sine;
end package signal_sources_pkg;
