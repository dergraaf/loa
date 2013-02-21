-------------------------------------------------------------------------------
-- Title      : iMotor Module
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: iMotor Module shares the same interface as a motor controller.
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;

-------------------------------------------------------------------------------

entity imotor_module is

   generic (
      BASE_ADDRESS : integer range 0 to 32767;
      MOTORS       : positive := 7
      );
   port (
      tx_out_p : out std_logic_vector(MOTORS - 1 downto 0);
      rx_in_p  : in  std_logic_vector(MOTORS - 1 downto 0);

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk : in std_logic
      );

end imotor_module;

-------------------------------------------------------------------------------

architecture behavioural of imotor_module is

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   imotor_inst: for imotor_idx in MOTORS-1 downto 0 generate
   end generate imotor_inst;

end behavioural;
