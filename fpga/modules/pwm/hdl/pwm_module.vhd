-------------------------------------------------------------------------------
-- PWM Module
--
-- Connects the pwm entity to the internal bus system.
-- 
-- @author    Fabian Greif
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.pwm_pkg.all;
use work.utils_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity pwm_module is
   generic (
      BASE_ADDRESS : integer range 0 to 32767;
      WIDTH        : positive := 12;  -- Number of bits for the PWM generation (e.g. 12 => 0..4095)
      PRESCALER    : positive := 2
      );
   port (
      pwm_p : out std_logic;

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      reset : in std_logic;
      clk   : in std_logic
      );
end pwm_module;

-------------------------------------------------------------------------------
architecture behavioral of pwm_module is

   type pwm_module_type is record
      pwm : std_logic_vector (WIDTH - 1 downto 0);
   end record;

   signal r, rin : pwm_module_type;

   signal clk_en : std_logic;
begin

   seq_proc : process(reset, clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then
            r.pwm <= (others => '0');
         else
            r <= rin;
         end if;
      end if;
   end process seq_proc;

   comb_proc : process(r, bus_i)
      variable v : pwm_module_type;
   begin
      v := r;

      if bus_i.we = '1' and
         bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS, 15)) then
         v.pwm := bus_i.data(WIDTH - 1 downto 0);
      end if;

      rin <= v;
   end process comb_proc;

   bus_o.data <= (others => '0');

   -- Generate clock for the PWM generator
   divider : clock_divider
      generic map (
         DIVIDER => PRESCALER)
      port map (
         clk_out_p => clk_en,
         clk       => clk);

   -- Generate a PWM
   pwm_1 : pwm
      generic map (
         WIDTH => WIDTH)
      port map (
         clk_en_p => clk_en,
         value_p  => r.pwm,
         output_p => pwm_p,
         reset    => reset,
         clk      => clk);
end behavioral;
