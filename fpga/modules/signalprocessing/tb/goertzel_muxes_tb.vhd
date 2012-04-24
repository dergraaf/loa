-------------------------------------------------------------------------------
-- Title      : Testbench for design "goertzel_muxes"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_muxes_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-24
-- Last update: 2012-04-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity goertzel_muxes_tb is

end entity goertzel_muxes_tb;

-------------------------------------------------------------------------------

architecture tb of goertzel_muxes_tb is

   -- component generics
   constant CHANNELS    : positive := 12;
   constant FREQUENCIES : positive := 5;

   -- component ports
   signal mux_delay1_p : std_logic                                   := '0';
   signal mux_delay2_p : std_logic                                   := '0';
   signal mux_coef     : natural range FREQUENCIES-1 downto 0        := 0;
   signal mux_input    : natural range CHANNELS-1 downto 0           := 0;
   signal bram_data    : goertzel_result_type                        := (others => (others => '0'));
   signal coefs_p      : goertzel_coefs_type(FREQUENCIES-1 downto 0) := (others => (others => '0'));
   signal inputs_p     : goertzel_inputs_type(CHANNELS-1 downto 0)   := (others => (others => '0'));
   signal delay1_p     : goertzel_data_type                          := (others => '0');
   signal delay2_p     : goertzel_data_type                          := (others => '0');
   signal coef_p       : goertzel_coef_type                          := (others => '0');
   signal input_p      : goertzel_input_type                         := (others => '0');

   -- clock
   signal Clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : entity work.goertzel_muxes
      generic map (
         CHANNELS    => CHANNELS,
         FREQUENCIES => FREQUENCIES)
      port map (
         mux_delay1_p => mux_delay1_p,
         mux_delay2_p => mux_delay2_p,
         mux_coef     => mux_coef,
         mux_input    => mux_input,
         bram_data    => bram_data,
         coefs_p      => coefs_p,
         inputs_p     => inputs_p,
         delay1_p     => delay1_p,
         delay2_p     => delay2_p,
         coef_p       => coef_p,
         input_p      => input_p);

   -- clock generation
   clk <= not clk after 10 ns;

   bram_data(0) <= "110011001100110011";
   bram_data(1) <= "101010101010101010";


   stim : process
      variable seed1, seed2 : positive;
      variable Rand         : real;
      variable IRand        : integer;
   begin
      for ii in 0 to CHANNELS-1 loop
         -- Zufallszahl ziwschen 0 und 1
         uniform(seed1, seed2, rand);
         -- daraus ein Integer zwischen 0 und 2^14-1
         irand := integer((rand* (2.0**14-1.0)));

         inputs_p(ii) <= to_signed(irand, 14);
      end loop;  -- ii

      for ii in 0 to FREQUENCIES-1 loop
         -- Zufallszahl ziwschen 0 und 1
         uniform(seed1, seed2, rand);
         -- daraus ein Integer zwischen 0 und 2^14-1
         irand := integer((rand* (2.0**14-1.0)));

         coefs_p(ii) <= to_signed(irand, 18);
      end loop;  -- ii

      -- do not repeat
      wait for 10 ms;
      
   end process;

   -- waveform generation
   WaveGen_Proc : process
   begin
      wait until clk = '0';
      wait until clk = '0';
      mux_delay1_p <= '1';
      wait until clk = '0';
      mux_delay1_p <= '0';
      wait until clk = '0';
      mux_delay2_p <= '1';
      wait until clk = '0';
      mux_delay2_p <= '0';
      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';

      -- all channels
      for ii in 0 to CHANNELS-1 loop
         mux_input <= ii;
         wait until clk = '0';
      end loop;  -- ii

      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';

      -- all coefs
      for ii in 0 to FREQUENCIES-1 loop
         mux_coef <= ii;
         wait until clk = '0';
      end loop;  -- ii

      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';

      -- do not repeat
      wait for 10 ms;

   end process WaveGen_Proc;

end architecture tb;
