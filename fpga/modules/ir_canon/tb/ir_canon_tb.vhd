-------------------------------------------------------------------------------
-- Title      : Testbench for design "ir_canon"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_canon_tb.vhd
-- Author     : user  <calle@alukiste>
-- Company    : 
-- Created    : 2014-12-16
-- Last update: 2014-12-16
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2014 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2014-12-16  1.0      calle   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.ir_canon_pkg.all;

-------------------------------------------------------------------------------
entity ir_canon_tb is
end ir_canon_tb;
-------------------------------------------------------------------------------

architecture tb of ir_canon_tb is

  component ir_canon
    port (
      ir_canon_in  : in  ir_canon_in_type;
      ir_canon_out : out ir_canon_out_type;
      clk          : in  std_logic);
  end component;

  -- component ports
  signal ir_canon_in  : ir_canon_in_type;
  signal ir_canon_out : ir_canon_out_type;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : ir_canon
    port map (
      ir_canon_in  => ir_canon_in,
      ir_canon_out => ir_canon_out,
      clk          => clk);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    -- insert signal assignments here
    ir_canon_in.trigger <= '0';
    wait until Clk = '1';
    wait until Clk = '1';
    ir_canon_in.trigger <= '1';
    wait until Clk = '1';
    ir_canon_in.trigger <= '0';
    wait for 15 ms;
  end process WaveGen_Proc;

end tb;

-------------------------------------------------------------------------------

configuration ir_canon_tb_tb_cfg of ir_canon_tb is
  for tb
  end for;
end ir_canon_tb_tb_cfg;

