-------------------------------------------------------------------------------
-- Title      : Servo Sequencer
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-23
-- Last update: 2011-12-31
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description: Generates eight periode begin signals shifted by 2.5ms
-- (8 x 2.5ms = 20ms). An additional helper signal is generated ~0.85 ms after
-- the periode begin signal.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package servo_sequencer_pkg is

   component servo_sequencer is
      port (
         load_p    : out std_logic_vector(7 downto 0);
         enable_p  : out std_logic_vector(7 downto 0);
         counter_p : out std_logic_vector(15 downto 0);
         reset     : in  std_logic;
         clk       : in  std_logic);
   end component servo_sequencer;

end package servo_sequencer_pkg;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------
entity servo_sequencer is

   port (
      load_p : out std_logic_vector(7 downto 0);
      enable_p : out std_logic_vector(7 downto 0);

      -- Servo periode counter. The channel compare this value to their own value
      -- and keep their output set to one as long as the counter is smaller then
      -- the compare value.
      counter_p : out std_logic_vector(15 downto 0);

      reset : in std_logic;             -- Output disable (if set to '1')
      clk   : in std_logic              -- must be 50 MHz or the constants have
                                        -- to be adapted.
      );

end servo_sequencer;

-------------------------------------------------------------------------------

architecture behavioral of servo_sequencer is
   constant CLK_FREQENCY : real := real(50e6);  -- 50 MHz

   -- 2.5ms
   constant PERIODE_SLICE_TICKS : integer :=
      integer((CLK_FREQENCY * 2.5e-3) - 1.0);

   -- ~0.85ms
   constant PERIODE_SIGNAL_TICKS : integer :=
      integer((1.5e-3 - (real(2**16) / CLK_FREQENCY / 2.0)) * CLK_FREQENCY - 1.0);
   
   type servo_sequencer_state_type is (STATE_IDLE, STATE_LOAD, STATE_WAIT, STATE_SIGNAL);

   type servo_sequencer_type is record
      state : servo_sequencer_state_type;

      periode_counter : integer range 0 to PERIODE_SLICE_TICKS;
      signal_counter  : integer range 0 to 2**16;
      index           : integer range 0 to 8;

      load   : std_logic_vector(7 downto 0);
      enable : std_logic_vector(7 downto 0);
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : servo_sequencer_type := (
      state           => STATE_LOAD,
      periode_counter => 0,
      signal_counter  => 0,
      index           => 0,
      load            => (others => '0'),
      enable          => (others => '0'));
begin
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(r, r.enable, r.index, r.load, r.periode_counter,
                       r.signal_counter, r.state, reset)
      variable v : servo_sequencer_type;
   begin
      v := r;

      -- set default values
      v.enable := (others => '0');
      v.load   := (others => '0');

      v.periode_counter := r.periode_counter + 1;
      if v.periode_counter = PERIODE_SLICE_TICKS then
         v.periode_counter := 0;

         v.index := (r.index + 1) mod 8;
         v.state := STATE_LOAD;
      elsif v.periode_counter = PERIODE_SIGNAL_TICKS then
         v.state := STATE_SIGNAL;
      end if;

      case r.state is
         when STATE_LOAD =>
            v.load(r.index) := '1';
            v.state         := STATE_WAIT;
            
         when STATE_WAIT =>
            v.signal_counter  := 0;
            v.enable(r.index) := '1';

         when STATE_SIGNAL =>
            v.signal_counter := r.signal_counter + 1;
            if v.signal_counter = 2**16 then
               v.signal_counter := 0;
               v.state          := STATE_IDLE;
            else
               v.enable(r.index) := '1';
            end if;
            
         when others => null;
      end case;

      if reset = '1' then
         v.state           := STATE_LOAD;
         v.signal_counter  := 0;
         v.periode_counter := 0;
         v.index           := 0;
         v.load            := (others => '0');
         v.enable          := (others => '0');
      end if;

      -- register outputs
      counter_p <= std_logic_vector(to_unsigned(r.signal_counter, counter_p'length));

      load_p   <= r.load;
      enable_p <= r.enable;

      rin <= v;
   end process comb_proc;

end behavioral;
