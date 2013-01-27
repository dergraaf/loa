-------------------------------------------------------------------------------
-- Title      : Testbench for integer-to-real conversion
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Learning VHDL io.  
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity io_test is

end entity io_test;

architecture tb of io_test is
   signal clk : std_logic := '0';

   signal s0 : std_logic_vector(15 downto 0) := (others => '0');
   signal s1 : signed(15 downto 0)           := (others => '0');
   signal s2 : integer                       := 0;
   signal s3 : real                          := 0.0;

   type IntegerFileType is file of integer;
   
begin  -- architecture tb
   -- clock gen
   clk <= not clk after 1 ms;

   process (clk) is
      variable cnt     : integer := 0;
      file data_out    : IntegerFileType open write_mode is "my_file.bin";
      variable fstatus : file_open_status;
   begin  -- process
      if rising_edge(clk) then          -- rising clock edge
         s0  <= std_logic_vector(to_unsigned(cnt, 16));
         write(data_out, s2);
         cnt := cnt + 1;
      end if;
   end process;

   s1 <= signed(s0);
   s2 <= to_integer(s1);
   s3 <= real(s2);


end architecture tb;
