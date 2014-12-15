-------------------------------------------------------------------------------
-- Title      : Testbench for Controller 8x1
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

entity ws2812_8x1_tb is

end ws2812_8x1_tb;

-------------------------------------------------------------------------------

architecture tb of ws2812_8x1_tb is

  -- component ports
  signal pixels     : ws2812_8x1_in_type;
  signal ws2812_in  : ws2812_in_type;
  signal ws2812_out : ws2812_out_type;

  signal ws2812_chain_out : ws2812_chain_out_type;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : ws2812_8x1
    port map (
      pixels     => pixels,
      ws2812_in  => ws2812_in,
      ws2812_out => ws2812_out,
      clk        => clk);

  ws2812_1 : ws2812
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

    pixels <= (pixel   =>
               (0      => x"111111",
                1      => x"110000",
                2      => x"111111",
                3      => x"001100",
                4      => x"111111",
                5      => x"000011",
                6      => x"111111",
                7      => x"050505"),
               refresh => '0');

    wait until Clk = '1';
    pixels.refresh <= '1';
    wait until Clk = '1';
    pixels.refresh <= '0';

    wait for 10 ms;
  end process WaveGen_Proc;

end tb;

-------------------------------------------------------------------------------

configuration ws2812_8x1_tb_tb_cfg of ws2812_8x1_tb is
  for tb
  end for;
end ws2812_8x1_tb_tb_cfg;

-------------------------------------------------------------------------------
