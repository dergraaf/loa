-------------------------------------------------------------------------------
-- Title      : Servo Channel
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-23
-- Last update: 2011-12-31
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: Generates a single servo signal in combination with the
-- servo_sequencer.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package servo_channel_pkg is

   component servo_channel is
      port (
         servo_p         : out std_logic;
         compare_value_p : in  std_logic_vector(15 downto 0);
         load_p          : in  std_logic;
         counter_p       : in  std_logic_vector(15 downto 0);
         enable_p        : in  std_logic;
         clk             : in  std_logic);
   end component servo_channel;

end package servo_channel_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
entity servo_channel is

   port (
      servo_p : out std_logic;          -- Servo signal

      compare_value_p : in std_logic_vector(15 downto 0);
      load_p          : in std_logic;   -- Load a new compare value
      -- Counter for the variable part of the signal (stays 0 for the
      -- static part => first 0.8ms)
      counter_p       : in std_logic_vector(15 downto 0);
      enable_p        : in std_logic;

      clk : in std_logic
      );

end servo_channel;

-------------------------------------------------------------------------------

architecture behavioral of servo_channel is

   type servo_channel_type is record
      servo_signal  : std_logic;
      compare_value : std_logic_vector(15 downto 0);
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : servo_channel_type := (
      servo_signal  => '0',
      compare_value => (others => '0'));
begin
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(compare_value_p, counter_p, enable_p, load_p, r,
                       r.compare_value, r.servo_signal)
      variable v : servo_channel_type;
   begin
      v := r;

      -- default values
      v.servo_signal := '0';

      if load_p = '1' then
         v.compare_value := compare_value_p;
      end if;

      if counter_p < r.compare_value then
         v.servo_signal := enable_p;
      end if;

      -- register outputs
      servo_p <= r.servo_signal;

      rin <= v;
   end process comb_proc;

end behavioral;
