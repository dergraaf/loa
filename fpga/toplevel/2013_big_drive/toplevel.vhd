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
use work.spislave_pkg.all;
use work.motor_control_pkg.all;
use work.utils_pkg.all;

use work.pwm_module_pkg.all;
use work.motor_control_pkg.all;
use work.encoder_module_pkg.all;
use work.servo_module_pkg.all;
use work.adc_mcp3008_pkg.all;
use work.reg_file_pkg.all;

-- Read the bus addresses from a file
use work.memory_map_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- BLDC 0 & 1
      bldc0_driver_p  : out bldc_driver_stage_type;
      bldc0_hall_p    : in  hall_sensor_type;
      bldc0_encoder_p : in  encoder_type;
      encoder0_p      : in  encoder_type;

      bldc1_driver_p  : out bldc_driver_stage_type;
      bldc1_hall_p    : in  hall_sensor_type;
      bldc1_encoder_p : in  encoder_type;
      encoder1_p      : in  encoder_type;

      -- DC Motors 0 & 1
      dc0_driver_p : out dc_driver_stage_type;
      dc1_driver_p : out dc_driver_stage_type;
      dc2_driver_p : out dc_driver_stage_type;

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
      -- TBD

      load_p : in std_logic;  -- On the rising edge encoders etc are sampled

      -- ADC on loa v2b / v2c
      -- TBD

      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is
   signal load_r : std_logic_vector(1 downto 0) := (others => '0');
   signal load   : std_logic;
   
   -- Number of motors (BLDC and DC, excluding iMotors) directly connected on the carrier board
   constant MOTOR_COUNT : positive := 5;
   
   signal sw_1r        : std_logic_vector(1 downto 0);
   signal sw_2r        : std_logic_vector(1 downto 0);
   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);

   signal adc_values_out       : adc_mcp3008_values_type(7 downto 0);
   signal comparator_values_in : comparator_values_type(MOTOR_COUNT-1 downto 0);
   signal current_limit        : std_logic_vector(MOTOR_COUNT-1 downto 0) := (others => '0');
   signal current_limit_hold   : std_logic_vector(MOTOR_COUNT-1 downto 0) := (others => '0');
   signal current_next_period  : std_logic                    := '1';

   signal encoder_index : std_logic := '0';

   signal servo_signals : std_logic_vector(3 downto 2);

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

   signal bus_motor3_pwm_out : busdevice_out_type;
   signal bus_comparator_out : busdevice_out_type;
   signal bus_servo_out      : busdevice_out_type;
begin
   -- synchronize asynchronous  signals
   process (clk)
   begin
      if rising_edge(clk) then
         -- load signal for the synchronisation of the encoder signals
         load_r <= load_r(0) & load_p;
      end if;
   end process;

   load <= load_r(1);

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

   -- TBD

   bus_i.data <= bus_register_out.data or
                 bus_adc_out.data or
                 bus_bldc0_out.data or bus_bldc0_encoder_out.data or
                 bus_bldc1_out.data or bus_bldc1_encoder_out.data or
                 bus_motor3_pwm_out.data or
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

   -- FIXME
   -- What does it do?
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
         driver_stage_p => bldc0_driver_p,
         hall_p         => bldc0_hall_p,
         break_p        => current_limit(1),
         bus_o          => bus_bldc0_out,
         bus_i          => bus_o,
         clk            => clk);

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

   -- odometry encoder 0
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
         driver_stage_p => bldc1_driver_p,
         hall_p         => bldc1_hall_p,
         break_p        => current_limit(0),
         bus_o          => bus_bldc1_out,
         bus_i          => bus_o,
         clk            => clk);

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

   ----------------------------------------------------------------------------
   -- DC Motors 0 to 2
   --motor3_pwm_module : dc_motor_module
   --   generic map (
   --      BASE_ADDRESS => BASE_ADDRESS_DC0,
   --      WIDTH        => 10,
   --      PRESCALER    => 1)
   --   port map (
   --      pwm1_p  => motor3_pwm1_p,
   --      pwm2_p  => motor3_pwm2_p,
   --      sd_p    => motor3_sd,
   --      break_p => current_limit(2),
   --      bus_o   => bus_motor3_pwm_out,
   --      bus_i   => bus_o,
   --      clk     => clk);

--   motor3_sd_np <= not motor3_sd;

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
      comparator_values_in(n) <= adc_values_out(n);
   end generate;

end structural;
