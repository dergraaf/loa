library ieee;
use ieee.std_logic_1164.all;

entity symmetric_pwm_deadtime_tb is
end symmetric_pwm_deadtime_tb;

use work.symmetric_pwm_deadtime_pkg.all;

architecture behavior of symmetric_pwm_deadtime_tb is
  signal clk    : std_logic := '0';
  signal clk_en : std_logic := '1';
  signal reset  : std_logic := '1';

  signal value  : std_logic_vector(7 downto 0) := (others => '0');
  signal pwm    : half_bridge_type;
  signal center : std_logic;            -- Center of the 'on'-periode
begin
  clk   <= not clk  after 10 NS;        -- 50 Mhz clock
  reset <= '1', '0' after 50 NS;        -- erzeugt Resetsignal

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

  uut : symmetric_pwm_deadtime
    generic map (
      WIDTH  => 8,
      T_DEAD => 10)
    port map (
      pwm_p    => pwm,
      center_p => center,
      clk_en_p => clk_en,
      value_p  => value,
      reset    => reset,
      clk      => clk);
end;
