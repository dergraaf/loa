-------------------------------------------------------------------------------
-- Title      : DS18b20 Reader Testbench
-------------------------------------------------------------------------------
-- Note: Sorry, only poor visual wavwform inspection for now.
--
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-14
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
use work.onewire_pkg.all;
use work.onewire_cfg_pkg.all;
use work.ds18b20_pkg.all;

-------------------------------------------------------------------------------

entity ds18b20_tb is

end ds18b20_tb;

-------------------------------------------------------------------------------

architecture tb of ds18b20_tb is

  component ds18b20
    port (
      ow_out      : in  onewire_out_type;
      ow_in       : out onewire_in_type;
      ds18b20_in  : in  ds18b20_in_type;
      ds18b20_out : out ds18b20_out_type;
      clk         : in  std_logic);
  end component;

-- component ports
  signal ow_out      : onewire_out_type := (d       => (others => '0'), busy => '0', err => '0');
  signal ow_in       : onewire_in_type;
  signal ds18b20_in  : ds18b20_in_type  := (refresh => '0');
  signal ds18b20_out : ds18b20_out_type;

-- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : ds18b20
    port map (
      ow_out      => ow_out,
      ow_in       => ow_in,
      ds18b20_in  => ds18b20_in,
      ds18b20_out => ds18b20_out,
      clk         => clk);

  -- clock generation
  Clk <= not Clk after 10 ns;

  -- waveform generation
  WaveGen_Proc : process
  begin
    wait until Clk = '1';
    ds18b20_in.refresh <= '1';
    wait until Clk = '1';
    ds18b20_in.refresh <= '0';

    wait until Clk = '1';
    ow_out.busy <= '1';
    wait for 100 ns;
    ow_out.busy <= '0';
    wait until Clk = '1';

    ow_out.busy <= '1';
    wait for 100 ns;
    ow_out.busy <= '0';
    wait until Clk = '1';

    ow_out.busy <= '1';
    wait for 100 ns;
    ow_out.busy <= '0';
    wait until Clk = '1';

    ow_out.busy <= '1';
    wait for 100 ns;
    ow_out.busy <= '0';
    wait until Clk = '1';

    wait for 20 ms;
  end process WaveGen_Proc;


  process
  begin
    wait for 1 us;
    ow_out.d <= x"ff";
  end process;
  
end tb;

