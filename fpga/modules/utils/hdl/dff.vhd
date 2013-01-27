-------------------------------------------------------------------------------
-- Title      : D Flip-Flop with synchronous Reset, Set and Clock Enable
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Xilinx Spartan 3
-------------------------------------------------------------------------------
-- Description:
-- 
-- D Flip-Flop with Synchronous Reset, Set and Clock Enable.
-- Priority (high to low): reset_p, set_p, ce_p
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dff is
   port(
      dout_p : out std_logic;           -- Data output
      din_p  : in  std_logic;           -- Data input

      set_p   : in std_logic;           -- Synchronous set input
      reset_p : in std_logic;           -- Synchronous reset input

      ce_p : in std_logic;              -- Clock enable input
      clk  : in std_logic               -- Clock input
      );
end dff;

-------------------------------------------------------------------------------
architecture behavioral of dff is
begin
   process (clk)
   begin
      if rising_edge(clk) then
         if reset_p = '1' then
            dout_p <= '0';
         elsif set_p = '1' then
            dout_p <= '1';
         elsif ce_p = '1' then
            dout_p <= din_p;
         end if;
      end if;
   end process;
end behavioral;

