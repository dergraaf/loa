-------------------------------------------------------------------------------
-- Title      : Testbench for design "dc_driver_stage_converter"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dc_driver_stage_converter_tb.vhd<2>
-- Author     : Sascha  <sascha@95-087.eduroam.rwth-aachen.de>
-- Company    : 
-- Created    : 2013-03-27
-- Last update: 2013-03-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-03-27  1.0      sascha	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity dc_driver_stage_converter_tb is

end entity dc_driver_stage_converter_tb;

-------------------------------------------------------------------------------

architecture tb of dc_driver_stage_converter_tb is

   -- component ports
   signal pwm1_in_p                : std_logic;
   signal pwm2_in_p                : std_logic;
   signal sd_in_p                  : std_logic;
   signal dc_driver_stage_st_out_p : dc_driver_stage_st_type;

   -- clock
   signal Clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT: entity work.dc_driver_stage_converter
      port map (
         pwm1_in_p                => pwm1_in_p,
         pwm2_in_p                => pwm2_in_p,
         sd_in_p                  => sd_in_p,
         dc_driver_stage_st_out_p => dc_driver_stage_st_out_p);

   -- clock generation
   Clk <= not Clk after 10 ns;

   -- waveform generation
   WaveGen_Proc: process
   begin
      -- insert signal assignments here
      
      wait until Clk = '1';
   end process WaveGen_Proc;

   

end architecture tb;

-------------------------------------------------------------------------------

configuration dc_driver_stage_converter_tb_tb_cfg of dc_driver_stage_converter_tb is
   for tb
   end for;
end dc_driver_stage_converter_tb_tb_cfg;

-------------------------------------------------------------------------------
