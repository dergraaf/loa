
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.utils_pkg.all;
use work.text_pkg.all;

entity utils_tb is
end utils_tb;

architecture behavior of utils_tb is
   --type input_type is record
   --  value : integer;
   --end record;

   --type expect_type is record
   --  value : integer;
   --end record;

   subtype input_type is integer;
   subtype expect_type is integer;

   type stimulus_type is record
      input  : input_type;
      expect : expect_type;
   end record;

   type stimuli_type is array (natural range <>) of stimulus_type;

   constant stimuli : stimuli_type := (
      (input => 0, expect => 0),
      (input => 1, expect => 1),
      (input => 2, expect => 1),
      (input => 3, expect => 2),
      (input => 4, expect => 2),
      (input => 5, expect => 3),
      (input => 7, expect => 3),
      (input => 8, expect => 4),
      (input => 9, expect => 4),
      (input => 15, expect => 4),
      (input => 16, expect => 5),
      (input => 17, expect => 5),
      (input => 31, expect => 5),
      (input => 32, expect => 6),
      (input => 33, expect => 6),
      (input => 48, expect => 6),
      (input => 63, expect => 6),
      (input => 64, expect => 7),
      (input => 127, expect => 7),
      (input => 128, expect => 8)
      );

   signal clk : std_logic := '0';
   signal reset : std_logic := '1';
begin
   clk <= not clk after 10 ns;          -- 50 Mhz clock
   reset <= '1', '0' after 40 ns;

   wave : process
   begin  -- process wave
      wait until falling_edge(reset);
      
      for i in stimuli'LEFT to stimuli'RIGHT loop
         assert required_bits(stimuli(i).input) = stimuli(i).expect
            report "required_bits(" & str(stimuli(i).input) & ") = " &
            str(required_bits(stimuli(i).input)) & " != " &
            str(stimuli(i).expect);
      end loop;
   end process wave;
   
end;
