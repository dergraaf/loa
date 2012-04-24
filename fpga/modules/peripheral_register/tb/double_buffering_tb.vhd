-------------------------------------------------------------------------------
-- Title      : Testbench for design "double_buffering"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : double_buffering_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-23
-- Last update: 2012-04-23
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------

entity double_buffering_tb is

end entity double_buffering_tb;

-------------------------------------------------------------------------------

architecture tb of double_buffering_tb is

   -- component ports
   signal ready_p  : std_logic := '0';
   signal enable_p : std_logic := '0';
   signal irq_p    : std_logic := '0';
   signal ack_p    : std_logic := '0';
   signal bank_p   : std_logic := '0';

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : double_buffering
      port map (
         ready_p  => ready_p,
         enable_p => enable_p,
         irq_p    => irq_p,
         ack_p    => ack_p,
         bank_p   => bank_p,
         clk      => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      wait until clk = '0';

      -------------------------------------------------------------------------
      -- Scenario 1: normal operation, STM acknowledges in time
      -------------------------------------------------------------------------
      -- app has finished:
      ready_p <= '1';
      wait until clk = '0';
      ready_p <= '0';

      -- wait until STM reacts
      for ii in 0 to 5 loop
         wait until clk = '0';
      end loop;  -- ii

      -- STM acknowledges, asynchronously
      wait for 3.39 ns;
      ack_p <= '1';
      wait for 38.3 ns;
      ack_p <= '0';



      -- separate test cases
      for ii in 0 to 5 loop
         wait until clk = '0';
      end loop;  -- ii

      -------------------------------------------------------------------------
      -- Scenario 2: ACK is still high when ready goes high again
      -------------------------------------------------------------------------
      -- Expected behaviour: keep IRQ high. Only rising edges of ready_p reset
      -- the IRQ signal.

      ack_p <= '1';
      for ii in 0 to 5 loop
         wait until clk = '0';
      end loop;  -- ii

      -- app has finished:
      ready_p <= '1';
      wait until clk = '0';
      ready_p <= '0';


      -- wait until STM reacts
      for ii in 0 to 5 loop
         wait until clk = '0';
      end loop;  -- ii

      ack_p <= '0';
      wait until clk = '0';
      ack_p <= '1';

      for ii in 0 to 5 loop
         wait until clk = '0';
      end loop;  -- ii

      ack_p <= '0';



      -- separate test cases
      for ii in 0 to 5 loop
         wait until clk = '0';
      end loop;  -- ii

      -------------------------------------------------------------------------
      -- Scenario 3: STM does not read data fast enough
      -------------------------------------------------------------------------
      -- Expected behaviour: IRQ is kept high, no bank change. 
      
      -- app has finished:
      ready_p <= '1';
      wait until clk = '0';
      ready_p <= '0';

      -- new data comes in 10 clock cycles
      for ii in 0 to 10 loop
         wait until clk = '0';
      end loop;  -- ii

      ready_p <= '1';
      wait until clk = '0';
      ready_p <= '0';

 

      -- do not repeat
      wait for 10 ms;
      
   end process WaveGen_Proc;

   

end architecture tb;

-------------------------------------------------------------------------------

configuration double_buffering_tb_tb_cfg of double_buffering_tb is
   for tb
   end for;
end double_buffering_tb_tb_cfg;

-------------------------------------------------------------------------------
