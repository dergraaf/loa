-------------------------------------------------------------------------------
-- Title      : Motor control
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
--
-- Generates a symmetric (center-aligned) PWM with deadtime
--
-- Memory Map:
--   Base Address + 0     | W |   PWM value
--   Base Address + 0     | R |   unused
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.motor_control_pkg.all;
use work.symmetric_pwm_deadtime_pkg.all;
use work.commutation_pkg.all;

entity bldc_motor_module is
   generic (
      BASE_ADDRESS : integer range 0 to 16#7FFF#;

      -- Number of bits for the PWM generation (e.g. 12 => 0..4095)
      WIDTH     : positive := 12;
      PRESCALER : positive
      );
   port (
      driver_stage_p : out bldc_driver_stage_type;
      hall_p         : in  hall_sensor_type;

      -- Disable switching
      break_p : in std_logic;

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk   : in std_logic
      );
end bldc_motor_module;

-------------------------------------------------------------------------------
architecture behavioral of bldc_motor_module is

   type bldc_motor_module_type is record
      data_out  : std_logic_vector(15 downto 0);         -- currently not used
      pwm_value : std_logic_vector(WIDTH - 1 downto 0);  -- PWM value
      sd        : std_logic;                             -- Shutdown
      dir       : std_logic;
   end record;

   signal clk_en : std_logic := '1';
   signal center : std_logic;           -- currently not used
   signal pwm    : half_bridge_type;

   signal r, rin : bldc_motor_module_type := (
      data_out  => (others => '0'),
      pwm_value => (others => '0'),
      sd        => '1',
      dir       => '0'
      );
begin

   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(bus_i.addr, bus_i.data(15),
                       bus_i.data(WIDTH - 1 downto 0), bus_i.re, bus_i.we, r)
      variable v : bldc_motor_module_type;
   begin
      v := r;

      -- Set default values
      v.data_out := (others => '0');

      -- Check Bus Address
      if bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS, 15)) then
         if bus_i.we = '1' then
            v.pwm_value := bus_i.data(WIDTH - 1 downto 0);
            v.sd        := bus_i.data(15);
            v.dir       := bus_i.data(14);
         elsif bus_i.re = '1' then
         -- v.data_out := r.counter;
         end if;
      end if;

      rin <= v;
   end process comb_proc;

   bus_o.data <= r.data_out;

   -- Generate clock for the PWM generator
   divider : clock_divider
      generic map (
         DIV => PRESCALER)
      port map (
         clk_out_p => clk_en,
         clk       => clk);

   pwm_generator : symmetric_pwm_deadtime
      generic map (
         WIDTH  => WIDTH,
         -- Deadtime settings:
         -- 50 MHz clock => 20ns per cycle
         -- T_DEAD = 20 * 20ns = 400ns
         T_DEAD => 20)
      port map (
         pwm_p    => pwm,
         center_p => center,
         clk_en_p => clk_en,
         value_p  => r.pwm_value,
         break_p  => break_p,
         reset    => '0',
         clk      => clk);

   commutation_1 : commutation
      port map (
         driver_stage_p => driver_stage_p,
         hall_p         => hall_p,
         pwm_p          => pwm,
         dir_p          => r.dir,
         sd_p           => r.sd,
         clk            => clk);

end behavioral;
