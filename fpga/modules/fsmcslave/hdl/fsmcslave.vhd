-------------------------------------------------------------------------------
-- Title      : FSMC Slave, synchronous
-------------------------------------------------------------------------------
-- Author     : 
-------------------------------------------------------------------------------
-- Description: This is slave to the flexible static memory controller (FSMC)
--              of a STM32 device. The slave is a busmaster to the local bus.
--              Data can be transfered to and from the bus slaves on the bus.
--              
-------------------------------------------------------------------------------
-- Copyright (c) 2013
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fsmcslave_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity fsmc_slave is

   port (

      bus_o : out busmaster_out_type;
      bus_i : in  busmaster_in_type;

      fsmc_inout_p : inout fsmc_inout_type;
      fsmc_in_p    : in    fsmc_in_type;
      fsmc_out_p   : out   fsmc_out_type;

      clk : in std_logic
      );

end fsmc_slave;

-------------------------------------------------------------------------------

architecture behavioral of fsmc_slave is

begin
   bus_o.data <= (others => '0');

end behavioral;

