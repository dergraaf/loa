
library ieee;
use ieee.std_logic_1164.all;

package bus_pkg is
  -- Busmaster
  type busmaster_out_type is record
    addr : std_logic_vector(14 downto 0);
    data : std_logic_vector(15 downto 0);
    re   : std_logic;
    we   : std_logic;
  end record;

  type busmaster_in_type is record
    data : std_logic_vector(15 downto 0);
  end record;

  -- Devices
  subtype busdevice_out_type is busmaster_in_type;
  subtype busdevice_in_type is busmaster_out_type;

end bus_pkg;
