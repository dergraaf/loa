library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;

package fsmcslave_pkg is
  -- Naming is from the viewpoint of the external FSMC master (STM32)
  type fsmc_out_type is record
    data  : std_logic_vector(15 downto 0);
    adv_n : std_logic;
    wr_n  : std_logic;                  
    cs_n  : std_logic;                  
    oe_n  : std_logic;                  
  end record fsmc_out_type;

  type fsmc_in_type is record
    data : std_logic_vector(15 downto 0);
  end record fsmc_in_type;

  component fsmcslave is
    port (
      fsmcslave_o : out fsmc_in_type;
      fsmcslave_i : in  fsmc_out_type;

      bus_o : out busmaster_out_type;
      bus_i : in  busmaster_in_type;

      clk : in std_logic
      );
  end component;
  
end package fsmcslave_pkg;
