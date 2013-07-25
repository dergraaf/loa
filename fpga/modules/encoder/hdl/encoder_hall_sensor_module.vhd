-------------------------------------------------------------------------------
-- Title      : Hall Sensor Encoder Module
-- Project    : Loa
-------------------------------------------------------------------------------
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description: Connectes a hall sensor encoder with a 16-bit counter to
--              the internal bus system.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.encoder_module_pkg.all;
use work.motor_control_pkg.all;
use work.hall_sensor_decoder_pkg.all;
use work.up_down_counter_pkg.all;

-------------------------------------------------------------------------------
entity encoder_hall_sensor_module is
   generic (
      BASE_ADDRESS : integer range 0 to 32767
      );
   port (
      hall_sensor_p : in hall_sensor_type;
      -- counter, set to '0' if not used
      load_p        : in std_logic;     -- Save the current encoder value in a
      -- buffer register

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk : in std_logic
      );
end encoder_hall_sensor_module;

-------------------------------------------------------------------------------
architecture behavioral of encoder_hall_sensor_module is

   type encoder_hall_sensor_module_type is record
      counter  : std_logic_vector(15 downto 0);
      data_out : std_logic_vector(15 downto 0);
   end record;

   signal r, rin : encoder_hall_sensor_module_type :=
      (data_out => (others => '0'),
       counter  => (others => '0'));

   signal step         : std_logic := '0';
   signal up_down      : std_logic := '0';  -- Direction for the counter ('1' = up, '0' = down)
   signal decode_error : std_logic;     -- Decoding Error, currently not used
   signal counter      : std_logic_vector(15 downto 0);
begin

   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(bus_i, counter, load_p, r)
      variable v : encoder_hall_sensor_module_type;
   begin
      v := r;

      v.data_out := (others => '0');

      -- Load counter into own buffer
      if load_p = '1' then
         v.counter := counter;
      end if;

      -- Check Bus Address
      if bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS, 15)) then
         if bus_i.we = '1' then
         -- TODO
         elsif bus_i.re = '1' then
            v.data_out := r.counter;
         end if;
      end if;

      rin <= v;
   end process comb_proc;

   bus_o.data <= r.data_out;

   decoder : hall_sensor_decoder
      port map (
         hall_sensor_p => hall_sensor_p,
         step_p    => step,
         dir_p     => up_down,
         error_p   => decode_error,
         clk       => clk);

   up_down_counter_1 : up_down_counter
      generic map (
         WIDTH => 16)
      port map (
         clk_en_p  => step,
         up_down_p => up_down,
         value_p   => counter,
         reset     => '0',
         clk       => clk);
end behavioral;
