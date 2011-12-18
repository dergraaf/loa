-------------------------------------------------------------------------------
-- Title      : Title String
-- Project    : 
-------------------------------------------------------------------------------
-- File       : entity_name.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2011-09-27
-- Last update: 2011-12-18
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-09-27  1.0      calle   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

entity entity_name is

  generic (
    );

  port (
    reset : in std_logic,
    clk   : in std_logic
    );

end entity_name;

-------------------------------------------------------------------------------

architecture behavioral of entity_name is

  type entity_name_state_type is (IDLE, STATE1, STATE2);

  type entity_name_type is record
    state : entity_name_state_type;
  end record;


  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : entity_name_type;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

begin
  
  seq_proc : process(reset, clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        r.state <= IDLE;
      else
        r <= rin;
      end if;
    end if;
  end process seq_proc;


  comb_proc : process(r)
    variable v : entity_name_type;
    
  begin
    v := r;
    
    case v.state is
      when IDLE =>
        null;
      when others =>
        null;
    end case;
    
    rin <= v;
  end process comb_proc;

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

end behavioral;
