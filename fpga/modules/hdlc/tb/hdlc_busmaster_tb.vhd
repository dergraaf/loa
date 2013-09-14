-------------------------------------------------------------------------------
-- Title      : Testbench for design HDLC Busmaster
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
use work.bus_pkg.all;
use work.reg_file_pkg.all;

use std.textio.all;

-------------------------------------------------------------------------------

entity hdlc_busmaster_tb is
end entity hdlc_busmaster_tb;

-------------------------------------------------------------------------------

architecture behavourial of hdlc_busmaster_tb is

  -- component ports

  signal tb_to_enc         : hdlc_enc_in_type   := (data => (others => '1'), enable => '0');
  signal enc_to_dec        : hdlc_enc_out_type  := (data => (others => '0'), enable => '0');
  signal dec_to_busmaster  : hdlc_dec_out_type  := (data => (others => '0'), enable => '0');
  signal bus_to_master     : busmaster_in_type  := (data => (others => '0'));
  signal master_to_bus     : busmaster_out_type := (addr => (others => '0'), data => (others => '0'), re => '0', we => '0');
  signal busmaster_to_enc2 : hdlc_enc_in_type   := (data => (others => '0'), enable => '0');
  signal enc_busy          : std_logic          := '0';

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
      dout_p => dec_to_busmaster,
      clk    => clk);

  DUT_bus_mst : work.hdlc_pkg.hdlc_busmaster
    port map(
      din_p  => dec_to_busmaster,
      dout_p => busmaster_to_enc2,
      bus_o  => master_to_bus,
      bus_i  => bus_to_master,
      clk    => clk);

  DUT_reg : work.reg_file_pkg.peripheral_register
    generic map(
      BASE_ADDRESS => 16#0080#)
    port map(
      dout_p => open,
      din_p  => x"1234",
      bus_o  => bus_to_master,
      bus_i  => master_to_bus,
      clk    => clk);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    wait until rising_edge(Clk);

    wait until rising_edge(Clk);

    -- read with good crc
    tb_to_enc.data   <= "1" & x"00";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"10";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"00";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"80";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"2B";    -- crc correct
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';

    -- read with bad crc 
    tb_to_enc.data   <= "1" & x"00";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"10";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"00";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"80";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"2c";    -- crc incorrect
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';

    -- write with good crc
    tb_to_enc.data   <= "1" & x"00";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"20";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"00";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"80";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"0f";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"0f";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"81";    -- good crc
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';

    -- write with bad crc
    tb_to_enc.data   <= "1" & x"00";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"20";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"00";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"80";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"0f";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"0f";
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    tb_to_enc.data   <= "0" & x"80";    -- good crc
    tb_to_enc.enable <= '1';

    wait until Clk = '1';
    tb_to_enc.enable <= '0';

    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';

    wait for 10 ms;

  end process WaveGen_Proc;

end architecture behavourial;
