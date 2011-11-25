-------------------------------------------------------------------------------
-- Title      : titleString
-- Project    : 
-------------------------------------------------------------------------------
-- File       : peripheral_register.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2011-09-27
-- Last update: 2011-10-26
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-10-26  1.0      calle   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity peripheral_register is
  port (
    din_p  : in  std_logic_vector(15 downto 0);
    dout_p : out std_logic_vector(15 downto 0);
    we_p   : in  std_logic;
    re_p   : in  std_logic;
    reset  : in  std_logic;
    clk    : in  std_logic
    );

end peripheral_register;

-------------------------------------------------------------------------------

architecture str of peripheral_register is

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal reg : std_logic_vector(15 downto 0) := (others => '0');

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

begin  -- str

  -- read is combinator, and we don't care about addresses in this case
  dout_p <= reg when re_p = '1' else (others => '0');

  seq_proc : process(reset, clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        reg <= (others => '0');
      else
        if we_p = '1' then
          reg <= din_p;
        end if;
      end if;
    end if;
  end process seq_proc;

end str;

-------------------------------------------------------------------------------
