-------------------------------------------------------------------------------
-- Title      : Testbench for simple ADC LTC2351 model
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Test the model of LTC2351, not self-checking. 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

-------------------------------------------------------------------------------

entity adc_ltc2351_model_tb is

end adc_ltc2351_model_tb;

-------------------------------------------------------------------------------

architecture tb of adc_ltc2351_model_tb is


  use work.adc_ltc2351_pkg.all;

  -- Component generics
  -- none

  -- Component ports
  signal sck_p  : std_logic := '0';
  signal sdo_p  : std_logic := '0';
  signal conv_p : std_logic := '0';

begin
  -- component instantiation
  MUT : adc_ltc2351_model
    port map (
      sck  => sck_p,
      conv => conv_p,
      sdo  => sdo_p
      );

  ----------------------------------------------------------------------------
  -- clock generation

  sck_p <= not sck_p after 20 ns;

  waveform : process
  begin  -- process waveform
    -- single pulse of CONV to start conversion
    wait for 160 ns;
    conv_p <= '1';
    wait for 80 ns;
    conv_p <= '0';
    wait for 10 ms;
  end process waveform;
end tb;
