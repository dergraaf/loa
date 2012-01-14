--!
--! Up/Down-Counter
--! 
--! @author     Fabian Greif
--!

library ieee;
use ieee.std_logic_1164.all;

package up_down_counter_pkg is

   component up_down_counter is
      generic (
         WIDTH : positive);
      port (
         clk_en_p  : in  std_logic;
         up_down_p : in  std_logic;
         value_p   : out std_logic_vector(WIDTH - 1 downto 0);
         reset     : in  std_logic;
         clk       : in  std_logic);
   end component up_down_counter;

end package up_down_counter_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity up_down_counter is
   generic (
      WIDTH : positive := 8);
   port (
      clk_en_p  : in std_logic;         --! Clock enable
      up_down_p : in std_logic;         --! '1' = up, '0' = down

      value_p : out std_logic_vector(WIDTH - 1 downto 0);

      reset : in std_logic;             --! Reset counter
      clk   : in std_logic              --! System clock
      );
end up_down_counter;

architecture behavioral of up_down_counter is
   signal count : unsigned(WIDTH - 1 downto 0) := (others => '0');
begin
   process
   begin
      wait until rising_edge(clk);

      if reset = '1' then
         count <= (others => '0');
      elsif clk_en_p = '1' then
         if up_down_p = '1' then
            count <= count + 1;
         else
            count <= count - 1;
         end if;
      end if;
   end process;

   value_p <= std_logic_vector(count);
end behavioral;
