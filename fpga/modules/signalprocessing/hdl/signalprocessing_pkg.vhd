-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bus_pkg.all;
use work.adc_ltc2351_pkg.all;

-------------------------------------------------------------------------------

package signalprocessing_pkg is

   type goertzel_result_type is array (1 downto 0) of signed(15 downto 0);

   component goertzel
      generic (
         INPUT_WIDTH : natural;
         CALC_WIDTH  : natural;
         Q           : natural;
         SAMPLES     : natural
         );
      port (
         clk         : in  std_logic;
         coef_p      : in  unsigned(17 downto 0);
         start_p     : in  std_logic;
         adc_value_p : in  signed(13 downto 0);
         result_p    : out goertzel_result_type;
         done_p      : out std_logic
         );
   end component;

end signalprocessing_pkg;
