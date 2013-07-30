
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;
use work.motor_control_pkg.all;

package encoder_module_pkg is

   type encoder_type is record
      a : std_logic;
      b : std_logic;
   end record encoder_type;

   component encoder_module
      generic (
         BASE_ADDRESS : integer range 0 to 16#7FFF#);
      port (
         encoder_p : in  encoder_type;
         index_p   : in  std_logic;
         load_p    : in  std_logic;
         bus_o     : out busdevice_out_type;
         bus_i     : in  busdevice_in_type;
         clk       : in  std_logic);
   end component;

   component encoder_module_extended is
      generic (
         BASE_ADDRESS : integer range 0 to 16#7FFF#);
      port (
         encoder_p : in  encoder_type;
         index_p   : in  std_logic;
         load_p    : in  std_logic;
         bus_o     : out busdevice_out_type;
         bus_i     : in  busdevice_in_type;
         clk       : in  std_logic);
   end component encoder_module_extended;

   component encoder_hall_sensor_module is
      generic (
         BASE_ADDRESS : integer range 0 to 16#7FFF#);
      port (
         hall_sensor_p : in  hall_sensor_type;
         load_p        : in  std_logic;
         bus_o         : out busdevice_out_type;
         bus_i         : in  busdevice_in_type;
         clk           : in  std_logic);
   end component encoder_hall_sensor_module;

end encoder_module_pkg;
