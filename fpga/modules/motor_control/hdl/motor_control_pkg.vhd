-------------------------------------------------------------------------------
-- Title      : Motor control for BLDC and DC motors
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : motor_control_pkg.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-18
-- Last update: 2012-04-15
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;

package motor_control_pkg is

   type hall_sensor_type is record
      a : std_logic;  -- Channel A -> Phase U magnetic field detection
      b : std_logic;  -- Channel B -> Phase V magnetic field detection
      c : std_logic;  -- Channel C -> Phase W magnetic field detection
   end record;

   type half_bridge_type is record
      high : std_logic;                 -- Highside
      low  : std_logic;                 -- Lowside
   end record;

   type bldc_driver_stage_type is record
      a : half_bridge_type;             -- Channel 1 (U,X)
      b : half_bridge_type;             -- Channel 2 (V,Y)
      c : half_bridge_type;             -- Channel 3 (W,Z)
   end record;

   component dc_motor_module is
      generic (
         BASE_ADDRESS : integer range 0 to 32767;
         WIDTH        : positive;
         PRESCALER    : positive);
      port (
         pwm1_p  : out std_logic;
         pwm2_p  : out std_logic;
         sd_p    : out std_logic;
         break_p : in  std_logic := '0';
         bus_o   : out busdevice_out_type;
         bus_i   : in  busdevice_in_type;
         reset   : in  std_logic;
         clk     : in  std_logic);
   end component dc_motor_module;

   component bldc_motor_module is
      generic (
         BASE_ADDRESS : integer range 0 to 32767;
         WIDTH        : positive;
         PRESCALER    : positive);
      port (
         driver_stage_p : out bldc_driver_stage_type;
         hall_p         : in  hall_sensor_type;
         break_p        : in  std_logic := '0';
         bus_o          : out busdevice_out_type;
         bus_i          : in  busdevice_in_type;
         reset          : in  std_logic;
         clk            : in  std_logic);
   end component bldc_motor_module;

   type comparator_values_type is array (natural range <>) of std_logic_vector(9 downto 0);
   
   component comparator_module is
      generic (
         BASE_ADDRESS : integer range 0 to 32767;
         CHANNELS     : positive := 8);
      port (
         value_p    : in  comparator_values_type(CHANNELS-1 downto 0);
         overflow_p : out std_logic_vector(CHANNELS-1 downto 0);
         bus_o      : out busdevice_out_type;
         bus_i      : in  busdevice_in_type;
         reset      : in  std_logic;
         clk        : in  std_logic);
   end component comparator_module;

end package motor_control_pkg;
