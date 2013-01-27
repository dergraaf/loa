-------------------------------------------------------------------------------
-- Title      : Testbench for design "input_capture"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : Roboterclub Aachen e.V.
-------------------------------------------------------------------------------
-- Description: 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.input_capture_pkg.all;

-------------------------------------------------------------------------------
entity input_capture_tb is
end input_capture_tb;

-------------------------------------------------------------------------------
architecture tb of input_capture_tb is

   -- component ports
   signal value  : std_logic_vector(15 downto 0);
   signal step   : std_logic := '0';
   signal dir    : std_logic := '0';
   signal clk_en : std_logic := '1';

   signal reset : std_logic := '1';
   signal clk   : std_logic := '0';

begin
   -- component instantiation
   input_capture_1 : input_capture
      port map (
         value_p  => value,
         step_p   => step,
         dir_p    => dir,
         clk_en_p => clk_en,
         reset    => reset,
         clk      => clk);

   -- clock generation
   clk <= not clk after 10 NS;

   -- reset generation
   reset <= '1', '0' after 50 NS;

   waveform : process
   begin
      wait until falling_edge(reset);
      wait for 400 NS;

      wait until rising_edge(clk);
      step <= '1';
      dir <= '0';
      wait until rising_edge(clk);
      step <= '0';

      wait for 400 US;

      wait until rising_edge(clk);
      step <= '1';
      dir <= '0';
      wait until rising_edge(clk);
      step <= '0';

      wait for 200 US;

      wait until rising_edge(clk);
      step <= '1';
      dir <= '0';
      wait until rising_edge(clk);
      step <= '0';
      
      wait for 50 US;

      wait until rising_edge(clk);
      step <= '1';
      dir <= '1';
      wait until rising_edge(clk);
      step <= '0';

      wait for 50 US;
      
      wait until rising_edge(clk);
      step <= '1';
      dir <= '1';
      wait until rising_edge(clk);
      step <= '0';

      wait for 50 US;
      
      wait until rising_edge(clk);
      step <= '1';
      dir <= '0';
      wait until rising_edge(clk);
      step <= '0';

      wait for 1 US;
      
      wait until rising_edge(clk);
      step <= '1';
      dir <= '0';
      wait until rising_edge(clk);
      step <= '0';

      wait for 2 MS;

      wait until rising_edge(clk);
      step <= '1';
      dir <= '0';
      wait until rising_edge(clk);
      step <= '0';

      wait for 20 US;

      wait until rising_edge(clk);
      step <= '1';
      dir <= '0';
      wait until rising_edge(clk);
      step <= '0';
      
   end process waveform;
end tb;
