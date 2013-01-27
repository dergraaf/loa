-------------------------------------------------------------------------------
-- Title      : Testbench for design "shiftout"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Platform   : Spartan 3 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.shiftout_pkg.all;

-------------------------------------------------------------------------------
entity shiftout_tb is
end shiftout_tb;

-------------------------------------------------------------------------------
architecture tb of shiftout_tb is

   -- component ports
   signal register_signal : shiftout_out_type;
   signal value : std_logic_vector(7 downto 0) := (others => '0');

   signal clk : std_logic := '0';
   signal reset : std_logic := '1';

begin
   -- component instantiation
   shiftout_1: shiftout
      port map (
         register_p => register_signal,
         value_p    => value,
         clk        => clk);
   
   -- clock generation
   clk <= not clk after 10 NS;
   reset <= '1', '0' after 30 NS;

   waveform : process
   begin
      wait until falling_edge(reset);

      wait for 50 NS;
      value <= x"23";
      wait for 1 US;
      value <= x"ff";
      wait for 1 US;
      value <= x"1f";
      wait for 20 NS;
      value <= x"f1";
   end process waveform;
end tb;
