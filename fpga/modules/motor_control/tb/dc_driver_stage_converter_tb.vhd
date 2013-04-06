-------------------------------------------------------------------------------
-- Title      : Testbench for design "dc_driver_stage_converter"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : dc_driver_stage_converter_tb.vhd
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.motor_control_pkg.all;

-------------------------------------------------------------------------------

entity dc_driver_stage_converter_tb is

end entity dc_driver_stage_converter_tb;

-------------------------------------------------------------------------------

architecture tb of dc_driver_stage_converter_tb is

   -- component ports
   signal pwm1_in_p                : std_logic := '0';
   signal pwm2_in_p                : std_logic := '0';
   signal sd_in_p                  : std_logic := '1';
   signal dc_driver_stage_st_out_p : dc_driver_stage_st_type;

   -- clock
   signal Clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : entity work.dc_driver_stage_converter
      port map (
         pwm1_in_p                => pwm1_in_p,
         pwm2_in_p                => pwm2_in_p,
         sd_in_p                  => sd_in_p,
         dc_driver_stage_st_out_p => dc_driver_stage_st_out_p);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';

      -- Deactivate
      pwm1_in_p <= '0';
      pwm2_in_p <= '0';
      sd_in_p   <= '1';

      -- Both low
      wait until clk = '1';
      pwm1_in_p <= '0';
      pwm2_in_p <= '0';
      sd_in_p   <= '0';

      -- Both high
      wait until clk = '1';
      pwm1_in_p <= '1';
      pwm2_in_p <= '1';
      sd_in_p   <= '0';

      -- High, low
      wait until clk = '1';
      pwm1_in_p <= '1';
      pwm2_in_p <= '0';
      sd_in_p   <= '0';

      -- Low, High
      wait until clk = '1';
      pwm1_in_p <= '0';
      pwm2_in_p <= '1';
      sd_in_p   <= '0';

   end process WaveGen_Proc;



end architecture tb;

-------------------------------------------------------------------------------

configuration dc_driver_stage_converter_tb_tb_cfg of dc_driver_stage_converter_tb is
   for tb
   end for;
end dc_driver_stage_converter_tb_tb_cfg;

-------------------------------------------------------------------------------
