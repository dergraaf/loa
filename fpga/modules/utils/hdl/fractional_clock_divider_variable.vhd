-------------------------------------------------------------------------------
-- Title      : Fractional clock divider with variable frequency
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : fractional_clock_divider_variable.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>, strongly-typed
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-22
-- Last update: 2012-04-13
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description:
-- Generates a clock enable signal.
--
-- MUL must be smaller than DIV. 
-- 
-- Example:
-- @code
-- process (clk)
-- begin
--    if rising_edge(clk) then
--       if enable = '1' then
--          ... do something with the period of the divided frequency ...
--       end if;
--    end if;
-- end process;
-- @endcode
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fractional_clock_divider_variable is
   generic (
        WIDTH : positive := 16
      );
   port (
      div : in std_logic_vector(WIDTH-1 downto 0);
      mul : in std_logic_vector(WIDTH-1 downto 0);
      clk_out_p : out std_logic;
      clk       : in  std_logic
      );
end fractional_clock_divider_variable;

-- ----------------------------------------------------------------------------
architecture behavior of fractional_clock_divider_variable is

    -- variable cnt : integer range 0 to (MUL + DIV - 1) := 0;
    signal cnt : std_logic_vector(WIDTH downto 0) := (others => '0');
    
begin 
   process begin
      wait until rising_edge(clk);
      if cnt >= div then
         clk_out_p <= '1';
         cnt <= std_logic_vector(unsigned(cnt) - unsigned(div));
      else
         clk_out_p <= '0';
         cnt <= std_logic_vector(unsigned(cnt) + unsigned(mul));         
      end if;
   end process;
end behavior;

