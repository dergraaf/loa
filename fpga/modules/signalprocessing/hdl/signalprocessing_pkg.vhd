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

   -- All calculations are based on that type:
   subtype goertzel_data_type is signed(CALC_WIDTH-1 downto 0);

   -- The result of the Goertzel Algorithm are always a pair of two values
   type goertzel_result_type is array (1 downto 0) of goertzel_data_type;

   -- The result for more channels and frequencies:
   type goertzel_results_type is array (natural range <>, natural range <>) of goertzel_result_type;

   -- One input to the algorithm. 
   subtype goertzel_input_type is signed(INPUT_WIDTH-1 downto 0);
   -- The input for many different channels
   type goertzel_inputs_type is array (natural range <>) of goertzel_input_type;

   -- One goertzel coefficient corresponds to a certain frequency.
   subtype goertzel_coef_type is signed(CALC_WIDTH-1 downto 0);
   -- The input for different frequencies
   type goertzel_coefs_type is array (natural range <>) of goertzel_coef_type;

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


   ----------------------------------------------------------------------------
   -- New version, consists of pipeline, muxes and control_unit
   ----------------------------------------------------------------------------
   component goertzel_pipeline is
      generic (
         Q : natural);
      port (
         coef_p   : in  goertzel_coef_type;
         input_p  : in  goertzel_input_type;
         delay_p  : in  goertzel_result_type;
         result_p : out goertzel_result_type;
         clk      : in  std_logic);
   end component goertzel_pipeline;

   component goertzel_muxes is
      generic (
         CHANNELS    : positive;
         FREQUENCIES : positive);
      port (
         mux_delay1_p : in  std_logic;
         mux_delay2_p : in  std_logic;
         mux_coef     : in  natural range FREQUENCIES-1 downto 0;
         mux_input    : in  natural range CHANNELS-1 downto 0;
         bram_data    : in  goertzel_result_type;
         coefs_p      : in  goertzel_coefs_type;
         inputs_p     : in  goertzel_inputs_type;
         delay1_p     : out goertzel_data_type;
         delay2_p     : out goertzel_data_type;
         coef_p       : out goertzel_coef_type;
         input_p      : out goertzel_input_type);
   end component goertzel_muxes;

   component goertzel_control_unit is
      generic (
         SAMPLES     : positive;
         FREQUENCIES : positive;
         CHANNELS    : positive);
      port (
         start_p      : in  std_logic;
         ready_p      : out std_logic                            := '0';
         bram_addr_p  : out std_logic_vector(7 downto 0)         := (others => '0');
         bram_we_p    : out std_logic                            := '0';
         mux_delay1_p : out std_logic                            := '0';
         mux_delay2_p : out std_logic                            := '0';
         mux_coef_p   : out natural range FREQUENCIES-1 downto 0 := 0;
         mux_input_p  : out natural range CHANNELS-1 downto 0    := 0;
         clk          : in  std_logic);
   end component goertzel_control_unit;

   component goertzel_pipelined_v2 is
      generic (
         FREQUENCIES  : positive;
         CHANNELS     : positive;
         SAMPLES      : positive;
         Q            : positive;
         BASE_ADDRESS : natural);
      port (
         start_p     : in  std_logic;
         bram_addr_p : out std_logic_vector(7 downto 0);
         bram_data_i : in  std_logic_vector(35 downto 0);
         bram_data_o : out std_logic_vector(35 downto 0);
         bram_we_p   : out std_logic;
         ready_p     : out std_logic;
         enable_p    : in  std_logic;
         coefs_p     : in  goertzel_coefs_type(FREQUENCIES-1 downto 0);
         inputs_p    : in  goertzel_inputs_type(CHANNELS-1 downto 0);
         clk         : in  std_logic);
   end component goertzel_pipelined_v2;
   
   
end signalprocessing_pkg;
