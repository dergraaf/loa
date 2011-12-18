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

  type half_bridge_type is record
    high : std_logic;                   -- Highside
    low  : std_logic;                   -- Lowside
  end record;

end package motor_control_pkg;
