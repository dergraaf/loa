-------------------------------------------------------------------------------
-- Title      : titleString
-- Project    : 
-------------------------------------------------------------------------------
-- File       : EntityName.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2011-09-27
-- Last update: 2011-09-27
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

-------------------------------------------------------------------------------

entity EntityName is

  generic (
    );

  port (
    reset : in std_logic,
    clk   : in std_logic
    );

end EntityName;

-------------------------------------------------------------------------------

architecture str of EntityName is

  type EntityName_state_type is (idle, state1, state2);

  type EntityName_type is record
    state : EntityName_state_type;
  end record;


  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : EntityName_type;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

begin  -- str

  seq_proc : process(reset, clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        r.state <= idle;
      else
        r <= rin;
      end if;
    end if;
  end process seq_proc;


  comb_proc : process(r)
    variable v : EntityName_type;
    
  begin
    v := r;
    
    case v.state is
      when idle =>
        null;
      when others =>
        null;
    end case;
    
    rin := v;
  end process comb_proc;

-----------------------------------------------------------------------------
-- Component instantiations
-----------------------------------------------------------------------------


end str;

-------------------------------------------------------------------------------
