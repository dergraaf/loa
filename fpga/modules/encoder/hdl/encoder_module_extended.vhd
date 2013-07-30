-------------------------------------------------------------------------------
-- Title      : Extended Encoder Module
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description: Connectes a quadrature decoder with a 16-bit counter and
--              encoder step time measurement to the internal bus system.
--
-- The normale encoder module is only able to count the number of encoder ticks
-- in a given timeframe. The extended module is able to also measure the time
-- between two ticks in the same direction.
-- If the direction changes or no tick is detected the value is 0xffff. Only
-- the last measurement is available and returned by a read operation.
--
-- Register map:
-- 
-- Offset | Register
-- -------+---------------
--    0   | Ticks (16-bit)
--    1   | Time between the last two ticks (16-bit)
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.encoder_module_pkg.all;
use work.quadrature_decoder_pkg.all;
use work.up_down_counter_pkg.all;
use work.input_capture_pkg.all;

-------------------------------------------------------------------------------
entity encoder_module_extended is
   generic (
      BASE_ADDRESS : integer range 0 to 16#7FFF#
      );
   port (
      encoder_p : in encoder_type;
      index_p   : in std_logic;         -- index can be used to reset the
      -- counter, set to '0' if not used
      load_p    : in std_logic;         -- Save the current encoder value in a
      -- buffer register

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk : in std_logic
      );
end encoder_module_extended;

-------------------------------------------------------------------------------
architecture behavioral of encoder_module_extended is
   -- Base address converted to a logic vector for easier access.
   constant BASE_ADDRESS_VECTOR : std_logic_vector(14 downto 0) :=
      std_logic_vector(to_unsigned(BASE_ADDRESS, 15));

   signal step         : std_logic := '0';
   signal up_down      : std_logic := '0';  -- Direction for the counter ('1' = up, '0' = down)
   signal decode_error : std_logic;  -- Decoding Error (A and B lines changes at the same time), current not used
   signal clk_capture  : std_logic;     -- Clock for input capture timer
   signal counter      : std_logic_vector(15 downto 0);
   signal timer        : std_logic_vector(15 downto 0);

   type encoder_module_extended_type is record
      counter  : std_logic_vector(15 downto 0);
      timer    : std_logic_vector(15 downto 0);
      data_out : std_logic_vector(15 downto 0);
   end record;

   signal r, rin : encoder_module_extended_type := (
      counter  => (others => '0'),
      timer    => (others => '1'),
      data_out => (others => '0'));
begin

   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(bus_i, counter, load_p, timer, r)
      variable v : encoder_module_extended_type;
   begin
      v := r;

      v.data_out := (others => '0');

      -- Load counter into own buffer
      if load_p = '1' then
         v.counter := counter;
         v.timer   := timer;
      end if;

      -- Check Bus Address (upper 14 (of 15) bits)
      if bus_i.addr(14 downto 1) = BASE_ADDRESS_VECTOR(14 downto 1) then
         if bus_i.re = '1' then
            -- Select by offset
            if bus_i.addr(0) = '0' then
               v.data_out := r.counter;
            else
               v.data_out := r.timer;
            end if;
         end if;
      end if;

      rin <= v;
   end process comb_proc;

   bus_o.data <= r.data_out;

   decoder : quadrature_decoder
      port map (
         encoder_p => encoder_p,
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

   -- clk = 50 MHz, divider = 10
   -- => clk_capture = 5 MHz
   -- 
   -- 16-bit counter
   -- => period = 2**16 / clk_capture = 0.0131s = 13.1ms
   clock_divider_capture : clock_divider
      generic map (
         DIV => 10)
      port map (
         clk_out_p => clk_capture,
         clk       => clk);

   input_capture_1 : input_capture
      port map (
         value_p  => timer,
         step_p   => step,
         dir_p    => up_down,
         clk_en_p => clk_capture,
         clk      => clk);
end behavioral;
