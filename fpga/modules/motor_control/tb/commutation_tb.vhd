library ieee;
use ieee.std_logic_1164.all;

entity commutation_tb is
end commutation_tb;

library work;
use work.motor_control_pkg.all;
use work.symmetric_pwm_deadtime_pkg.all;
use work.commutation_pkg.all;

architecture behavior of commutation_tb is
   signal clk    : std_logic := '0';
   signal clk_en : std_logic := '1';

   signal center : std_logic;
   signal value  : std_logic_vector(7 downto 0) := x"F0";

   signal driver_stage : bldc_driver_stage_type;
   signal pwm          : half_bridge_type;
   signal sd           : std_logic        := '0';
   signal dir          : std_logic        := '0';
   signal hall         : hall_sensor_type := ('0', '0', '0');
begin
   clk   <= not clk  after 10 NS;       -- 50 Mhz clock

   waveform : process
   begin
      wait for 50 US;
      hall <= ('1', '0', '1');
      wait for 100 US;
      hall <= ('1', '0', '0');
      wait for 100 US;
      hall <= ('1', '1', '0');
      wait for 100 US;
      hall <= ('0', '1', '0');
      wait for 100 US;
      hall <= ('0', '1', '1');
      wait for 100 US;
      hall <= ('0', '0', '1');

      wait for 100 US;
      hall <= ('1', '0', '1');
      wait for 100 US;
      hall <= ('1', '0', '0');
      wait for 100 US;
      hall <= ('1', '1', '0');
      wait for 100 US;
      hall <= ('0', '1', '0');
      wait for 100 US;
      hall <= ('0', '1', '1');
      wait for 100 US;
      hall <= ('0', '0', '1');
   end process;

   waveform2 : process
   begin
      wait for 600 US;
      sd  <= '1';
      wait for 20 US;
      sd  <= '0';
      dir <= '1';
   end process;

   pwm_generator : symmetric_pwm_deadtime
      generic map (
         WIDTH  => 8,
         T_DEAD => 20)
      port map (
         pwm_p    => pwm,
         clk_en_p => clk_en,
         value_p  => value,
         center_p => center,
         reset    => '0',
         clk      => clk);

   commutation_1 : commutation
      port map (
         driver_stage_p => driver_stage,
         hall_p         => hall,
         pwm_p          => pwm,
         dir_p          => dir,
         sd_p           => sd,
         clk            => clk);
end;
