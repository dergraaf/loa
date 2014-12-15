-------------------------------------------------------------------------------
-- Title      : Onewire Master Testbench - Reset Operation
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
use work.onewire_pkg.all;
use work.onewire_cfg_pkg.all;

-------------------------------------------------------------------------------

entity onewire_reset_tb is

end onewire_reset_tb;

-------------------------------------------------------------------------------

architecture tb of onewire_reset_tb is

  component onewire
    port (
      onewire_in      : in  onewire_in_type;
      onewire_out     : out onewire_out_type;
      onewire_bus_in  : in  onewire_bus_in_type;
      onewire_bus_out : out onewire_bus_out_type;
      clk             : in  std_logic);
  end component;

  -- component ports
  signal onewire_in      : onewire_in_type;
  signal onewire_out     : onewire_out_type;
  signal onewire_bus_in  : onewire_bus_in_type;
  signal onewire_bus_out : onewire_bus_out_type;

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -- component instantiation
  DUT : onewire
    port map (
      onewire_in      => onewire_in,
      onewire_out     => onewire_out,
      onewire_bus_in  => onewire_bus_in,
      onewire_bus_out => onewire_bus_out,
      clk             => clk);

  -- clock generation
  Clk <= not Clk after 10 ns;           -- 50MHz Clock

  -- waveform generation
  WaveGen_Proc : process
  begin
    onewire_in.d         <= (others => '0');
    onewire_in.re        <= '0';
    onewire_in.we        <= '0';
    onewire_in.reset_bus <= '0';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    onewire_in.reset_bus <= '1';
    wait until Clk = '1';
    onewire_in.reset_bus <= '0';
    wait for 2.5 ms;
  end process WaveGen_Proc;


  WaveGen_onewire_device : process
    variable device_response : std_logic := '0';
  begin
    onewire_bus_in.d <= '1';
    wait until onewire_bus_out.en_driver = '1';
    wait for 480 us;
    wait for 60 us;
    onewire_bus_in.d <= device_response;
    device_response  := not device_response;  -- Bus reset will fail every second
                                              -- time.
    wait for 240 us;
  end process WaveGen_onewire_device;




end tb;

