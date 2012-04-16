-------------------------------------------------------------------------------
-- Title      : Symmetric PWM with Deadtime generation
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : symmetric_pwm_deadtime.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-16
-- Last update: 2012-04-15
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
--
-- Deadtime for on and off can be specified separately.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.motor_control_pkg.all;

package symmetric_pwm_deadtime_pkg is

   component symmetric_pwm_deadtime
      generic (
         WIDTH  : natural;
         T_DEAD : natural);
      port (
         pwm_p    : out half_bridge_type;
         center_p : out std_logic;
         clk_en_p : in  std_logic;
         value_p  : in  std_logic_vector (WIDTH - 1 downto 0);
         break_p  : in  std_logic := '0';
         reset    : in  std_logic;
         clk      : in  std_logic);
   end component;

end package symmetric_pwm_deadtime_pkg;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.motor_control_pkg.all;
use work.symmetric_pwm_pkg.all;
use work.deadtime_pkg.all;

entity symmetric_pwm_deadtime is
   generic (
      -- Number of bits used for the PWM (12bit => 0..4095)
      WIDTH : natural := 12;

      -- Defines the duration of the dead-time
      -- inserted between the complementary outputs (in clock cycles of 'clk').
      T_DEAD : natural := 0
      );
   port (
      pwm_p : out half_bridge_type;

      center_p : out std_logic;  -- PWM is in the middle of the 'on'-periode
      clk_en_p : in  std_logic;         -- clock enable
      value_p  : in  std_logic_vector (WIDTH - 1 downto 0);

      -- Disable PWM generation (sets pwm.low = '1' and pwm.high = '0')
      break_p : in std_logic := '0';

      reset : in std_logic;             -- High active, Restarts the PWM period
      clk   : in std_logic
      );
end symmetric_pwm_deadtime;

architecture structural of symmetric_pwm_deadtime is
   signal pwm_raw : std_logic := '0';  -- PWM signal from the Symmetric PWM generator
   signal pwm     : std_logic;
   signal pwm_n   : std_logic;

   signal lowside_center  : std_logic;
   signal highside_center : std_logic;
begin

   pwm_generator : symmetric_pwm
      generic map (
         WIDTH => WIDTH)
      port map (
         pwm_p       => pwm_raw,
         underflow_p => lowside_center,
         overflow_p  => highside_center,
         clk_en_p    => clk_en_p,
         value_p     => value_p,
         reset       => reset,
         clk         => clk);

   pwm <= '0' when break_p = '1' else pwm_raw;
   pwm_n <= not pwm;

   deadtime_on : deadtime
      generic map (
         T_DEAD => T_DEAD)
      port map (
         in_p  => pwm_n,
         out_p => pwm_p.low,
         clk   => clk);

   deadtime_off : deadtime
      generic map (
         T_DEAD => T_DEAD)
      port map (
         in_p  => pwm,
         out_p => pwm_p.high,
         clk   => clk);

   -- The deadtime generation delays the PWM output. To keep the center_p signal
   -- synchron is has also to be delayed.
   process
      variable go    : std_logic                           := '0';  -- Delay has started
      variable delay : integer range 0 to (T_DEAD / 2) - 1 := 0;
   begin
      wait until rising_edge(clk);

      if go = '0' then
         center_p <= '0';
         if lowside_center = '1' then
            go    := '1';
            delay := 0;
         end if;
      else
         if delay < (T_DEAD / 2) - 1 then
            delay := delay + 1;
         else
            center_p <= '1';
            go       := '0';
         end if;
      end if;
   end process;
end architecture structural;
