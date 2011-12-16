-------------------------------------------------------------------------------
-- Title      : Deadtime generation
-- Project    : 
-------------------------------------------------------------------------------
-- File       : deadtime.vhd
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : 
-- Created    : 2011-12-16
-- Last update: 2011-12-16
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package deadtime_pkg is

  component deadtime is
    generic (
      T_DEAD : integer);
    port (
      in_p  : in  std_logic;
      out_p : out std_logic := '0';
      clk   : in  std_logic);
  end component deadtime;

end package deadtime_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity deadtime is
  generic (
    T_DEAD : positive                    -- Number of Deadtime cycles
    );
  port (
    in_p  : in  std_logic;
    out_p : out std_logic := '0';
    clk   : in  std_logic
    );
end deadtime;

architecture behavioral of deadtime is
  signal delay : integer range 0 to T_DEAD - 1 := 0;
begin
  process
  begin
    wait until rising_edge(clk);

    if (in_p = '0') then
      out_p <= '0';
      delay <= 0;
    else
      if (delay < (T_DEAD - 1)) then
        delay <= delay + 1;
      else
        out_p <= '1';
      end if;
    end if;
  end process;
end behavioral;
