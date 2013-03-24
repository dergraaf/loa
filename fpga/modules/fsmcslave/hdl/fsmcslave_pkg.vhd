
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;

package fsmcslave_pkg is

   -- Naming is from the viewpoint of the external FSMC master (the STM32)
   type fsmc_out_type is record
      data  : std_logic_vector(15 downto 0);
      adv_n : std_logic;
      clk   : std_logic;
      rd_n  : std_logic;                -- Bus master read (output enable)
      wr_n  : std_logic;                -- Bus master write (write enable)
      cs_n  : std_logic;                -- Chip select
      bl_n  : std_logic_vector(1 downto 0);
   end record fsmc_out_type;

   type fsmc_in_type is record
      data   : std_logic_vector(15 downto 0);
      wait_n : std_logic;
      oe     : std_logic;               -- Output enable
   end record fsmc_in_type;

   component fsmc_slave is
      port (
         fsmc_i : out fsmc_out_type;
         fsmc_o : in  fsmc_in_type;

         bus_o : out busmaster_out_type;
         bus_i : in  busmaster_in_type;

         clk : in std_logic
         );
   end component;
   
end package fsmcslave_pkg;
