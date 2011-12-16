-------------------------------------------------------------------------------
-- Title      : Testbench for design "quadrature_decoder"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : quadrature_decoder_tb.vhd
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : 
-- Created    : 2011-12-15
-- Last update: 2011-12-16
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-12-15  1.0      fabian  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.quadrature_decoder_pkg.all;

-------------------------------------------------------------------------------
entity quadrature_decoder_tb is

end quadrature_decoder_tb;

-------------------------------------------------------------------------------
architecture tb of quadrature_decoder_tb is
  type input_type is record
    a : std_logic;
    b : std_logic;
  end record;

  type expect_type is record
    step  : std_logic;
    dir   : std_logic;
    error : std_logic;
  end record;

  type stimulus_type is record
    input  : input_type;
    expect : expect_type;
  end record;

  type stimuli_type is array (natural range <>) of stimulus_type;

  constant stimuli : stimuli_type := (
    (input => ('0', '0'), expect => ('0', '-', '0')),
    (input => ('1', '0'), expect => ('1', '1', '0')),
    (input => ('1', '0'), expect => ('0', '-', '0')),
    (input => ('1', '1'), expect => ('1', '1', '0')),
    (input => ('0', '1'), expect => ('1', '1', '0')),
    (input => ('0', '0'), expect => ('1', '1', '0')),
    (input => ('1', '0'), expect => ('1', '1', '0')),
    (input => ('1', '1'), expect => ('1', '1', '0')),
    (input => ('1', '1'), expect => ('0', '-', '0')),
    (input => ('1', '0'), expect => ('1', '0', '0')),
    (input => ('0', '0'), expect => ('1', '0', '0')),
    (input => ('1', '0'), expect => ('1', '1', '0')),
    (input => ('0', '0'), expect => ('1', '0', '0')),
    (input => ('0', '0'), expect => ('0', '-', '0')),
    (input => ('0', '1'), expect => ('1', '0', '0')),
    (input => ('0', '0'), expect => ('1', '1', '0')),
    (input => ('0', '1'), expect => ('1', '0', '0')),
    (input => ('1', '1'), expect => ('1', '0', '0')),
    (input => ('1', '0'), expect => ('1', '0', '0')),
    (input => ('0', '0'), expect => ('1', '0', '0')),
    (input => ('1', '1'), expect => ('0', '-', '1')),
    (input => ('0', '0'), expect => ('0', '-', '1')),
    (input => ('0', '1'), expect => ('1', '0', '0')),
    (input => ('1', '1'), expect => ('1', '0', '0')),
    (input => ('0', '0'), expect => ('0', '-', '1')),
    (input => ('0', '0'), expect => ('0', '0', '0'))
    );

  -- component ports
  signal a     : std_logic := '0';
  signal b     : std_logic := '0';
  signal step  : std_logic;
  signal dir   : std_logic;
  signal error : std_logic;

  -- clock
  signal clk : std_logic := '1';
begin

  -- component instantiation
  DUT : quadrature_decoder
    port map (
      a_p     => a,
      b_p     => b,
      step_p  => step,
      dir_p   => dir,
      error_p => error,
      clk     => clk);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  wave : process
  begin
    wait until falling_edge(reset);
    wait for 20 ns;

    for i in stimuli'left to (stimuli'right + 2) loop
      wait until rising_edge(clk);
      if i <= stimuli'right then
        a <= stimuli(i).input.a;
        b <= stimuli(i).input.b;
      else
        a <= '0';
        b <= '0';
      end if;

      if i > (stimuli'left + 2) then
        -- values are active at the output after two clock cycles
        assert (step = stimuli(i-2).expect.step) report "Wrong value for 'step'" severity note;
        if not (stimuli(i-2).expect.dir = '-') then
          assert (dir = stimuli(i-2).expect.dir) report "Wrong value for 'dir'" severity note;
        end if;
        assert (error = stimuli(i-2).expect.error) report "Wrong value for 'error'" severity note;
      end if;
    end loop;  -- i
  end process wave;

end tb;
