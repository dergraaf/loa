library ieee;
use ieee.std_logic_1164.all;

entity symmetric_pwm_deadtime_tb is
end symmetric_pwm_deadtime_tb;

use work.symmetric_pwm_deadtime_pkg.all;

architecture behavior of symmetric_pwm_deadtime_tb is
  signal clk    : std_logic := '0';
  signal clk_en : std_logic := '1';
  signal reset  : std_logic := '1';

  signal value    : std_logic_vector(7 downto 0) := (others => '0');
  signal lowside  : std_logic;
  signal highside : std_logic;
  signal center   : std_logic;          -- Center of the 'on'-periode
begin
  clk   <= not clk  after 10 ns;        -- 50 Mhz clock
  reset <= '1', '0' after 50 ns;        -- erzeugt Resetsignal

  tb : process
  begin
    wait until falling_edge(reset);

    value <= x"7F";
    wait for 100 us;
    value <= x"01";
    wait for 100 us;
    value <= x"0a";
    wait for 100 us;
    value <= x"FE";
    wait for 100 us;
    value <= x"00";
    wait for 100 us;
    value <= x"FF";
    wait for 100 us;
  end process;

  uut : symmetric_pwm_deadtime
    generic map (
      WIDTH  => 8,
      T_DEAD => 10)
    port map (
      lowside_p  => lowside,
      highside_p => highside,
      center_p   => center,
      clk_en_p   => clk_en,
      value_p    => value,
      reset      => reset,
      clk        => clk);
end;
