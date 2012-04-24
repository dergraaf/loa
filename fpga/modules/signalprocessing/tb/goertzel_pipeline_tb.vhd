-------------------------------------------------------------------------------
-- Title      : Testbench for design "goertzel_pipeline"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipeline_tb.vhd
-- Author     : user  <user@alphamac.ac.local>
-- Company    : 
-- Created    : 2012-04-24
-- Last update: 2012-04-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-04-24  1.0      user    Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity goertzel_pipeline_tb is

end entity goertzel_pipeline_tb;

-------------------------------------------------------------------------------

architecture tb of goertzel_pipeline_tb is

   -- component generics
   constant Q : natural := 13;

   -- component ports
   signal coef_p   : goertzel_coef_type   := (others => '0');
   signal input_p  : goertzel_input_type  := (others => '0');
   signal delay_p  : goertzel_result_type := (others => (others => '0'));
   signal result_p : goertzel_result_type := (others => (others => '0'));

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : entity work.goertzel_pipeline
      generic map (
         Q => Q)
      port map (
         coef_p   => coef_p,
         input_p  => input_p,
         delay_p  => delay_p,
         result_p => result_p,
         clk      => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      wait until clk = '0';
      wait until clk = '0';

      -- resize is not exactly what's intende because it takes care of the sign
      -- bit (MSB) when truncating. But for simple test purposes this does not
      -- matter as the actual data is unimportant. 
      coef_p  <= resize(x"323fe", coef_p'length);
      delay_p <= resize(x"1ffff", 18) & resize(x"14238", 18);
      input_p <= resize(x"193af", input_p'length);

      
      
   end process WaveGen_Proc;

   

end architecture tb;
