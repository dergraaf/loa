
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;


package pwm_module_pkg is

  component pwm_module
    generic (
      BASE_ADDRESS : integer range 0 to 16#7FFF#;
      WIDTH        : positive;
      PRESCALER    : positive);
    port (
      pwm_p : out std_logic;
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;
      reset : in  std_logic;
      clk   : in  std_logic);
  end component;

end pwm_module_pkg;
