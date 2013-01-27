-------------------------------------------------------------------------------
-- Title      : Servo Module
-------------------------------------------------------------------------------
-- File       : servo_module.vhd
-- Author     : Fabian <fabian@kleinvieh>
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;

package servo_module_pkg is

   component servo_module is
      generic (
         BASE_ADDRESS : integer range 0 to 32767;
         SERVO_COUNT  : positive);
      port (
         servo_p : out std_logic_vector(SERVO_COUNT-1 downto 0);
         bus_o   : out busdevice_out_type;
         bus_i   : in  busdevice_in_type;
         reset   : in  std_logic;
         clk     : in  std_logic);
   end component servo_module;

end package servo_module_pkg;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;

use work.servo_sequencer_pkg.all;
use work.servo_channel_pkg.all;

entity servo_module is
   generic (
      BASE_ADDRESS : integer range 0 to 32767;
      SERVO_COUNT  : positive           -- Number of conntected servos
      );
   port (
      servo_p : out std_logic_vector(SERVO_COUNT-1 downto 0);

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      reset : in std_logic;
      clk   : in std_logic
      );

end servo_module;

-------------------------------------------------------------------------------
architecture behavioral of servo_module is
   -- Maximum servo index
   constant SERVO_MAX : natural := SERVO_COUNT - 1;

   -- Number of Bits needed to encode the given number of servos
   constant SERVO_BUS_WIDTH : natural := required_bits(SERVO_MAX);

   -- Base address converted to a logic vector for easier access.
   constant BASE_ADDRESS_VECTOR : std_logic_vector(14 downto 0) :=
      std_logic_vector(to_unsigned(BASE_ADDRESS, 15));
   
   subtype servo_value_type is std_logic_vector(15 downto 0);
   type servo_value_array_type is array (natural range 0 to SERVO_MAX) of
      servo_value_type;

   signal counter : std_logic_vector(15 downto 0);  -- Servo counter

   --  Servo channel enable (can be connected to multiple channels)
   signal enable : std_logic_vector(7 downto 0);
   signal load   : std_logic_vector(7 downto 0);  -- Load new compare value

   type servo_module_type is record
      servo_value : servo_value_array_type;
   end record;

   signal r, rin : servo_module_type := (servo_value => (others => (others => '0')));
begin
   seq_proc : process(reset, clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then
            r <= (servo_value => (others => (others => '0')));
         else
            r <= rin;
         end if;
      end if;
   end process seq_proc;

   comb_proc : process(bus_i.addr(14 downto SERVO_BUS_WIDTH), bus_i.data,
                       bus_i.addr(SERVO_BUS_WIDTH downto 0), bus_i.we, r)
      variable index : integer range 0 to 2**SERVO_BUS_WIDTH - 1;
      variable v     : servo_module_type;
   begin
      v := r;

      -- Check Bus Address
      if bus_i.addr(14 downto SERVO_BUS_WIDTH) =
         BASE_ADDRESS_VECTOR(14 downto SERVO_BUS_WIDTH) then

         index := to_integer(unsigned(bus_i.addr(SERVO_BUS_WIDTH downto 0)));
         if index <= SERVO_MAX then
            if bus_i.we = '1' then
               v.servo_value(index) := bus_i.data;
            --elsif bus_i.re = '1' then
            --   v.dout := din_p;
            end if;
         end if;
      end if;

      rin <= v;
   end process comb_proc;

   servo_sequencer_1 : servo_sequencer
      port map (
         load_p    => load,
         enable_p  => enable,
         counter_p => counter,
         reset     => reset,
         clk       => clk);

   servo_channels : for i in 0 to SERVO_MAX generate
      servo_channel_1 : servo_channel
         port map (
            servo_p         => servo_p(i),
            compare_value_p => r.servo_value(i),
            load_p          => load(i mod 8),
            enable_p        => enable(i mod 8),
            counter_p       => counter,
            clk             => clk);
   end generate servo_channels;
end behavioral;
