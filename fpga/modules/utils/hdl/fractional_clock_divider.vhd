-------------------------------------------------------------------------------
-- Title      : Generic clock divider
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : fractional_clock_divider.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-22
-- Last update: 2011-12-22
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

entity fractional_clock_divider is
   generic (
      DIV : positive;
      MUL : positive := 1
      );
   port (
      clk_out_p : out std_logic;
      clk       : in  std_logic
      );
end fractional_clock_divider;

-- ----------------------------------------------------------------------------
architecture behavior of fractional_clock_divider is

begin
   process
      variable cnt : integer range 0 to (MUL + DIV - 1) := 0;
   begin
      wait until rising_edge(clk);

      cnt := cnt + MUL;
      if cnt >= DIV then
         cnt := cnt - DIV;

         clk_out_p <= '1';
      else
         clk_out_p <= '0';
      end if;
   end process;
end behavior;

