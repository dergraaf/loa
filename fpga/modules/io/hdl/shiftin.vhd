-------------------------------------------------------------------------------
-- Title      : Shift In Register (74HC(T)165 and similar types)
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : shiftin.vhd
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-31
-- Last update: 2011-12-31
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description:
--
-- Maximum frequency 74HC165  : xx MHz
--                   74HCT165 : xx MHz 
--
--
-- ## Pins
--
-- !CE (Pin 15) should be tied to low.
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

package shiftin_pkg is

   type shiftin_out_type is record
      sck    : std_logic;                 -- or CP (Pin 2)
      load_n : std_logic;                 -- or !PL (Pin 1)
   end record;

   type shiftout_in_type is record
      din : std_logic;                  -- or Q7 (Pin 9)
   end record shiftout_in_type;

   component shiftin is
      port (
         register_out_p : out shiftin_out_type;
         register_in_p  : in  shiftout_in_type;
         re_p           : in  std_logic;
         busy_p         : out std_logic;
         value_p        : out std_logic_vector(7 downto 0);
         clk            : in  std_logic);
   end component shiftin;

end package shiftin_pkg;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.shiftin_pkg.all;

entity shiftin is

   port (
      register_out_p : out shiftin_out_type;
      register_in_p  : in  shiftout_in_type;

      re_p   : in  std_logic;           -- Start transaction
      busy_p : out std_logic;           -- Transaction in progress

      value_p : out std_logic_vector(7 downto 0);

      clk : in std_logic);

end entity shiftin;

architecture behavioral of shiftin is
   signal clk_enable : std_logic := '1';  -- clock enable for the SCK speed
   
   type shiftin_state_type is (
      STATE_IDLE, STATE_LOAD, STATE_LOAD_WAIT, STATE_WRITE, STATE_WRITE_NEXT);

   type shiftin_type is record
      state : shiftin_state_type;

      value_buffer : std_logic_vector(7 downto 0);
      value        : std_logic_vector(7 downto 0);
      bitcount     : integer range 0 to 9;  -- Number of bits loaded

      o : shiftin_out_type;
   end record shiftin_type;

   signal r, rin : shiftin_type := (
      state        => STATE_IDLE,
      value_buffer => (others => '0'),
      value        => (others => '0'),
      bitcount     => 0,
      o            => (
         sck       => '0',
         load_n    => '1'));
begin

   seq_proc : process (clk) is
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process (clk_enable, r, r.bitcount, r.o, r.state, r.value,
                        r.value_buffer(6 downto 0), r.value_buffer(7), value_p) is
      variable v : shiftin_type;
   begin
      v := r;

      case r.state is
         when STATE_IDLE =>
            if re_p = '1' then
               v.state := STATE_LOAD;
            end if;

         when STATE_LOAD =>
            if clk_enable = '1' then
               v.o.load_n := '0';
               v.state  := STATE_LOAD_WAIT;
            end if;

         when STATE_LOAD_WAIT =>
            if clk_enable = '1' then
               v.o.load_n := '1';
               v.state  := STATE_WRITE_NEXT;
            end if;

         when STATE_WRITE =>
            if clk_enable = '1' then
               v.o.sck := '1';
               v.state := STATE_WRITE_NEXT;
            end if;

         when STATE_WRITE_NEXT =>
            if clk_enable = '1' then
               v.o.sck := '0';
               
               v.state := STATE_WRITE;
            end if;

            ---- Clock low and switch to the next bit
            --when STATE_WRITE_NEXT =>
            --   if clk_enable = '1' then
            --      v.o.sck := '0';

            --      -- MSB first
            --      v.o.dout       := r.value_buffer(7);
            --      v.value_buffer := r.value_buffer(6 downto 0) & '0';

            --      v.bitcount := r.bitcount + 1;
            --      if r.bitcount = 8 then
            --         v.state := STATE_LOAD;
            --      else
            --         v.state := STATE_WRITE;
            --      end if;
            --   end if;
      end case;

      -- register outputs
      register_out_p <= r.o;

      rin <= v;
   end process comb_proc;

-- TODO clk_enable generation
-- to adapt to higher clk frequencies
end architecture behavioral;
