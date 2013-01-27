-------------------------------------------------------------------------------
-- Title      : Testbench for design "beacon_robot"
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.spislave_pkg.all;
use work.motor_control_pkg.all;
use work.utils_pkg.all;

use work.pwm_module_pkg.all;
use work.motor_control_pkg.all;
use work.encoder_module_pkg.all;
use work.servo_module_pkg.all;
use work.adc_mcp3008_pkg.all;
use work.reg_file_pkg.all;
use work.utils_pkg.all;

-------------------------------------------------------------------------------
entity toplevel_tb is
end toplevel_tb;

-------------------------------------------------------------------------------
architecture tb of toplevel_tb is

   component toplevel is
      port (
         bldc1_driver_p  : out bldc_driver_stage_type;
         bldc1_hall_p    : in  hall_sensor_type;
         bldc1_encoder_p : in  encoder_type;
         bldc2_driver_p  : out bldc_driver_stage_type;
         bldc2_hall_p    : in  hall_sensor_type;
         bldc2_encoder_p : in  encoder_type;
         motor3_pwm1_p   : out std_logic;
         motor3_pwm2_p   : out std_logic;
         motor3_sd_np    : out std_logic;
         servo_p         : out std_logic_vector(16 downto 1);
         cs_np           : in  std_logic;
         sck_p           : in  std_logic;
         miso_p          : out std_logic;
         mosi_p          : in  std_logic;
         load_p          : in  std_logic;
         reset_n         : in  std_logic;
         led_np          : out std_logic_vector (3 downto 0);
         sw_np           : in  std_logic_vector (1 downto 0);
         adc_out_p       : out adc_mcp3008_spi_out_type;
         adc_in_p        : in  adc_mcp3008_spi_in_type;
         clk             : in  std_logic);
   end component toplevel;

   -- signals for component ports
   signal bldc1_driver_p  : bldc_driver_stage_type;
   signal bldc1_hall_p    : hall_sensor_type;
   signal bldc1_encoder_p : encoder_type;
   signal bldc2_driver_p  : bldc_driver_stage_type;
   signal bldc2_hall_p    : hall_sensor_type;
   signal bldc2_encoder_p : encoder_type;
   signal motor3_pwm1_p   : std_logic;
   signal motor3_pwm2_p   : std_logic;
   signal motor3_sd_np    : std_logic;
   signal servo_p         : std_logic_vector(16 downto 1);
   signal cs_np           : std_logic;
   signal sck_p           : std_logic;
   signal miso_p          : std_logic;
   signal mosi_p          : std_logic;
   signal load            : std_logic := '0';
   signal led_np          : std_logic_vector (3 downto 0);
   signal sw_np           : std_logic_vector (1 downto 0);
   signal adc_out_p       : adc_mcp3008_spi_out_type;
   signal adc_in_p        : adc_mcp3008_spi_in_type;

   signal reset_n : std_logic := '1';
   signal clk     : std_logic := '0';

begin  -- tb

   toplevel_1 : entity work.toplevel
      port map (
         bldc1_driver_p  => bldc1_driver_p,
         bldc1_hall_p    => bldc1_hall_p,
         bldc1_encoder_p => bldc1_encoder_p,
         bldc2_driver_p  => bldc2_driver_p,
         bldc2_hall_p    => bldc2_hall_p,
         bldc2_encoder_p => bldc2_encoder_p,
         motor3_pwm1_p   => motor3_pwm1_p,
         motor3_pwm2_p   => motor3_pwm2_p,
         motor3_sd_np    => motor3_sd_np,
         servo_p         => servo_p,
         cs_np           => cs_np,
         sck_p           => sck_p,
         miso_p          => miso_p,
         mosi_p          => mosi_p,
         load_p          => load,
         reset_n         => reset_n,
         led_np          => led_np,
         sw_np           => sw_np,
         adc_out_p       => adc_out_p,
         adc_in_p        => adc_in_p,
         clk             => clk);

   -- clock generation
   Clk <= not Clk after 5.0 NS;

   process
   begin
      wait for 25 NS;
      reset_n <= '0';

      wait for 10 US;
      load <= '1';
      wait for 100 NS;
      load <= '0';
   end process;

end tb;

