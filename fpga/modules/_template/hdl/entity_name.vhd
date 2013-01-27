-------------------------------------------------------------------------------
-- Title      : Title String
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- library work;
-- use work.<package_name>.all;

-------------------------------------------------------------------------------

entity entity_name is

   generic (
      PARAM : natural := 42
      );
   port (
      clk : in std_logic
      );

end entity_name;

-------------------------------------------------------------------------------

architecture behavioural of entity_name is

   type entity_name_state_type is (
      IDLE,                             -- Idle state: 
      STATE1,                           -- State 1:
      STATE2                            -- State 2:
      );

   type entity_name_type is record
      state : entity_name_state_type;
   end record;


   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : entity_name_type := (state => IDLE);

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package
   
begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Sequential part of finite state machine (FSM)
   ----------------------------------------------------------------------------
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   ----------------------------------------------------------------------------
   -- Combinatorial part of FSM
   ----------------------------------------------------------------------------
   comb_proc : process(r)
      variable v : entity_name_type;
      
   begin
      v := r;

      case r.state is
         when IDLE =>
            null;
         when others =>
            v.state := IDLE;
      end case;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.
   
end behavioural;
