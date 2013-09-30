-------------------------------------------------------------------------------
-- Title      : Goertel Muxes
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Selects one data word, one coefficient and one input from the
-- arrays of different channels/frequencies. Truely combinatorial.
-- goertzel_pipeline has registers at its inputs. 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.signalprocessing_pkg.all;

entity goertzel_muxes is
   generic (
      CHANNELS    : positive := 12;
      FREQUENCIES : positive);
   port (
      -- control pins of the muxes, from control unit
      mux_delay1_p : in  std_logic;
      mux_delay2_p : in  std_logic;
      mux_coef     : in  natural range FREQUENCIES-1 downto 0;
      mux_input    : in  natural range CHANNELS-1 downto 0;

      -- data to mux
      bram_data    : in  goertzel_result_type;
      coefs_p      : in  goertzel_coefs_type;
      inputs_p     : in  goertzel_inputs_type;

      -- outputs of the mux
      delay1_p     : out goertzel_data_type;
      delay2_p     : out goertzel_data_type;
      coef_p       : out goertzel_coef_type;
      input_p      : out goertzel_input_type);

end entity goertzel_muxes;

architecture behavourial of goertzel_muxes is

begin  -- architecture behavourial

   -- be able to blank the input. This is necessary at the beginning of a
   -- cycle.
   delay1_p <= bram_data(0) when (mux_delay1_p = '1') else (others => '0');
   delay2_p <= bram_data(1) when (mux_delay2_p = '1') else (others => '0');

   -- select one coefficient from all coefficients
   coef_p <= coefs_p(mux_coef);

   -- select one input from all inputs
   input_p <= inputs_p(mux_input);

end architecture behavourial;
