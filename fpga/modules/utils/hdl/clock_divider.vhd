--! 
--! Generic clock divider
--! 
--! Generates an clock enable signal.
--! 
--! Example:
--! @code
--! process (clk)
--! begin
--!     if rising_edge(clk) then
--!         if enable = '1' then
--!             ... do something with the period of the divided frequency ...
--!         end if;
--!     end if;
--! end process;
--! @endcode
--! 
--! @author             Fabian Greif
--! 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity clock_divider is
  generic (
    DIVIDER : positive := 2);
  port (
    clk_out_p : out std_logic;  -- Enable output ('1' for one clock cycle)
    clk       : in  std_logic           -- System clock
    );
end clock_divider;

-- ----------------------------------------------------------------------------
architecture behavior of clock_divider is
begin
  process
    variable counter : integer range 0 to DIVIDER := 0;
  begin
    wait until rising_edge(clk);

    counter := counter + 1;
    if counter = DIVIDER then
      counter   := 0;
      clk_out_p <= '1';
    else
      clk_out_p <= '0';
    end if;
  end process;
end behavior;

