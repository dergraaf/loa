-------------------------------------------------------------------------------
-- Title      : Title String
-------------------------------------------------------------------------------
-- Author     : AUTHOR
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013, AUTHOR
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package pwm_sr_pkg is

   type entity_name_out_type is record
      data  : std_logic_vector(7 downto 0);
   end record fsmc_out_type;

   type entity_name_in_type is record
      data   : std_logic_vector(7 downto 0);
   end record fsmc_in_type;

   component entity_name is
      port (
         entity_name_i : out entity_name_out_type;
         entity_name_o : in  entity_name_in_type;

         clk : in std_logic
         );
   end component;
   
end package pwm_sr_pkg;
