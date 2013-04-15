-------------------------------------------------------------------------------
-- Title      : Big Drive
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 6
-------------------------------------------------------------------------------
-- Description:
-- Main control board of the 2013 robot "big".
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
-- use work.fsmcslave_pkg.all;
use work.spislave_pkg.all;

use work.motor_control_pkg.all;
use work.utils_pkg.all;

use work.pwm_module_pkg.all;
use work.encoder_module_pkg.all;
use work.servo_module_pkg.all;
use work.imotor_module_pkg.all;
use work.adc_ad7266_pkg.all;
use work.reg_file_pkg.all;

-- Read the bus addresses from a file
use work.memory_map_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- BLDC 0 & 1
      bldc0_driver_st_p : out bldc_driver_stage_st_type;
      bldc0_hall_p      : in  hall_sensor_type;
      bldc0_encoder_p   : in  encoder_type;
      encoder0_p        : in  encoder_type;

      bldc1_driver_st_p : out bldc_driver_stage_st_type;
      bldc1_hall_p      : in  hall_sensor_type;
      bldc1_encoder_p   : in  encoder_type;
      encoder1_p        : in  encoder_type;

      -- DC Motors 0 & 1
      dc0_driver_st_p : out dc_driver_stage_st_type;
      dc1_driver_st_p : out dc_driver_stage_st_type;
      dc2_driver_st_p : out dc_driver_stage_st_type;

      -- Servos 2 and 3
      servo_p : out std_logic_vector(3 downto 2);

      -- iMotors 0 to 4
      imotor_tx_p : out std_logic_vector(4 downto 0);
      imotor_rx_p : in  std_logic_vector(4 downto 0);

      -- Pumps 0 to 3
      pump_p : out std_logic_vector(3 downto 0);

      -- Valves 0 to 3
      valve_p : out std_logic_vector(3 downto 0);

      -- FSMC Connections to the STM32F407
      --fsmc_out_p   : out   fsmc_out_type;
      --fsmc_in_p    : in    fsmc_in_type;
      --fsmc_inout_p : inout fsmc_inout_type;

      -- SPI Connection to the STM32F407
      cs_np  : in  std_logic;
      sck_p  : in  std_logic;
      miso_p : out std_logic;
      mosi_p : in  std_logic;

      load_p : in std_logic;

      -- ADC AD7266 on loa v2b / v2c
      adc_out_p : out adc_ad7266_spi_out_type;
      adc_in_p  : in  adc_ad7266_spi_in_type;

      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is
   signal load_r : std_logic_vector(1 downto 0) := (others => '0');
   signal load   : std_logic;

   -- Number of motors (BLDC and DC, excluding iMotors) directly connected on the carrier board
   constant MOTOR_COUNT : positive := 5;

   -- Non-inverted driver stages
   signal bldc0_driver_stage_s : bldc_driver_stage_type;
   signal bldc1_driver_stage_s : bldc_driver_stage_type;

   signal dc_pwm1_s : std_logic_vector(0 to 2);
   signal dc_pwm2_s : std_logic_vector(0 to 2);
   signal dc_sd_s   : std_logic_vector(0 to 2);


   signal sw_1r        : std_logic_vector(1 downto 0);
   signal sw_2r        : std_logic_vector(1 downto 0);
   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);

   signal adc_values_out       : adc_ad7266_values_type(11 downto 0);
   signal comparator_values_in : comparator_values_type(MOTOR_COUNT-1 downto 0);
   signal current_limit        : std_logic_vector(MOTOR_COUNT-1 downto 0) := (others => '0');
   signal current_limit_hold   : std_logic_vector(MOTOR_COUNT-1 downto 0) := (others => '0');
   signal current_next_period  : std_logic                                := '1';

   signal encoder_index : std_logic := '0';

   signal servo_signals : std_logic_vector(3 downto 2);
   signal pwm           : std_logic;    -- PWM for valves and pumps

   signal pumps_valves_s : std_logic_vector(15 downto 0) := (others => '0');

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
   signal bus_register_out : busdevice_out_type;
   signal bus_adc_out      : busdevice_out_type;

   signal bus_bldc0_out         : busdevice_out_type;
   signal bus_bldc0_encoder_out : busdevice_out_type;
   signal bus_encoder0_out      : busdevice_out_type;
   signal bus_bldc1_out         : busdevice_out_type;
   signal bus_bldc1_encoder_out : busdevice_out_type;
   signal bus_encoder1_out      : busdevice_out_type;

   signal bus_dc0_pwm_out : busdevice_out_type;
   signal bus_dc1_pwm_out : busdevice_out_type;
   signal bus_dc2_pwm_out : busdevice_out_type;

   signal bus_imotor_out : busdevice_out_type;

   signal bus_comparator_out : busdevice_out_type;
   signal bus_servo_out      : busdevice_out_type;

begin
   -- synchronize asynchronous signals
   process (clk)
   begin
      if rising_edge(clk) then
         load_r <= load_r(0) & load_p;
      end if;
   end process;

   load <= '1';                         -- load_r(1); TODO

   current_hold : for n in MOTOR_COUNT-1 downto 0 generate
      event_hold_stage_1 : event_hold_stage
         port map (
            dout_p   => current_limit_hold(n),
            din_p    => current_limit(n),
            period_p => current_next_period,
            clk      => clk);
   end generate;

   process (clk) is
   begin
      if rising_edge(clk) then
         if load_r = "01" then
            -- rising edge of the load signal
            current_next_period <= '1';
         else
            current_next_period <= '0';
         end if;
      end if;
   end process;

   ----------------------------------------------------------------------------
   -- FSMC connection to the STM32F4xx and Busmaster
   -- for the internal bus
   --fsmc_slave : entity work.fsmc_slave
   --   port map (
   --      bus_o        => bus_o,
   --      bus_i        => bus_i,
   --      fsmc_inout_p => fsmc_inout_p,
   --      fsmc_in_p    => fsmc_in_p,
   --      fsmc_out_p   => fsmc_out_p,
   --      clk          => clk);

   -- SPI connection to STM32F4xx
   spi_slave : entity work.spi_slave
      port map (
         miso_p => miso_p,
         mosi_p => mosi_p,
         sck_p  => sck_p,
         csn_p  => cs_np,

         bus_o => bus_o,
         bus_i => bus_i,

         clk => clk);

   bus_i.data <= bus_register_out.data or
                 bus_adc_out.data or
                 bus_bldc0_out.data or bus_bldc0_encoder_out.data or bus_encoder0_out.data or
                 bus_bldc1_out.data or bus_bldc1_encoder_out.data or bus_encoder1_out.data or
                 bus_dc0_pwm_out.data or
                 bus_dc1_pwm_out.data or
                 bus_dc2_pwm_out.data or
                 bus_imotor_out.data or
                 bus_comparator_out.data or
                 bus_servo_out.data;

   ----------------------------------------------------------------------------
   -- Register
   preg : peripheral_register
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_REG)
      port map (
         dout_p => register_out,
         din_p  => register_in,
         bus_o  => bus_register_out,
         bus_i  => bus_o,
         clk    => clk);

   register_in <= x"ff56";

   -- FIXME
   -- What does it do?      1 bit         3 bits       2 bits 2 bits
   -- register_in <= x"46" & "0" & current_limit_hold & "00" & sw_2r;

   ----------------------------------------------------------------------------
   -- component instantiation

   -----------------------------------------------------------------------------
   -- BLDC motors 0 & 1
   bldc0 : bldc_motor_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_BLDC0,
         WIDTH        => 10,
         PRESCALER    => 1)
      port map (
         driver_stage_p => bldc0_driver_stage_s,
         hall_p         => bldc0_hall_p,
         break_p        => '0',         -- TODO current_limit(1),
         bus_o          => bus_bldc0_out,
         bus_i          => bus_o,
         clk            => clk);

   bldc0_driver_stage_converter : entity work.bldc_driver_stage_converter
      port map (
         bldc_driver_stage    => bldc0_driver_stage_s,
         bldc_driver_stage_st => bldc0_driver_st_p);

   bldc0_encoder : encoder_module_extended
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_BLDC0_ENCODER)
      port map (
         encoder_p => bldc0_encoder_p,
         index_p   => encoder_index,
         load_p    => load,
         bus_o     => bus_bldc0_encoder_out,
         bus_i     => bus_o,
         clk       => clk);

   odemetry0_encoder0 : entity work.encoder_module_extended
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_ODOMETRY0_ENCODER)
      port map (
         encoder_p => encoder0_p,
         index_p   => encoder_index,
         load_p    => load,
         bus_o     => bus_encoder0_out,
         bus_i     => bus_o,
         clk       => clk);


   bldc1 : bldc_motor_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_BLDC1,
         WIDTH        => 10,
         PRESCALER    => 1)
      port map (
         driver_stage_p => bldc1_driver_stage_s,
         hall_p         => bldc1_hall_p,
         break_p        => '0',         -- TOOD current_limit(0),
         bus_o          => bus_bldc1_out,
         bus_i          => bus_o,
         clk            => clk);

   bldc1_driver_stage_converter : entity work.bldc_driver_stage_converter
      port map (
         bldc_driver_stage    => bldc1_driver_stage_s,
         bldc_driver_stage_st => bldc1_driver_st_p);

   bldc1_encoder : encoder_module_extended
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_BLDC1_ENCODER)
      port map (
         encoder_p => bldc1_encoder_p,
         index_p   => encoder_index,
         load_p    => load,
         bus_o     => bus_bldc1_encoder_out,
         bus_i     => bus_o,
         clk       => clk);

   odometry1_encoder : entity work.encoder_module_extended
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_ODOMETRY1_ENCODER)
      port map (
         encoder_p => encoder1_p,
         index_p   => encoder_index,
         load_p    => load,
         bus_o     => bus_encoder1_out,
         bus_i     => bus_o,
         clk       => clk);

   -- As 2012 but low-side inverted

   ----------------------------------------------------------------------------
   -- DC Motors 0 to 2
   dc0_pwm_module_extended : entity work.dc_motor_module_extended
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_DC0,
         WIDTH        => 10,
         PRESCALER    => 1)
      port map (
         pwm1_p  => dc_pwm1_s(0),       -- First halfbridge
         pwm2_p  => dc_pwm2_s(0),       -- Second halfbride
         sd_p    => dc_sd_s(0),         -- shutdown
         break_p => '0',
         bus_o   => bus_dc0_pwm_out,
         bus_i   => bus_o,
         clk     => clk);

   dc1_pwm_module_extended : entity work.dc_motor_module_extended
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_DC1,
         WIDTH        => 10,
         PRESCALER    => 1)
      port map (
         pwm1_p  => dc_pwm1_s(1),       -- First halfbridge
         pwm2_p  => dc_pwm2_s(1),       -- Second halfbride
         sd_p    => dc_sd_s(1),         -- shutdown
         break_p => '0',
         bus_o   => bus_dc1_pwm_out,
         bus_i   => bus_o,
         clk     => clk);

   dc2_pwm_module_extended : entity work.dc_motor_module_extended
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_DC2,
         WIDTH        => 10,
         PRESCALER    => 1)
      port map (
         pwm1_p  => dc_pwm1_s(2),       -- First halfbridge
         pwm2_p  => dc_pwm2_s(2),       -- Second halfbride
         sd_p    => dc_sd_s(2),         -- shutdown
         break_p => '0',                -- current_limit(2),
         bus_o   => bus_dc2_pwm_out,
         bus_i   => bus_o,
         clk     => clk);

   -- convert from 2012-style motor-bridge to 2013-style
   dc0_driver_stage_converter : entity work.dc_driver_stage_converter
      port map (
         pwm1_in_p                => dc_pwm1_s(0),
         pwm2_in_p                => dc_pwm2_s(0),
         sd_in_p                  => dc_sd_s(0),
         dc_driver_stage_st_out_p => dc0_driver_st_p);

   dc1_driver_stage_converter : entity work.dc_driver_stage_converter
      port map (
         pwm1_in_p                => dc_pwm1_s(1),
         pwm2_in_p                => dc_pwm2_s(1),
         sd_in_p                  => dc_sd_s(1),
         dc_driver_stage_st_out_p => dc1_driver_st_p);

   dc2_driver_stage_converter : entity work.dc_driver_stage_converter
      port map (
         pwm1_in_p                => dc_pwm1_s(2),
         pwm2_in_p                => dc_pwm2_s(2),
         sd_in_p                  => dc_sd_s(2),
         dc_driver_stage_st_out_p => dc2_driver_st_p);

   ----------------------------------------------------------------------------
   -- All iMotors with one module
   imotor_module : entity work.imotor_module
      generic map (
         BASE_ADDRESS    => BASE_ADDRESS_IMOTOR,
         MOTORS          => 5,
         DATA_WORDS_SEND => 2,
         DATA_WORDS_READ => 3)
      port map (
         tx_out_p => imotor_tx_p,
         rx_in_p  => imotor_rx_p,
         bus_o    => bus_imotor_out,
         bus_i    => bus_o,
         clk      => clk);

   ----------------------------------------------------------------------------
   -- Pumps and Valves
   -- Do PWM for pumps because battery voltage is higher than nominal voltage
   -- of pumps

   pumps_valves_register : entity work.peripheral_register
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_PUMPS_VALVES)
      port map (
         dout_p => pumps_valves_s,
         din_p  => (others => '0'),
         bus_o  => open,
         bus_i  => bus_o,
         clk    => clk);

   pwm_1 : entity work.pwm
      generic map (
         WIDTH => 12)
      port map (
         clk_en_p => '1',               -- no prescaler
         value_p  => x"800",
         output_p => pwm,
         reset    => '0',
         clk      => clk);

   valve_p <= pumps_valves_s(3 downto 0) when pwm = '1' else (others => '0');
   pump_p  <= pumps_valves_s(7 downto 4) when pwm = '1' else (others => '0');



   ----------------------------------------------------------------------------
   -- Servos
   servo_module_1 : servo_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_SERVO,
         SERVO_COUNT  => 2)
      port map (
         servo_p => servo_signals,
         bus_o   => bus_servo_out,
         bus_i   => bus_o,
         clk     => clk);

   servo_p <= not servo_signals;

   ----------------------------------------------------------------------------
   -- Current limiter
   -- 0x0080/1 -> BLDC1 (upper, lower)
   -- 0x0082/3 -> BLDC2 (upper, lower)
   -- 0x0084/5 -> DC0   (upper, lower)
   -- 0x0086/7 -> DC1   (upper, lower)
   -- 0x0088/9 -> DC2   (upper, lower)
   comparator_module_1 : comparator_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_COMPARATOR,
         CHANNELS     => MOTOR_COUNT)
      port map (
         value_p    => comparator_values_in,
         overflow_p => current_limit,
         bus_o      => bus_comparator_out,
         bus_i      => bus_o,
         clk        => clk);

   convert : for n in MOTOR_COUNT-1 downto 0 generate
      comparator_values_in(n) <= adc_values_out(n)(11 downto 2);
   end generate;

   ----------------------------------------------------------------------------
   -- ADC
--   adc_ad7266_single_ended_module : entity work.adc_ad7266_single_ended_module
--      generic map (
--         BASE_ADDRESS => BASE_ADDRESS_ADC)
--      port map (
--         adc_out_p    => adc_out_p,
--         adc_in_p     => adc_in_p,
--         bus_o        => bus_adc_out,
--         bus_i        => bus_o,
--         adc_values_o => adc_values_out,
--         clk          => clk);

   adc_out_p.sgl_diff      <= '0';
   adc_out_p.sck           <= '1';
   adc_out_p.cs_n          <= '1';
   adc_out_p.a(2 downto 0) <= (others => '0');



end structural;
