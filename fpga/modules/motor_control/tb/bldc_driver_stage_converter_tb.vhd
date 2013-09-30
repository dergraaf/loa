-------------------------------------------------------------------------------
-- Title      : Testbench for design "bldc_driver_stage_converter"
-- Project    : 
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.motor_control_pkg.all;

-------------------------------------------------------------------------------

entity bldc_driver_stage_converter_tb is

end entity bldc_driver_stage_converter_tb;

-------------------------------------------------------------------------------

architecture tb of bldc_driver_stage_converter_tb is

   -- component ports
   signal bldc_driver_stage : bldc_driver_stage_type := (a => (high => '0', low => '0'),
                                                         b => (high => '0', low => '0'),
                                                         c => (high => '0', low => '0')
                                                         );
   signal bldc_driver_stage_st : bldc_driver_stage_st_type;

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : entity work.bldc_driver_stage_converter
      port map (
         bldc_driver_stage    => bldc_driver_stage,
         bldc_driver_stage_st => bldc_driver_stage_st);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- All off
      -- default
      wait until clk = '1';

      -- P1 H
      bldc_driver_stage.a.high <= '1';
      wait until clk = '1';

      -- P1 L
      bldc_driver_stage.a.high <= '0';
      bldc_driver_stage.a.low  <= '1';
      wait until clk = '1';

      -- P1 H L shoot through
      bldc_driver_stage.a.high <= '1';
      bldc_driver_stage.a.low  <= '1';
      wait until clk = '1';

      -- P2 H
      bldc_driver_stage.a.low  <= '0';
      bldc_driver_stage.a.high <= '0';

      bldc_driver_stage.b.high <= '1';
      wait until clk = '1';

      -- P2 L
      bldc_driver_stage.b.high <= '0';
      bldc_driver_stage.b.low  <= '1';
      wait until clk = '1';

      -- P3H
      bldc_driver_stage.c.high <= '1';
      wait until clk = '1';

      -- P3L
      bldc_driver_stage.c.high <= '0';
      bldc_driver_stage.c.low <= '1';

      wait;
   end process WaveGen_Proc;



end architecture tb;

-------------------------------------------------------------------------------

configuration bldc_driver_stage_converter_tb_tb_cfg of bldc_driver_stage_converter_tb is
   for tb
   end for;
end bldc_driver_stage_converter_tb_tb_cfg;

-------------------------------------------------------------------------------
