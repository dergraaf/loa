-------------------------------------------------------------------------------
-- Title      : Testbench for design "goertzel_pipelined_v2"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipelined_v2_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-24
-- Last update: 2012-04-26
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

library work;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity goertzel_pipelined_v2_tb is

end entity goertzel_pipelined_v2_tb;

-------------------------------------------------------------------------------

architecture tb of goertzel_pipelined_v2_tb is

   -- component generics
   constant FREQUENCIES : positive := 5;
   constant CHANNELS    : positive := 12;
   constant SAMPLES     : positive := 250;

   -- component ports
   signal start_p     : std_logic := '0';
   signal bram_addr_p : std_logic_vector(7 downto 0);
   signal bram_data_i : std_logic_vector(35 downto 0);
   signal bram_data_o : std_logic_vector(35 downto 0);
   signal bram_we_p   : std_logic;
   signal ready_p     : std_logic;
   signal enable_p    : std_logic;
   signal coefs_p     : goertzel_coefs_type(FREQUENCIES-1 downto 0);
   signal inputs_p    : goertzel_inputs_type(CHANNELS-1 downto 0);

   -- clock
   signal Clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : entity work.goertzel_pipelined_v2
      generic map (
         FREQUENCIES => FREQUENCIES,
         CHANNELS    => CHANNELS,
         SAMPLES     => SAMPLES)
      port map (
         start_p     => start_p,
         bram_addr_p => bram_addr_p,
         bram_data_i => bram_data_i,
         bram_data_o => bram_data_o,
         bram_we_p   => bram_we_p,
         ready_p     => ready_p,
         enable_p    => enable_p,
         coefs_p     => coefs_p,
         inputs_p    => inputs_p,
         clk         => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- dummy data
      bram_data_i <= "110111000000000000" & "010101010101010101";
      coefs_p(0)  <= "000000000000000001";
      coefs_p(1)  <= "000000000000000010";
      coefs_p(2)  <= "000000000000000100";
      coefs_p(3)  <= "000000000000001000";
      coefs_p(4)  <= "000000000000010000";

      inputs_p(0)  <= "00000000011010";
      inputs_p(1)  <= "00000000101010";
      inputs_p(2)  <= "00000000111010";
      inputs_p(3)  <= "00000001001010";
      inputs_p(4)  <= "00000011011010";
      inputs_p(5)  <= "00000111011010";
      inputs_p(6)  <= "00001111011010";
      inputs_p(7)  <= "00011111011010";
      inputs_p(8)  <= "00100111011010";
      inputs_p(9)  <= "00110011011010";
      inputs_p(10) <= "01010001011010";
      inputs_p(11) <= "01100001011010";

      wait until clk = '0';
      wait until clk = '1';
      wait until clk = '0';

      -- start the magic!
      start_p <= '1';
      wait until clk = '1';
      wait until clk = '0';
      start_p <= '0';

      wait until clk = '1';


      -- do not repeat
      wait for 10 ms;
   end process WaveGen_Proc;

end architecture tb;
