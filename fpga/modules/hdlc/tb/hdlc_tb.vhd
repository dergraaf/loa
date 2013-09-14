-------------------------------------------------------------------------------
-- Title      : Testbench for design HDLC Enc/Dec
-------------------------------------------------------------------------------
-- Author     : Carl Treudler (cjt@users.sourceforge.net)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:  Some Testbench
-------------------------------------------------------------------------------
-- Copyright (c) 2013, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.hdlc_pkg.all;

use std.textio.all;

-------------------------------------------------------------------------------

entity hdlc_tb is
end entity hdlc_tb;

-------------------------------------------------------------------------------

architecture behavourial of hdlc_tb is

  -- component ports

  signal tb_to_enc  : hdlc_enc_in_type  := (data => (others => '1'), enable => '0');
  signal enc_to_dec : hdlc_enc_out_type := (data => (others => '0'), enable => '0');
  signal dec_to_tb  : hdlc_dec_out_type := (data => (others => '0'), enable => '0');

  signal enc_busy : std_logic;

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture behavourial

  -- component instantiation
  DUT_enc : work.hdlc_pkg.hdlc_enc
    port map(
      din_p  => tb_to_enc,
      dout_p => enc_to_dec,
      busy_p => enc_busy,
      clk    => clk);

  DUT_dec : work.hdlc_pkg.hdlc_dec
    port map(
      din_p  => enc_to_dec,
      dout_p => dec_to_tb,
      clk    => clk);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    wait until rising_edge(Clk);

    wait until rising_edge(Clk);

    tb_to_enc.data   <= "1" & x"00";
    tb_to_enc.enable <= '1';

    wait until rising_edge(Clk);
    tb_to_enc.enable <= '0';

    wait until Clk = '1';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"55";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"AA";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';

    wait until Clk = '1';

    wait until clk = '1';

    tb_to_enc.data   <= "0" & x"7d";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"7e";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"AA";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait for 10 ms;

  end process WaveGen_Proc;

end architecture behavourial;
