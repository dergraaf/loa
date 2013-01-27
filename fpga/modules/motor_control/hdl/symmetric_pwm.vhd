-------------------------------------------------------------------------------
-- Title      : Symmetric PWM generator
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
--
-- Generates a center aligned PWM with deadtime. The deadtime and register width
-- can be changed by generics.
-- 
-- PWM frequency (f_pwm) is: f_pwm = clk / ((2 ^ width) - 1)
-- 
-- Example:
-- clk = 50 MHz
-- clk_en = constant '1' (no prescaler)
-- width = 8 => value = 0..255
-- 
-- => f_pwm = 1/510ns = 0,1960784 MHz = 50/255 MHz 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package symmetric_pwm_pkg is

   component symmetric_pwm is
      generic (
         WIDTH : natural);
      port (
         pwm_p       : out std_logic;
         underflow_p : out std_logic;
         overflow_p  : out std_logic;
         clk_en_p    : in  std_logic;
         value_p     : in  std_logic_vector (WIDTH - 1 downto 0);
         reset       : in  std_logic;
         clk         : in  std_logic);
   end component symmetric_pwm;

end package symmetric_pwm_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity symmetric_pwm is
   generic (
      WIDTH : natural := 12);  -- Number of bits used for the PWM (12bit => 0..4095)
   port (
      pwm_p       : out std_logic;      -- PWM output
      underflow_p : out std_logic;  -- PWM is in the middle of the 'on'-periode
      overflow_p  : out std_logic;  -- PWM is in the middle of the 'off'-periode

      clk_en_p : in std_logic;          -- clock enable
      value_p  : in std_logic_vector (WIDTH - 1 downto 0);

      reset : in std_logic;             -- High active, Restarts the PWM period
      clk   : in std_logic
      );
end symmetric_pwm;

-- ----------------------------------------------------------------------------
architecture behavioral of symmetric_pwm is
   signal count     : integer range 0 to ((2 ** WIDTH) - 2) := 0;
   signal value_buf : std_logic_vector(width - 1 downto 0)  := (others => '0');

   signal dir : std_logic := '0';       -- 0 = up
begin
   -- Counter
   process
   begin
      wait until rising_edge(clk);

      if reset = '1' then
         -- Load new value and reset counter => restart periode
         count       <= 0;
         value_buf   <= value_p;
         underflow_p <= '0';
         overflow_p  <= '0';
      elsif clk_en_p = '1' then
         underflow_p <= '0';
         overflow_p  <= '0';

         -- counter
         if (dir = '0') then            -- up
            if count < ((2 ** WIDTH) - 2) then
               count <= count + 1;
            else
               dir        <= '1';
               count      <= count - 1;
               overflow_p <= '1';
               -- Load new value from the shadow register (not active before
               -- the next clock cycle)
               value_buf  <= value_p;
            end if;
         else                           -- down
            if (count > 0) then
               count <= count - 1;
            else
               dir         <= '0';
               count       <= count + 1;
               underflow_p <= '1';
            end if;
         end if;
      end if;
   end process;

   -- Generate Output
   process
   begin
      wait until rising_edge(clk);

      if reset = '1' then
         pwm_p <= '0';
      else
         -- comparator for the output
         if count >= to_integer(unsigned(value_buf)) then
            pwm_p <= '0';
         else
            pwm_p <= '1';
         end if;
      end if;
   end process;
end behavioral;
