-------------------------------------------------------------------------------
-- Title      : Testbench for integer-to-real conversion
-- Project    : 
-------------------------------------------------------------------------------
-- File       : real_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-05-03
-- Last update: 2012-05-03
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity real_tb is

end entity real_tb;

architecture tb of real_tb is
   signal clk : std_logic := '0';
   
   signal s0 : std_logic_vector(15 downto 0) := (others => '0');
   signal s1 : signed(15 downto 0)           := (others => '0');
   signal s2 : integer := 0;
   signal s3 : real := 0.0;
   
begin  -- architecture tb
   -- clock gen
   clk <= not clk after 10 ns;

   process (clk) is
      variable cnt : integer := 0;
   begin  -- process
      if rising_edge(clk) then          -- rising clock edge
         s0 <= std_logic_vector(to_unsigned(cnt, 16));
         cnt := cnt + 1;
      end if;
   end process;

   s1 <= signed(s0);
   s2 <= to_integer(s1);
   s3 <= real(s2);


end architecture tb;
