
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;

package fsmcslave_pkg is

   -- Naming is from the viewpoint of the external FSMC master (the STM32)
   type fsmcmaster_out_type is record
      adv_n : std_logic;
      oe_n  : std_logic;                -- Bus master read (output enable)
      we_n  : std_logic;                -- Bus master write (write enable)
      cs_n  : std_logic;                -- Chip select
      ad    : std_logic_vector(15 downto 0);  -- tristate buffer needs to be
                                              -- controlled by another output
   end record fsmcmaster_out_type;

   type fsmcmaster_in_type is record
      ad   : std_logic_vector(15 downto 0);
   end record fsmcmaster_in_type;

   subtype fsmcslave_in_type  is fsmcmaster_out_type;
   subtype fsmcslave_out_type is fsmcmaster_in_type;

   component fsmcslave is
      port (
         fsmc_o : out fsmcslave_out_type;
         fsmc_i : in  fsmcslave_in_type;
         fsmc_oe : out std_logic;       -- needs to be output for both: master
                                        -- and slave
         --
         bus_o : out busmaster_out_type;
         bus_i : in  busmaster_in_type;
         --
         clk : in std_logic
         );
   end component fsmcslave;

end package fsmcslave_pkg;
