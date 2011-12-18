-- ----------------------------------------------------------------------------
-- Quadrature Decoder
-- 
-- @code
--           ___     ___         ___     ___
-- A     ___|   |___|   |_______|   |___|
--             ___     ___     ___     ___
-- B     _____|   |___|   |___|   |___|   |_
-- 
-- step_p   1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1
-- dir_p    1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 
-- @endcode
--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.encoder_module_pkg.all;

package quadrature_decoder_pkg is
   component quadrature_decoder
      port (
         encoder_p : in encoder_type;

         step_p  : out std_logic;
         dir_p   : out std_logic;
         error_p : out std_logic;

         clk : in std_logic);
   end component;
end quadrature_decoder_pkg;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.encoder_module_pkg.all;

entity quadrature_decoder is
   port (
      encoder_p : in encoder_type;

      step_p  : out std_logic;  -- detected step_p ('1' for one clock cycle)
      dir_p   : out std_logic;          -- count direction (1 = up, 0 = down)
      error_p : out std_logic;  -- illegal transition (two bits change at the same time)

      clk : in std_logic                -- system clock                
      );
end quadrature_decoder;

architecture behavioral of quadrature_decoder is
   signal a_buf : std_logic_vector(1 downto 0) := "00";
   signal b_buf : std_logic_vector(1 downto 0) := "00";
begin
   -- edge detection
   process
   begin
      wait until rising_edge(clk);

      a_buf <= a_buf(0) & encoder_p.a;
      b_buf <= b_buf(0) & encoder_p.b;
   end process;

   -- signal decoding
   comb : process(a_buf, b_buf)
      variable state : std_logic_vector(3 downto 0);
   begin
      state := a_buf(0) & b_buf(0) & a_buf(1) & b_buf(1);
      case state is
         -- step_p = a_buf(0) xor a_buf(1) xor b_buf(0) xor b_buf(1)
         -- dir_p  = not (a_buf(0) xor b_buf(1))

         -- new -> old
         when "0000" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "0001" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "0010" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "0011" => step_p <= '0'; dir_p <= '1'; error_p <= '1';
         when "0100" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "0101" => step_p <= '0'; dir_p <= '1'; error_p <= '0';
         when "0110" => step_p <= '0'; dir_p <= '0'; error_p <= '1';
         when "0111" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "1000" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "1001" => step_p <= '0'; dir_p <= '0'; error_p <= '1';
         when "1010" => step_p <= '0'; dir_p <= '1'; error_p <= '0';
         when "1011" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "1100" => step_p <= '0'; dir_p <= '1'; error_p <= '1';
         when "1101" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "1110" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "1111" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when others => step_p <= '0'; dir_p <= '1'; error_p <= '1';
      end case;
   end process;
end behavioral;
