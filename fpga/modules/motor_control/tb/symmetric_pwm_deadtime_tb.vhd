library ieee;
use ieee.std_logic_1164.all;

library work;
use work.motor_control_pkg.all;
use work.symmetric_pwm_deadtime_pkg.all;

entity symmetric_pwm_deadtime_tb is
end symmetric_pwm_deadtime_tb;

architecture behavior of symmetric_pwm_deadtime_tb is
   constant WIDTH  : positive := 8;
   constant T_DEAD : natural  := 10;    -- Deadtime in clk cycles

   signal clk    : std_logic := '0';
   signal clk_en : std_logic := '1';
   signal reset  : std_logic := '1';

   signal value  : std_logic_vector(WIDTH - 1 downto 0) := (others => '0');
   signal pwm    : half_bridge_type;
   signal center : std_logic;           -- Center of the 'on'-periode

   signal break : std_logic := '0';
begin
   clk   <= not clk  after 10 NS;       -- 50 Mhz clock
   reset <= '1', '0' after 50 NS;       -- erzeugt Resetsignal

   tb : process
   begin
      wait until falling_edge(reset);

      value <= x"7F";
      wait for 100 US;
      value <= x"01";
      wait for 100 US;
      value <= x"0a";
      wait for 100 US;
      value <= x"FE";
      wait for 100 US;
      value <= x"00";
      wait for 100 US;
      value <= x"FF";
      wait for 100 US;
   end process;

   tb2 : process
   begin
      wait until falling_edge(reset);

      wait for 40 US;
      break <= '1';
      wait for 30 US;
      break <= '0';
      
      wait for 150 US;
      break <= '1';
      wait for 30 US;
      break <= '0';
   end process;

   uut : symmetric_pwm_deadtime
      generic map (
         WIDTH  => WIDTH,
         T_DEAD => T_DEAD)
      port map (
         pwm_p    => pwm,
         center_p => center,
         clk_en_p => clk_en,
         value_p  => value,
         break_p  => break,
         reset    => reset,
         clk      => clk);
end;
