-------------------------------------------------------------------------------
-- Title      : Hall Sensor Decoder
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Company    : Roboterclub Aachen e. V.
-------------------------------------------------------------------------------
-- Description: 
-- 
--           _____       _______       _____
-- A     ___|     |_____|       |_____|     
--             _____       ___       _______
-- B     _____|     |_____|   |_____|       
--               _____             _______    
-- C     _______|     |___________|       |_
--                                          
-- step_p   1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1
-- dir_p    1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 
--

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.motor_control_pkg.all;

package hall_sensor_decoder_pkg is
   
   component hall_sensor_decoder
      port (
         hall_sensor_p : in hall_sensor_type;

         step_p  : out std_logic;
         dir_p   : out std_logic;
         error_p : out std_logic;

         clk : in std_logic);
   end component;
   
end hall_sensor_decoder_pkg;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
 use work.motor_control_pkg.all;

entity hall_sensor_decoder is
   port (
      hall_sensor_p : in hall_sensor_type;

      step_p  : out std_logic;  -- detected step_p ('1' for one clock cycle)
      dir_p   : out std_logic;  -- count direction (1 = up, 0 = down)
      error_p : out std_logic;  -- illegal transition (two or more bits change at the same time)

      clk : in std_logic                -- system clock                
      );
end hall_sensor_decoder;

architecture behavioral of hall_sensor_decoder is
   signal a_buf : std_logic_vector(1 downto 0) := (others => '0');
   signal b_buf : std_logic_vector(1 downto 0) := (others => '0');
   signal c_buf : std_logic_vector(1 downto 0) := (others => '0');
begin
   -- edge detection
   process
   begin
      wait until rising_edge(clk);

      a_buf <= a_buf(0) & hall_sensor_p.a;
      b_buf <= b_buf(0) & hall_sensor_p.b;
      c_buf <= c_buf(0) & hall_sensor_p.c;
   end process;

   -- signal decoding
   comb : process(a_buf, b_buf, c_buf)
      variable state : std_logic_vector(5 downto 0);
   begin
      state := a_buf(0) & b_buf(0) & c_buf(0) & a_buf(1) & b_buf(1) & c_buf(1);
      case state is
         -- new -> old
         -- unchanged valid codes
         when "101" & "101" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "100" & "100" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "110" & "110" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "010" & "010" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "011" & "011" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "001" & "001" => step_p <= '0'; dir_p <= '0'; error_p <= '0';

         -- CW
         when "101" & "100" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "100" & "110" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "110" & "010" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "010" & "011" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "011" & "001" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
         when "001" & "101" => step_p <= '1'; dir_p <= '0'; error_p <= '0';


         -- CCW
         when "101" & "001" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "001" & "011" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "011" & "010" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "010" & "110" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "110" & "100" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
         when "100" & "101" => step_p <= '1'; dir_p <= '1'; error_p <= '0';

         -- From invalid to any valid
         when "101" & "000" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "101" & "111" => step_p <= '0'; dir_p <= '0'; error_p <= '0';

         when "100" & "000" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "100" & "111" => step_p <= '0'; dir_p <= '0'; error_p <= '0';

         when "110" & "000" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "110" & "111" => step_p <= '0'; dir_p <= '0'; error_p <= '0';

         when "010" & "000" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "010" & "111" => step_p <= '0'; dir_p <= '0'; error_p <= '0';

         when "011" & "000" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "011" & "111" => step_p <= '0'; dir_p <= '0'; error_p <= '0';

         when "001" & "000" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
         when "001" & "111" => step_p <= '0'; dir_p <= '0'; error_p <= '0';

         -- All other invalid
         when others => step_p <= '0'; dir_p <= '0'; error_p <= '1';
      end case;
   end process;
end behavioral;
