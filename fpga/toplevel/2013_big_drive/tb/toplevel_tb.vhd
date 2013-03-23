-------------------------------------------------------------------------------
-- Title      : Testbench for design "2013_big_drive"
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
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
use work.adc_ad7266_pkg.all;
use work.reg_file_pkg.all;
use work.utils_pkg.all;

-------------------------------------------------------------------------------
entity toplevel_tb is
end toplevel_tb;

-------------------------------------------------------------------------------
architecture tb of toplevel_tb is

   component toplevel is
      port (
         bldc0_driver_p  : out bldc_driver_stage_type;
         bldc0_hall_p    : in  hall_sensor_type;
         bldc0_encoder_p : in  encoder_type;
         encoder0_p      : in  encoder_type;
         bldc1_driver_p  : out bldc_driver_stage_type;
         bldc1_hall_p    : in  hall_sensor_type;
         bldc1_encoder_p : in  encoder_type;
         encoder1_p      : in  encoder_type;
         dc0_driver_p    : out dc_driver_stage_st_type;
         dc1_driver_p    : out dc_driver_stage_st_type;
         dc2_driver_p    : out dc_driver_stage_st_type;
         servo_p         : out std_logic_vector(3 downto 2);
         imotor_tx_p     : out std_logic_vector(4 downto 0);
         imotor_rx_p     : in  std_logic_vector(4 downto 0);
         pump_p          : out std_logic_vector(3 downto 0);
         valve_p         : out std_logic_vector(3 downto 0);
         cs_np           : in  std_logic;
         sck_p           : in  std_logic;
         miso_p          : out std_logic;
         mosi_p          : in  std_logic;
         adc_out_p       : out adc_ad7266_spi_out_type;
         adc_in_p        : in  adc_ad7266_spi_in_type;
         clk             : in  std_logic);
   end component toplevel;

   -- signals for component ports
   signal bldc0_driver_p  : bldc_driver_stage_type;
   signal bldc0_hall_p    : hall_sensor_type;
   signal bldc0_encoder_p : encoder_type;
   signal encoder0_p      : encoder_type;
   signal bldc1_driver_p  : bldc_driver_stage_type;
   signal bldc1_hall_p    : hall_sensor_type;
   signal bldc1_encoder_p : encoder_type;
   signal encoder1_p      : encoder_type;
   signal dc0_driver_p    : dc_driver_stage_st_type;
   signal dc1_driver_p    : dc_driver_stage_st_type;
   signal dc2_driver_p    : dc_driver_stage_st_type;
   signal servo_p         : std_logic_vector(3 downto 2);
   signal imotor_tx_p     : std_logic_vector(4 downto 0);
   signal imotor_rx_p     : std_logic_vector(4 downto 0);
   signal pump_p          : std_logic_vector(3 downto 0);
   signal valve_p         : std_logic_vector(3 downto 0);

   signal adc_in_p  : adc_ad7266_spi_in_type;
   signal adc_out_p : adc_ad7266_spi_out_type;

   signal cs_np  : std_logic;
   signal sck_p  : std_logic;
   signal miso_p : std_logic;
   signal mosi_p : std_logic;

   signal clk : std_logic := '0';

begin  -- tb

   toplevel_1 : entity work.toplevel
      port map (
         bldc0_driver_p  => bldc0_driver_p,
         bldc0_hall_p    => bldc0_hall_p,
         bldc0_encoder_p => bldc0_encoder_p,
         encoder0_p      => encoder0_p,
         bldc1_driver_p  => bldc1_driver_p,
         bldc1_hall_p    => bldc1_hall_p,
         bldc1_encoder_p => bldc1_encoder_p,
         encoder1_p      => encoder1_p,
         dc0_driver_p    => dc0_driver_p,
         dc1_driver_p    => dc1_driver_p,
         dc2_driver_p    => dc2_driver_p,
         servo_p         => servo_p,
         imotor_rx_p     => imotor_rx_p,
         imotor_tx_p     => imotor_tx_p,
         adc_out_p       => adc_out_p,
         adc_in_p        => adc_in_p,
         cs_np           => cs_np,
         sck_p           => sck_p,
         miso_p          => miso_p,
         mosi_p          => mosi_p,
         clk             => clk);

   -- clock generation
   Clk <= not Clk after 5.0 ns;

   process
   begin

      wait;
   end process;

end tb;

