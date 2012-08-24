-------------------------------------------------------------------------------
-- Title      : Timestamp Generator module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : timestamp_generator.vhd
-- Author     : strongly-typed
-- Created    : 2011-09-27
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: A fast, wide counter for keeping a timestamp for events like
--              samples. 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity timestamp_generator is
   port (
      timestamp_o_p : out timestamp_type;
      clk       : in  std_logic
      );

end timestamp_generator;

-------------------------------------------------------------------------------

architecture behavioural of timestamp_generator is

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal cnt : timestamp_type := (others => '0'); --unsigned(WIDTH-1 downto 0) := (others => '0');
   
   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package
   
begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   timestamp_o_p <= cnt;

   ----------------------------------------------------------------------------
   -- Sequential process
   ----------------------------------------------------------------------------
   cnt_proc : process(clk)
   begin
      if rising_edge(clk) then
         cnt <= cnt + 1;
      end if;
   end process cnt_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.
   
end behavioural;
