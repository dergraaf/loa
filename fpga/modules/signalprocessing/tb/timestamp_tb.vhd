-------------------------------------------------------------------------------
-- Title      : Testbench for design "timestamp"
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Created    : 2011-12-16
-- Last update: 2012-08-03
-- Platform   : Spartan 3 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------
entity timestamp_tb is
end timestamp_tb;

-------------------------------------------------------------------------------
architecture tb of timestamp_tb is

   -- component generics
   constant WIDTH : positive := 8;

   -- component ports
   signal timestamp : unsigned(WIDTH-1 downto 0) := (others => '0');

   signal clk   : std_logic := '0';

begin
   -- component instantiation
   timestamp_1: entity work.timestamp
      generic map (
         WIDTH => WIDTH)
      port map (
         timestamp => timestamp,
         clk       => clk);
   
   -- clock generation
   clk <= not clk after 20 ns;

   waveform : process
   begin
      wait for 20 ns;

      -- do not repeat
      wait;
      
   end process waveform;
end tb;
