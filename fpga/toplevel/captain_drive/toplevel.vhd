-------------------------------------------------------------------------------
-- Title      : Captain Drive
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2012-03-28
-- Last update: 2012-03-28
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
-- Main control board of the 2012 robot "captain".
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
use work.adc_mcp3008_pkg.all;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- BLDC 1 & 2
      bldc1_driver_p        : out bldc_driver_stage_type;
      bldc1_hall_p          : in  hall_sensor_type;
      bldc1_encoder_p       : in  encoder_type;

      bldc2_driver_p        : out bldc_driver_stage_type;
      bldc2_hall_p          : in  hall_sensor_type;
      bldc2_encoder_p       : in  encoder_type;

      -- Motor 3
      motor3_pwm1_p : out std_logic;
      motor3_pwm2_p : out std_logic;
      motor3_sd_np  : out std_logic;

      servo_p : out std_logic_vector(16 downto 1);

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

      adc_out_p : out adc_mcp3008_spi_out_type;
      adc_in_p  : in adc_mcp3008_spi_in_type;

      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is
   signal reset_r : std_logic_vector(1 downto 0) := (others => '0');
   signal reset   : std_logic;
   signal load_r  : std_logic_vector(1 downto 0) := (others => '0');
   signal load    : std_logic;

   signal sw_1r        : std_logic_vector(1 downto 0);
   signal sw_2r        : std_logic_vector(1 downto 0);
   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);
   
   signal motor3_sd : std_logic := '1';
   signal encoder_index : std_logic := '0';
   
   signal servo_signals : std_logic_vector(15 downto 0);

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
   signal bus_register_out : busdevice_out_type;
   signal bus_adc_out      : busdevice_out_type;

   signal bus_bldc1_out         : busdevice_out_type;
   signal bus_bldc1_encoder_out : busdevice_out_type;
   signal bus_bldc2_out         : busdevice_out_type;
   signal bus_bldc2_encoder_out : busdevice_out_type;

   signal bus_motor3_pwm_out     : busdevice_out_type;

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
                 bus_adc_out.data or
                 bus_bldc1_out.data or bus_bldc1_encoder_out.data or
                 bus_bldc2_out.data or bus_bldc2_encoder_out.data or
                 bus_motor3_pwm_out.data or
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

   -- component instantiation
   adc : adc_mcp3008_module
      generic map (
         BASE_ADDRESS => 16#0060#)
      port map (
         adc_out_p    => adc_out_p,
         adc_in_p     => adc_in_p,
         bus_o        => bus_adc_out,
         bus_i        => bus_o,
         adc_values_o => open,
         reset        => reset,
         clk          => clk);

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

   bldc1_encoder : encoder_module_extended
      generic map (
         BASE_ADDRESS => 16#0012#)
      port map (
         encoder_p => bldc1_encoder_p,
         index_p   => encoder_index,
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

   bldc2_encoder : encoder_module_extended
      generic map (
         BASE_ADDRESS => 16#0022#)
      port map (
         encoder_p => bldc2_encoder_p,
         index_p   => encoder_index,
         load_p    => load,
         bus_o     => bus_bldc2_encoder_out,
         bus_i     => bus_o,
         reset     => reset,
         clk       => clk);

   ----------------------------------------------------------------------------
   -- DC Motors 3

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

   ----------------------------------------------------------------------------
   -- Servos
   servo_module_1: servo_module
      generic map (
         BASE_ADDRESS => 16#0040#,
         SERVO_COUNT  => 16)
      port map (
         servo_p => servo_signals,
         bus_o   => bus_servo_out,
         bus_i   => bus_o,
         reset   => reset,
         clk     => clk);

   servo_p <= servo_signals;

end structural;
