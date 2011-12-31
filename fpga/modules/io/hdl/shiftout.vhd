-------------------------------------------------------------------------------
-- Title      : Shift Out Register (74HC(T)595 and similar types)
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : shiftout.vhd
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-31
-- Last update: 2011-12-31
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description:
--
-- Maximum frequency 74HC595  : 100 MHz
--                   74HCT595 : 57 MHz 
--
-- At 50 MHz it takes about 360ns (+ 25ns propgation delay from the 74HCT595)
-- until the output is visible at the outputs. The maximum latency of 380ns
-- appears it a transaction is has started directly before the transaction.
--
-- ## Pins
-- 
-- Master Reset (Pin 10) should be connected to high-level,
-- Output Enable (Pin 13) should be at low-level.
-- 
-- ## Waveform
-- 
--        1   2   3   4   5   6   7   8   9  10  11  12  13  14  15  16  17  18  19
--         _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _  
-- clke __| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |
--             ___     ___     ___     ___     ___     ___     ___     ___
-- sck  ______|   |___|   |___|   |___|   |___|   |___|   |___|   |___|   |_________
--         _______ _______ _______ _______ _______ _______ _______ _______ 
-- dout __X_______X_______X_______X_______X_______X_______X_______X_______X_________
-- bit  0 1       2       3       4       5       6       7       8       9 
--                                                                             ___
-- load ______________________________________________________________________|   |__
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package shiftout_pkg is

   type shiftout_out_type is record
      sck  : std_logic;                 -- or SH_CP (Pin 11)
      dout : std_logic;                 -- or DS (Pin 14)
      load : std_logic;                 -- or ST_CP (Pin 12)
   end record;

   component shiftout is
      port (
         register_p : out shiftout_out_type;
         value_p    : in  std_logic_vector(7 downto 0);
         clk        : in  std_logic);
   end component shiftout;

end package shiftout_pkg;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.shiftout_pkg.all;

entity shiftout is
   
   port (
      register_p : out shiftout_out_type;
      value_p    : in  std_logic_vector(7 downto 0);
      clk        : in  std_logic
      );

end entity shiftout;

architecture behavioral of shiftout is
   signal clk_enable : std_logic := '1';  -- clock enable for the SCK speed
   
   type shiftout_state_type is (
      STATE_IDLE, STATE_WRITE, STATE_WRITE_NEXT, STATE_LOAD, STATE_LOAD_WAIT);

   type shiftout_type is record
      state : shiftout_state_type;

      value        : std_logic_vector(7 downto 0);  -- copy of the input value
      -- value currently loaded into the shift register
      value_buffer : std_logic_vector(7 downto 0);
      bitcount     : integer range 0 to 9;          -- Number of bits loaded

      o : shiftout_out_type;
   end record shiftout_type;

   signal r, rin : shiftout_type := (
      state        => STATE_IDLE,
      value        => (others => '0'),
      value_buffer => (others => '0'),
      bitcount     => 0,
      o            => (
         sck       => '0',
         dout      => '0',
         load      => '0'));
begin

   seq_proc : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process (clk_enable, r, r.bitcount, r.o, r.state, r.value,
                        r.value_buffer(6 downto 0), r.value_buffer(7), value_p) is
      variable v : shiftout_type;
   begin
      v := r;

      case r.state is
         when STATE_IDLE =>
            -- Wait until the input changes
            if r.value /= value_p then
               v.value        := value_p;
               v.value_buffer := value_p;

               v.bitcount := 0;
               v.state    := STATE_WRITE_NEXT;
            end if;

         -- Clock high
         when STATE_WRITE =>
            if clk_enable = '1' then
               v.o.sck := '1';
               v.state := STATE_WRITE_NEXT;
            end if;

         -- Clock low and switch to the next bit
         when STATE_WRITE_NEXT =>
            if clk_enable = '1' then
               v.o.sck := '0';

               -- MSB first
               v.o.dout       := r.value_buffer(7);
               v.value_buffer := r.value_buffer(6 downto 0) & '0';

               v.bitcount := r.bitcount + 1;
               if r.bitcount = 8 then
                  v.state := STATE_LOAD;
               else
                  v.state := STATE_WRITE;
               end if;
            end if;

         -- Load high
         when STATE_LOAD =>
            if clk_enable = '1' then
               v.o.dout := '0';
               v.o.load := '1';

               v.state := STATE_LOAD_WAIT;
            end if;

         -- Load low
         when STATE_LOAD_WAIT =>
            if clk_enable = '1' then
               v.o.load := '0';
               v.state  := STATE_IDLE;
            end if;
      end case;

      -- register outputs
      register_p <= r.o;

      rin <= v;
   end process comb_proc;

   -- TODO clk_enable generation
   -- to adapt to higher clk frequencies
end architecture behavioral;
