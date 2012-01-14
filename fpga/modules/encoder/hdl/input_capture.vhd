-------------------------------------------------------------------------------
-- Title      : Input Capture Counter
-- Project    : Loa
-------------------------------------------------------------------------------
-- File       : input_capture.vhd
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2012-01-13
-- Last update: 2012-01-13
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description:
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package input_capture_pkg is

   component input_capture is
      port (
         value_p  : out std_logic_vector(15 downto 0);
         step_p   : in  std_logic;
         dir_p    : in  std_logic;
         clk_en_p : in  std_logic;
         reset    : in  std_logic;
         clk      : in  std_logic);
   end component input_capture;

end package input_capture_pkg;

-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity input_capture is
   
   port (
      value_p : out std_logic_vector(15 downto 0);

      step_p : in std_logic;            -- Encoder Step
      dir_p  : in std_logic;            -- Encoder Direction

      clk_en_p : in std_logic;          -- Clock enable
      reset    : in std_logic;
      clk      : in std_logic
      );

end entity input_capture;

architecture behavioral of input_capture is
   type input_capture_type is record
      dir     : std_logic;
      value   : std_logic_vector(15 downto 0);
      invalid : std_logic;
      cnt     : unsigned(15 downto 0);  -- Counter value
   end record;

   signal r, rin : input_capture_type := (
      dir     => '0',
      value   => (others => '1'),
      invalid => '1',
      cnt     => (others => '0')
      );
begin

   seq_proc : process(reset, clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then
            r.cnt     <= (others => '0');
            r.value   <= (others => '1');
            r.invalid <= '1';
         else
            r <= rin;
         end if;
      end if;
   end process seq_proc;

   comb_proc : process(clk_en_p, dir_p, r, r.cnt, step_p)
      variable v : input_capture_type;
   begin
      v := r;

      if clk_en_p = '1' then
         v.cnt := r.cnt + 1;
      end if;

      -- Check for overflows
      if r.cnt = (r.cnt'range => '1') then
         v.value   := std_logic_vector(r.cnt);
         v.invalid := '1';
      end if;

      -- Next value will bigger, preadjust the output value
      if std_logic_vector(r.cnt) >= r.value then
         v.value := std_logic_vector(r.cnt);
      end if;

      if step_p = '1' then
         if v.dir = dir_p and r.invalid = '0' then
            -- Step is in the same direction as the one before
            -- => correct measurement
            v.value := std_logic_vector(r.cnt);
         else
            -- Step in the other direction => invalid value
            v.value := (others => '1');
         end if;

         v.dir     := dir_p;
         v.cnt     := (others => '0');
         v.invalid := '0';
      end if;

      rin <= v;
   end process comb_proc;

   value_p <= r.value;

end architecture behavioral;
