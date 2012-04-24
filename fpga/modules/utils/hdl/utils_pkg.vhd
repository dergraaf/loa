
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package utils_pkg is

   -- Calculates the number of bits required to encode the given number
   --
   -- Note that this function is not intended to synthesize directly into
   -- hardware, rather it is used to generate constants for synthesized
   -- hardware.
   --
   -- Example:
   -- entity foo is
   --    generic(
   --       ABC : positive);
   --    port(
   --       xzy : out std_logic_vector(required_bits(ABC) downto 0));
   -- end foo;
   function required_bits (value : natural) return natural;

   -- Another function which does the same, up to 32 bits
   function log2 (val : integer) return natural;

   ----------------------------------------------------------------------------
   function max(L : integer;
                R : integer)
      return integer;

   function minn(L : integer;
                R : integer)
      return integer;

   ----------------------------------------------------------------------------
   -- replacement for std_logic_arith
   -- works with unsigneds
   -- see http://www.lothar-miller.de/s9y/archives/14-Numeric_Std.html
   
   function conv_integer(
      vec : std_logic_vector)
      return integer;

   function conv_std_logic_vector (
      int : natural;
      len : natural)
      return std_logic_vector;

   ----------------------------------------------------------------------------
   component clock_divider is
      generic (
         DIV : positive);
      port (
         clk_out_p : out std_logic;
         clk       : in  std_logic);
   end component;

   -- Requires MUL <= DIV
   component fractional_clock_divider is
      generic (
         DIV : positive;
         MUL : positive);
      port (
         clk_out_p : out std_logic;
         clk       : in  std_logic);
   end component fractional_clock_divider;

   -- Requires mul <= div
   component fractional_clock_divider_variable is
      generic (
         WIDTH : positive);
      port (
         div       : in  std_logic_vector(WIDTH-1 downto 0);
         mul       : in  std_logic_vector(WIDTH-1 downto 0);
         clk_out_p : out std_logic;
         clk       : in  std_logic);
   end component fractional_clock_divider_variable;

   ----------------------------------------------------------------------------
   component event_hold_stage is
      port (
         dout_p   : out std_logic;
         din_p    : in  std_logic;
         period_p : in  std_logic;

         clk : in std_logic);
   end component event_hold_stage;

   component edge_detect is
      port (
         async_sig : in  std_logic;
         clk       : in  std_logic;
         rise      : out std_logic;
         fall      : out std_logic);
   end component edge_detect;

   ----------------------------------------------------------------------------
   component dff is
      port (
         dout_p  : out std_logic;
         din_p   : in  std_logic;
         set_p   : in  std_logic;
         reset_p : in  std_logic;
         ce_p    : in  std_logic;
         clk     : in  std_logic);
   end component dff;
   
end package utils_pkg;

package body utils_pkg is

   function required_bits (value : natural) return natural is
   begin
      if value <= 0 then
         return 0;
      elsif value = 1 then
         return 1;
      elsif value < 8 then
         return integer(ceil(log2(real(value))));
      else
         -- FIXME: Why is this hack necessary?
         -- Otherwise the values for 2**x (x >= 3) are calculated wrong.
         -- E.g.:
         -- required_bits(8) = 3 != 4
         -- required_bits(16) = 4 != 5
         -- see ../tb/utils_tb.vhd
         return integer(ceil(log2(real(value) + 0.5)));
      end if;
   end function;

   function log2 (val : integer) return natural is
      variable res : positive;
   begin  -- log2
      for i in 1 to 31 loop
         if (val <= (2**i)) then

            res := i;
            exit;
         end if;
      end loop;  -- i
      return res;
   end log2;

   ----------------------------------------------------------------------------

   function max(L : integer;
                R : integer)
      return integer is
   begin  -- max
      if L > R then
         return L;
      else
         return R;
      end if;
   end max;

   function minn(L : integer;
                R : integer)
      return integer is
   begin  -- min
      if L < R then
         return L;
      else
         return R;
      end if;
   end minn;

   ----------------------------------------------------------------------------

   function conv_integer(
      vec : std_logic_vector)
      return integer is
   begin
      return to_integer(unsigned(vec));
   end conv_integer;

   function conv_std_logic_vector (
      int : natural;
      len : natural)
      return std_logic_vector is
   begin  -- conv_std_logic_vector
      return std_logic_vector(to_unsigned(int, len));
   end conv_std_logic_vector;


end package body utils_pkg;
