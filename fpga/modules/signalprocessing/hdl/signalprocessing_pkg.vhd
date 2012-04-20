-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.bus_pkg.all;
use work.adc_ltc2351_pkg.all;

-------------------------------------------------------------------------------

package signalprocessing_pkg is

   constant CALC_WIDTH  : natural := 18;  -- Width of all calculations.
   constant INPUT_WIDTH : natural := 14;  -- Width of ADC values

   -- The result of the Goertzel Algorithm are two values
   type goertzel_result_type is array (1 downto 0) of signed(CALC_WIDTH-1 downto 0);

   -- The result for more channels and frequencies:
   type goertzel_results_type is array (natural range <>, natural range <>) of goertzel_result_type;

   -- The input for different channels
   type goertzel_inputs_type is array (natural range <>) of signed(INPUT_WIDTH-1 downto 0);

   -- The input for different frequencies
   type goertzel_coefs_type is array (natural range <>) of unsigned(CALC_WIDTH-1 downto 0);

   component goertzel
      generic (
         Q       : natural;
         SAMPLES : natural
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

   component goertzel_pipelined
      generic (
         Q           : natural;
         CHANNELS    : natural;
         FREQUENCIES : natural;
         SAMPLES     : natural);
      port (
         coefs_p  : in goertzel_coefs_type;
         inputs_p : in goertzel_inputs_type;
         start_p  : in std_logic;

         results_p : out goertzel_results_type;
         done_p    : out std_logic;

         clk : in std_logic);
   end component;
   
end signalprocessing_pkg;
