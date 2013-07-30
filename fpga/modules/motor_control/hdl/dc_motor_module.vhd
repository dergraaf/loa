-------------------------------------------------------------------------------
-- Title      : Motor control for DC Motors
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
--
-- Generates a symmetric (center-aligned) PWM without deadtime
--
-- Register Map:
--   Base Address + 0   | W |   PWM
--   Base Address + 0   | R |   unused
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.motor_control_pkg.all;
use work.symmetric_pwm_pkg.all;

entity dc_motor_module is
   generic (
      BASE_ADDRESS : integer range 0 to 16#7FFF#;
      WIDTH        : positive := 12;  -- Number of bits for the PWM generation (e.g. 12 => 0..4095)
      PRESCALER    : positive
      );
   port (
      pwm1_p : out std_logic;           -- Halfbridge 1
      pwm2_p : out std_logic;           -- Halfbridge 2
      sd_p   : out std_logic;           -- Shutdown

      -- Disable switching
      break_p : in std_logic;

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk : in std_logic
      );
end dc_motor_module;

-------------------------------------------------------------------------------
architecture behavioral of dc_motor_module is

   type dc_motor_module_type is record
      data_out  : std_logic_vector(15 downto 0);         -- currently not used
      pwm_value : std_logic_vector(WIDTH - 1 downto 0);  -- PWM value
      sd        : std_logic;                             -- Shutdown
   end record;

   signal clk_en    : std_logic := '1';
   signal underflow : std_logic;        -- currently not used
   signal overflow  : std_logic;        -- currently not used

   signal pwm : std_logic;

   signal r, rin : dc_motor_module_type := (
      data_out  => (others => '0'),
      pwm_value => (others => '0'),
      sd        => '1'
      );

begin

   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(bus_i.addr, bus_i.data(15),
                       bus_i.data(WIDTH - 1 downto 0), bus_i.re, bus_i.we, pwm, break_p,
                       r, r.sd)
      variable v : dc_motor_module_type;
   begin
      v := r;

      -- Set default values
      v.data_out := (others => '0');

      -- Check Bus Address
      if bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS, 15)) then
         if bus_i.we = '1' then
            v.pwm_value := bus_i.data(WIDTH - 1 downto 0);
            v.sd        := bus_i.data(15);
         elsif bus_i.re = '1' then
         -- v.data_out := r.counter;
         end if;
      end if;

      if r.sd = '1' then
         pwm1_p <= '0';
         pwm2_p <= '0';
         sd_p   <= '1';
      else
         if break_p = '1' then
            pwm1_p <= '0';
            pwm2_p <= '0';
         else
            pwm1_p <= pwm;
            pwm2_p <= not pwm;
         end if;
         sd_p <= '0';
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

   pwm_generator : symmetric_pwm
      generic map (
         WIDTH => WIDTH)
      port map (
         pwm_p       => pwm,
         underflow_p => underflow,
         overflow_p  => overflow,
         clk_en_p    => clk_en,
         value_p     => r.pwm_value,
         reset       => '0',
         clk         => clk);

end behavioral;
