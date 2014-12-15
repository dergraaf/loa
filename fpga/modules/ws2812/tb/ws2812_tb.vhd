-------------------------------------------------------------------------------
-- Title      : Testbench for design "ws2812"
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-13
-------------------------------------------------------------------------------
-- Copyright (c) 2014, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ws2812_pkg.all;
use work.ws2812_cfg_pkg.all;

-------------------------------------------------------------------------------

entity ws2812_tb is

end ws2812_tb;

-------------------------------------------------------------------------------

architecture tb of ws2812_tb is

  -- component ports
  signal ws2812_in        : ws2812_in_type;
  signal ws2812_out       : ws2812_out_type;
  signal ws2812_chain_out : ws2812_chain_out_type;


  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : ws2812
    port map (
      ws2812_in        => ws2812_in,
      ws2812_out       => ws2812_out,
      ws2812_chain_out => ws2812_chain_out,
      clk              => clk);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    ws2812_in.send_reset <= '0';
    ws2812_in.we         <= '0';
    ws2812_in.d          <= x"000000";

    wait until Clk = '1';
    ws2812_in.d  <= x"aa0f55";
    ws2812_in.we <= '1';
    wait until Clk = '1';
    ws2812_in.we <= '0';


    wait for 40 us;
    ws2812_in.send_reset <= '1';
    wait until Clk = '1';
    ws2812_in.send_reset <= '0';
    wait for 80 us;
  end process WaveGen_Proc;

  

end tb;

-------------------------------------------------------------------------------

configuration ws2812_tb_tb_cfg of ws2812_tb is
  for tb
  end for;
end ws2812_tb_tb_cfg;

-------------------------------------------------------------------------------
