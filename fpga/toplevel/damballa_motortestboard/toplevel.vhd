-------------------------------------------------------------------------------
-- Title      : Motortestboard
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-14
-- Last update: 2011-12-30
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
-- This board is used to develop the FPGA and STM32F4xx Peripherals and
-- test if the system is suitable as main controller for the RCA robots.
-- 
-- The FPGA is able to control the following peripherals:
-- 2x Brushless Motor (with Hall-Sensors and Encoders)
-- 2x DC Motor (with Encoders)
-- 1x RGB LED
-- 3x Servo
-- ...
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.spislave_pkg.all;
use work.motor_control_pkg.all;

use work.peripheral_register_pkg.all;
use work.pwm_module_pkg.all;
use work.dc_motor_module_pkg.all;
use work.bldc_motor_module_pkg.all;
use work.encoder_module_pkg.all;
use work.servo_module_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- Motortestboard
      led_red_p   : out std_logic;
      led_green_p : out std_logic;
      led_blue_p  : out std_logic;

      -- BLDC 1 & 2
      bldc1_driver_p        : out bldc_driver_stage_type;
      bldc1_hall_p          : in  hall_sensor_type;
      bldc1_encoder_p       : in  encoder_type;
      bldc1_encoder_index_p : in  std_logic;

      bldc2_driver_p        : out bldc_driver_stage_type;
      bldc2_hall_p          : in  hall_sensor_type;
      bldc2_encoder_p       : in  encoder_type;
      bldc2_encoder_index_p : in  std_logic;

      -- Motor 3 & 4
      motor3_pwm1_p : out std_logic;
      motor3_pwm2_p : out std_logic;
      motor3_sd_np  : out std_logic;

      motor3_encoder_p       : in encoder_type;
      motor3_encoder_index_p : in std_logic;

      motor4_pwm1_p : out std_logic;
      motor4_pwm2_p : out std_logic;
      motor4_sd_np  : out std_logic;

      motor4_encoder_p       : in encoder_type;
      motor4_encoder_index_p : in std_logic;

      -- Encoder 6
      encoder6_p       : in encoder_type;
      encoder6_index_p : in std_logic;

      servo_p : out std_logic_vector(3 downto 1);

      -- Connections to the STM32F407
      cs_np  : in  std_logic;
      sck_p  : in  std_logic;
      miso_p : out std_logic;
      mosi_p : in  std_logic;

      load_p  : in std_logic;  -- On the rising edge encoders etc are sampled
      reset_n : in std_logic;

      -- Internal connections
      led_np : out std_logic_vector (3 downto 0);
      sw_np  : in  std_logic_vector (1 downto 0);

      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is
   signal reset_r : std_logic_vector(1 downto 0) := (others => '0');
   signal reset   : std_logic;
   signal load_r  : std_logic_vector(1 downto 0) := (others => '0');
   signal load    : std_logic;

   signal sw_1r         : std_logic_vector(1 downto 0);
   signal sw_2r : std_logic_vector(1 downto 0);
   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);

   signal motor3_sd : std_logic := '1';
   signal motor4_sd : std_logic := '1';

   signal servo_signals : std_logic_vector(2 downto 0);

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
   signal bus_register_out : busdevice_out_type;

   signal bus_pwm1_out : busdevice_out_type;
   signal bus_pwm2_out : busdevice_out_type;
   signal bus_pwm3_out : busdevice_out_type;

   signal bus_bldc1_out         : busdevice_out_type;
   signal bus_bldc1_encoder_out : busdevice_out_type;
   signal bus_bldc2_out         : busdevice_out_type;
   signal bus_bldc2_encoder_out : busdevice_out_type;

   signal bus_motor3_pwm_out     : busdevice_out_type;
   signal bus_motor3_encoder_out : busdevice_out_type;
   signal bus_motor4_pwm_out     : busdevice_out_type;
   signal bus_motor4_encoder_out : busdevice_out_type;

   signal bus_encoder6_out : busdevice_out_type;

   signal bus_servo_out : busdevice_out_type;
begin
   -- synchronize reset and other signals
   process (clk)
   begin
      if rising_edge(clk) then
         reset_r <= reset_r(0) & reset_n;

         load_r <= load_r(0) & load_p;
      end if;
   end process;

   reset <= not reset_r(1);
   load  <= load_r(1);

   ----------------------------------------------------------------------------
   -- SPI connection to the STM32F4xx and Busmaster
   -- for the internal bus
   spi : spi_slave
      port map (
         miso_p => miso_p,
         mosi_p => mosi_p,
         sck_p  => sck_p,
         csn_p  => cs_np,

         bus_o => bus_o,
         bus_i => bus_i,

         reset => reset,
         clk   => clk);
	
   bus_i.data <= bus_register_out.data or
                 bus_pwm1_out.data or bus_pwm2_out.data or bus_pwm3_out.data or
                 bus_bldc1_out.data or bus_bldc1_encoder_out.data or
                 bus_bldc2_out.data or bus_bldc2_encoder_out.data or
                 bus_motor3_pwm_out.data or bus_motor3_encoder_out.data or
                 bus_motor4_pwm_out.data or bus_motor4_encoder_out.data or
                 bus_encoder6_out.data or
                 bus_servo_out.data;

   ----------------------------------------------------------------------------
   -- Register
   preg : peripheral_register
      generic map (
         BASE_ADDRESS => 16#0000#)
      port map (
         dout_p => register_out,
         din_p  => register_in,
         bus_o  => bus_register_out,
         bus_i  => bus_o,
         reset  => reset,
         clk    => clk);

   process (clk)
   begin
      if rising_edge(clk) then
         sw_1r <= not sw_np;
         sw_2r <= sw_1r;
      end if;
   end process;

   register_in <= x"abc" & "00" & sw_2r;
   led_np <= not register_out(3 downto 0);

   ----------------------------------------------------------------------------
   -- Bus devices
   pwm_module_1 : pwm_module
      generic map (
         BASE_ADDRESS => 16#0001#,
         WIDTH        => 16,
         PRESCALER    => 2)
      port map (
         pwm_p => led_red_p,
         bus_o => bus_pwm1_out,
         bus_i => bus_o,
         reset => reset,
         clk   => clk);

   pwm_module_2 : pwm_module
      generic map (
         BASE_ADDRESS => 16#0002#,
         WIDTH        => 16,
         PRESCALER    => 2)
      port map (
         pwm_p => led_green_p,
         bus_o => bus_pwm2_out,
         bus_i => bus_o,
         reset => reset,
         clk   => clk);

   pwm_module_3 : pwm_module
      generic map (
         BASE_ADDRESS => 16#0003#,
         WIDTH        => 16,
         PRESCALER    => 2)
      port map (
         pwm_p => led_blue_p,
         bus_o => bus_pwm3_out,
         bus_i => bus_o,
         reset => reset,
         clk   => clk);

   -----------------------------------------------------------------------------
   -- BLDC motors 1 & 2

   bldc1 : bldc_motor_module
      generic map (
         BASE_ADDRESS => 16#0010#,
         WIDTH        => 10,
         PRESCALER    => 1)
      port map (
         driver_stage_p => bldc1_driver_p,
         hall_p         => bldc1_hall_p,
         bus_o          => bus_bldc1_out,
         bus_i          => bus_o,
         reset          => reset,
         clk            => clk);

   bldc1_encoder : encoder_module
      generic map (
         BASE_ADDRESS => 16#0012#)
      port map (
         encoder_p => bldc1_encoder_p,
         index_p   => bldc1_encoder_index_p,
         load_p    => load,
         bus_o     => bus_bldc1_encoder_out,
         bus_i     => bus_o,
         reset     => reset,
         clk       => clk);

   bldc2 : bldc_motor_module
      generic map (
         BASE_ADDRESS => 16#0020#,
         WIDTH        => 10,
         PRESCALER    => 1)
      port map (
         driver_stage_p => bldc2_driver_p,
         hall_p         => bldc2_hall_p,
         bus_o          => bus_bldc2_out,
         bus_i          => bus_o,
         reset          => reset,
         clk            => clk);

   bldc2_encoder : encoder_module
      generic map (
         BASE_ADDRESS => 16#0022#)
      port map (
         encoder_p => bldc2_encoder_p,
         index_p   => bldc2_encoder_index_p,
         load_p    => load,
         bus_o     => bus_bldc2_encoder_out,
         bus_i     => bus_o,
         reset     => reset,
         clk       => clk);

   ----------------------------------------------------------------------------
   -- DC Motors 3 & 4

   motor3_pwm_module : dc_motor_module
      generic map (
         BASE_ADDRESS => 16#0030#,
         WIDTH        => 12,
         PRESCALER    => 2)
      port map (
         pwm1_p => motor3_pwm1_p,
         pwm2_p => motor3_pwm2_p,
         sd_p   => motor3_sd,
         bus_o  => bus_motor3_pwm_out,
         bus_i  => bus_o,
         reset  => reset,
         clk    => clk);

   motor3_sd_np <= not motor3_sd;

   motor3_encoder_module : encoder_module
      generic map (
         BASE_ADDRESS => 16#0032#)
      port map (
         encoder_p => motor3_encoder_p,
         index_p   => motor3_encoder_index_p,
         load_p    => load,
         bus_o     => bus_motor3_encoder_out,
         bus_i     => bus_o,
         reset     => reset,
         clk       => clk);

   motor4_pwm_module : dc_motor_module
      generic map (
         BASE_ADDRESS => 16#0040#,
         WIDTH        => 12,
         PRESCALER    => 2)
      port map (
         pwm1_p => motor4_pwm1_p,
         pwm2_p => motor4_pwm2_p,
         sd_p   => motor4_sd,
         bus_o  => bus_motor4_pwm_out,
         bus_i  => bus_o,
         reset  => reset,
         clk    => clk);

   motor4_sd_np <= not motor4_sd;

   motor4_encoder_module : encoder_module
      generic map (
         BASE_ADDRESS => 16#0042#)
      port map (
         encoder_p => motor4_encoder_p,
         index_p   => motor4_encoder_index_p,
         load_p    => load,
         bus_o     => bus_motor4_encoder_out,
         bus_i     => bus_o,
         reset     => reset,
         clk       => clk);

   ----------------------------------------------------------------------------
   -- Encoder 6
   encoder6 : encoder_module
      generic map (
         BASE_ADDRESS => 16#0060#)
      port map (
         encoder_p => encoder6_p,
         index_p   => encoder6_index_p,
         load_p    => load,
         bus_o     => bus_encoder6_out,
         bus_i     => bus_o,
         reset     => reset,
         clk       => clk);

   ----------------------------------------------------------------------------
   -- Servos
   servo_module_1: servo_module
      generic map (
         BASE_ADDRESS => 16#0070#,
         SERVO_COUNT  => 3)
      port map (
         servo_p => servo_signals,
         bus_o   => bus_servo_out,
         bus_i   => bus_o,
         reset   => reset,
         clk     => clk);

   servo_p <= servo_signals;

end structural;
