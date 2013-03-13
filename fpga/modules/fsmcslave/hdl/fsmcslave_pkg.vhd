
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;

package fsmcslave_pkg is

   -- Bidirectional data pins
   type fsmc_inout_type is record
      d : std_logic_vector(15 downto 0);
   end record fsmc_inout_type;

   -- Unidirectional control pins
   type fsmc_out_type is record
      nadv : std_logic;
      clk  : std_logic;
      noe  : std_logic;
      nwe  : std_logic;
      ne1  : std_logic;
      nbl  : std_logic_vector(1 downto 0);
   end record fsmc_out_type;

   type fsmc_in_type is record
      nwait : std_logic;
   end record fsmc_in_type;
   
end package fsmcslave_pkg;

package body fsmcslave_pkg is

end package body fsmcslave_pkg;
