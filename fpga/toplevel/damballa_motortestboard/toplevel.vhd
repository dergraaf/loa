-------------------------------------------------------------------------------
-- Title      : Motortestboard
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-14
-- Last update: 2011-12-18
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
-- ...
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.spislave_pkg.all;
use work.motor_control_pkg.all;

use work.pwm_module_pkg.all;
use work.bldc_motor_module_pkg.all;
use work.encoder_module_pkg.all;

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
      motor3_pwm_p  : out std_logic;
      motor3_pwm_np : out std_logic;
      motor3_sd_np  : out std_logic;

      motor3_encoder_p       : in encoder_type;
      motor3_encoder_index_p : in std_logic;

      motor4_pwm_p  : out std_logic;
      motor4_pwm_np : out std_logic;
      motor4_sd_np  : out std_logic;

      motor4_encoder_p       : in encoder_type;
      motor4_encoder_index_p : in std_logic;

      -- Encoder 6
      encoder6_p       : in encoder_type;
      encoder6_index_p : in std_logic;

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

   signal led : std_logic_vector(3 downto 0);

   signal motor3_pwm : std_logic := '0';
   signal motor4_pwm : std_logic := '0';

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
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

   -- blinking led
   process
      variable cnt : integer range 0 to 24999999;
   begin
      wait until rising_edge(clk);
      if reset = '1' then
         led <= "0000";
         cnt := 24999999;
      else
         -- 0...24999999 = 25000000 Takte = 1/2 Sekunde bei 50MHz 
         if cnt < (24999999 - 1) then
            cnt := cnt + 1;
         else
            cnt    := 0;
            led(0) <= not led(0);
         end if;
      end if;
   end process;

   led_np <= not led;

   -----------------------------------------------------------------------------
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
         clk   => clk
         );

   bus_i.data <= bus_pwm1_out.data or bus_pwm2_out.data or bus_pwm3_out.data or
                 bus_bldc1_out.data or bus_bldc1_encoder_out.data or
                 bus_bldc2_out.data or bus_bldc2_encoder_out.data or
                 bus_motor3_pwm_out.data or bus_motor3_encoder_out.data or
                 bus_motor4_pwm_out.data or bus_motor4_encoder_out.data or
                 bus_encoder6_out.data;

   -----------------------------------------------------------------------------
   -- Bus devices
   pwm_module_1 : pwm_module
      generic map (
         BASE_ADDRESS => 0,
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
         BASE_ADDRESS => 1,
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
         BASE_ADDRESS => 2,
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
         BASE_ADDRESS => 10,
         WIDTH        => 12,
         PRESCALER    => 2)
      port map (
         driver_stage_p => bldc1_driver_p,
         hall_p         => bldc1_hall_p,
         bus_o          => bus_bldc1_out,
         bus_i          => bus_o,
         reset          => reset,
         clk            => clk);

   bldc1_encoder : encoder_module
      generic map (
         BASE_ADDRESS => 11)
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
         BASE_ADDRESS => 20,
         WIDTH        => 12,
         PRESCALER    => 2)
      port map (
         driver_stage_p => bldc2_driver_p,
         hall_p         => bldc2_hall_p,
         bus_o          => bus_bldc2_out,
         bus_i          => bus_o,
         reset          => reset,
         clk            => clk);

   bldc2_encoder : encoder_module
      generic map (
         BASE_ADDRESS => 21)
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

   motor3_pwm_module : pwm_module
      generic map (
         BASE_ADDRESS => 30,
         WIDTH        => 12,
         PRESCALER    => 2)
      port map (
         pwm_p => motor3_pwm,
         bus_o => bus_motor3_pwm_out,
         bus_i => bus_o,
         reset => reset,
         clk   => clk);

   motor3_pwm_p  <= motor3_pwm;
   motor3_pwm_np <= not motor3_pwm;
	motor3_sd_np  <= '0';					-- FIXME

   motor3_encoder_module : encoder_module
      generic map (
         BASE_ADDRESS => 31)
      port map (
         encoder_p => motor3_encoder_p,
         index_p   => motor3_encoder_index_p,
         load_p    => load,
         bus_o     => bus_motor3_encoder_out,
         bus_i     => bus_o,
         reset     => reset,
         clk       => clk);

   motor4_pwm_module : pwm_module
      generic map (
         BASE_ADDRESS => 40,
         WIDTH        => 12,
         PRESCALER    => 2)
      port map (
         pwm_p => motor4_pwm,
         bus_o => bus_motor4_pwm_out,
         bus_i => bus_o,
         reset => reset,
         clk   => clk);

   motor4_pwm_p  <= motor4_pwm;
   motor4_pwm_np <= not motor4_pwm;
	motor4_sd_np  <= '0';					-- FIXME

   motor4_encoder_module : encoder_module
      generic map (
         BASE_ADDRESS => 41)
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
         BASE_ADDRESS => 60)
      port map (
         encoder_p => encoder6_p,
         index_p   => encoder6_index_p,
         load_p    => load,
         bus_o     => bus_encoder6_out,
         bus_i     => bus_o,
         reset     => reset,
         clk       => clk);

end structural;
