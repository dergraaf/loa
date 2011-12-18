-------------------------------------------------------------------------------
-- Title      : Motor control for BLDC and DC motors
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : motor_control_pkg.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-18
-- Last update: 2011-12-18
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

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

end package motor_control_pkg;
