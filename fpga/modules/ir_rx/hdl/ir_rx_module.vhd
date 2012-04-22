-------------------------------------------------------------------------------
-- Title      : Module for Receiver for infrared beacons
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_module.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-13
-- Last update: 2012-04-20
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--
-- Two functions:
-- a) Extract sync from IR signal
-- b) Measure frequency component of opponent beacons (with Goertzel algorithm)
--
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.reg_file_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.ir_rx_module_pkg.all;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity ir_rx_module is

   -- Memory map
   -- 
   -- offset | R/W | Description
   -- -------+-------------------------------------------------
   --    +00 |   W | Goertzel Coefficient           Frequency 0
   --    +01 |   W | Goertzel Coefficient           Frequency 1
   -- -------+-----+-------------------------------------------
   --    +00 |   R | Goertzel Result 0, Channel  0, Frequency 0
   --    +01 |   R | Goertzel Result 1, Channel  0, Frequency 0
   --    +02 |   R | Goertzel Result 0, Channel  1, Frequency 0
   --    +03 |   R | Goertzel Result 1, Channel  1, Frequency 0
   --    +04 |   R | Goertzel Result 0, Channel  2, Frequency 0
   --    +05 |   R | Goertzel Result 1, Channel  2, Frequency 0
   --    +06 |   R | Goertzel Result 0, Channel  3, Frequency 0
   --    +07 |   R | Goertzel Result 1, Channel  3, Frequency 0
   --    +08 |   R | Goertzel Result 0, Channel  4, Frequency 0
   --    +09 |   R | Goertzel Result 1, Channel  4, Frequency 0
   --    +0A |   R | Goertzel Result 0, Channel  5, Frequency 0
   --    +0B |   R | Goertzel Result 1, Channel  5, Frequency 0
   --    +0C |   R | Goertzel Result 0, Channel  6, Frequency 0
   --    +0D |   R | Goertzel Result 1, Channel  6, Frequency 0
   --    +0E |   R | Goertzel Result 0, Channel  7, Frequency 0
   --    +0F |   R | Goertzel Result 1, Channel  7, Frequency 0
   --    +10 |   R | Goertzel Result 0, Channel  8, Frequency 0
   --    +11 |   R | Goertzel Result 1, Channel  8, Frequency 0 
   --    +12 |   R | Goertzel Result 0, Channel  9, Frequency 0
   --    +13 |   R | Goertzel Result 1, Channel  9, Frequency 0 
   --    +14 |   R | Goertzel Result 0, Channel 10, Frequency 0
   --    +15 |   R | Goertzel Result 1, Channel 10, Frequency 0
   --    +16 |   R | Goertzel Result 0, Channel 11, Frequency 0
   --    +17 |   R | Goertzel Result 1, Channel 11, Frequency 0
   -- ---------------------------------------------------------
   --    +20 |   R | Goertzel Result 0, Channel  0, Frequency 1
   --    +21 |   R | Goertzel Result 1, Channel  0, Frequency 1
   --    +22 |   R | Goertzel Result 0, Channel  1, Frequency 1
   --    +23 |   R | Goertzel Result 1, Channel  1, Frequency 1
   --    +24 |   R | Goertzel Result 0, Channel  2, Frequency 1
   --    +25 |   R | Goertzel Result 1, Channel  2, Frequency 1
   --    +26 |   R | Goertzel Result 0, Channel  3, Frequency 1
   --    +27 |   R | Goertzel Result 1, Channel  3, Frequency 1
   --    +28 |   R | Goertzel Result 0, Channel  4, Frequency 1
   --    +29 |   R | Goertzel Result 1, Channel  4, Frequency 1
   --    +2A |   R | Goertzel Result 0, Channel  5, Frequency 1
   --    +2B |   R | Goertzel Result 1, Channel  5, Frequency 1
   --    +2C |   R | Goertzel Result 0, Channel  6, Frequency 1
   --    +2D |   R | Goertzel Result 1, Channel  6, Frequency 1
   --    +2E |   R | Goertzel Result 0, Channel  7, Frequency 1
   --    +2F |   R | Goertzel Result 1, Channel  7, Frequency 1
   --    +30 |   R | Goertzel Result 0, Channel  8, Frequency 1
   --    +31 |   R | Goertzel Result 1, Channel  8, Frequency 1 
   --    +32 |   R | Goertzel Result 0, Channel  9, Frequency 1
   --    +33 |   R | Goertzel Result 1, Channel  9, Frequency 1 
   --    +34 |   R | Goertzel Result 0, Channel 10, Frequency 1
   --    +35 |   R | Goertzel Result 1, Channel 10, Frequency 1
   --    +36 |   R | Goertzel Result 0, Channel 11, Frequency 1
   --    +37 |   R | Goertzel Result 1, Channel 11, Frequency 1
   --
   -- +000 to +03f = 6 Bits = 2^6 = 64 words

   
   generic (
      BASE_ADDRESS : integer range 0 to 32767  -- Base address at the internal data bus
      );

   port (
      -- Ports to two ADCs
      -- signals to and from real hardware
      adc_out_p : out ir_rx_module_spi_out_type;
      adc_in_p  : in  ir_rx_module_spi_in_type;

      -- Raw values of last ADC conversions (two ADCs with six channels each)
      adc_values_p : out adc_ltc2351_values_type(11 downto 0);

      -- Extracted sync signal
      sync_p : out std_logic;

      -- signals to and from the internal parallel bus
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      -- Handshake interface to STM when new data is available
      done_p : out std_logic;
      ack_p  : in  std_logic;

      -- Sampling clock enable (expected to be 250 kHz or less)
      clk_sample_en : in std_logic;

      clk : in std_logic
      );

end ir_rx_module;

architecture structural of ir_rx_module is
   ----------------------------------------------------------------------------
   -- Constants
   ----------------------------------------------------------------------------

--   constant INPUT_WIDTH : natural := 14;
--   constant CALC_WIDTH  : natural := 18;
   constant Q           : natural := 13;
   constant SAMPLES     : natural := 250;
   constant CHANNELS    : natural := 12;
   constant FREQUENCIES : natural := 2;

   constant COEF : unsigned := to_unsigned(2732, CALC_WIDTH);

   ----------------------------------------------------------------------------
   -- Internal signal declaration
   ----------------------------------------------------------------------------

   -- twelve ADC channels
   signal adc_values_s : adc_ltc2351_values_type(CHANNELS-1 downto 0) := (others => (others => '0'));

   -- conversion to signed values
   signal adc_values_signed_s : goertzel_inputs_type(CHANNELS-1 downto 0) := (others => (others => '0'));

   -- Goertzel coefficients, one for each frequency
   signal coefs_s : goertzel_coefs_type(FREQUENCIES-1 downto 0) := (others => (others => '0'));

   signal results_s : goertzel_results_type(CHANNELS-1 downto 0, FREQUENCIES-1 downto 0) := (others => (others => (others => (others => '0'))));

   signal module_done : std_logic := '0';

   -- TODO Twelve results from Goertzel
   -- TODO: search for two frequencies


   signal adc_start_s : std_logic := '0';
   signal adc_done_s  : std_logic := '0';

   signal reg_o : reg_file_type(63 downto 0);
   signal reg_i : reg_file_type(63 downto 0);

   signal goertzel_done_s : std_logic;
   
begin  -- structural

   ----------------------------------------------------------------------------
   -- Connect components
   ----------------------------------------------------------------------------
   adc_values_p <= adc_values_s;

   -- only the upper bits that fit in in the register
   copy_freq_loop : for fr in FREQUENCIES-1 downto 0 generate
      copy_channel_loop : for ii in 0 to (CHANNELS*2 - 1) generate
         reg_i(ii + fr * 16#0020#) <=
            std_logic_vector(
               --        |-ch-|     |-  0/1 -|
               results_s(ii / 2, fr)(ii mod 2)
               -- adjust length, only the upper bits that fit in in the register
               (results_s(0, 0)(0)'length-1 downto results_s(0, 0)(0)'length - reg_i(0)'length)
               );
      end generate copy_channel_loop;
   end generate copy_freq_loop;

   coef_loop : for ii in 0 to FREQUENCIES-1 generate
      coefs_s(ii) <= "00" & unsigned(reg_o(ii));
   end generate coef_loop;

   done_p <= module_done;

   ----------------------------------------------------------------------------
   -- Component Instantiation
   ----------------------------------------------------------------------------

   -- Register file to present Goertzel values to bus
   reg_file_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => 6  -- 2**6 = 64 registers for goertzel values
         )
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_o,
         reg_i => reg_i,
         reset => '0',
         clk   => clk
         );

   -- Two ADCs
   adc_ltc2351_0 : adc_ltc2351
      port map (
         adc_out  => adc_out_p(0),
         adc_in   => adc_in_p(0),
         start_p  => clk_sample_en,
         values_p => adc_values_s(5 downto 0),
         done_p   => adc_done_s,
         reset    => '0',
         clk      => clk
         );

   adc_ltc2351_1 : adc_ltc2351
      port map (
         adc_out  => adc_out_p(1),
         adc_in   => adc_in_p(1),
         start_p  => clk_sample_en,
         values_p => adc_values_s(11 downto 6),
         done_p   => open,
         reset    => '0',
         clk      => clk
         );

   -- 12 Goertzel algorithms

   -- 14-bit ADC value, 0x0000 to 0x3fff, 0x2000 on average
   adc_values_loop : for ch in CHANNELS-1 downto 0 generate
      adc_values_signed_s(ch) <= signed(adc_values_s(ch)) - to_signed(16#2000#, 16)(INPUT_WIDTH-1 downto 0);
   end generate adc_values_loop;

   goertzel_pipelined_1 : goertzel_pipelined
      generic map (
         Q           => Q,
         CHANNELS    => CHANNELS,
         FREQUENCIES => FREQUENCIES,
         SAMPLES     => SAMPLES)
      port map (
         coefs_p   => coefs_s,
         inputs_p  => adc_values_signed_s,
         start_p   => adc_done_s,
         results_p => results_s,
         done_p    => goertzel_done_s,
         clk       => clk);

   ---- Channel 5
   --goertzel_5 : goertzel
   --   generic map (
   --      Q       => Q,
   --      SAMPLES => SAMPLES)
   --   port map (
   --      clk         => clk,
   --      coef_p      => COEF,
   --      start_p     => adc_done_s,
   --      adc_value_p => adc_value_signed_s,
   --      result_p    => results_s,
   --      done_p      => goertzel_done_s
   --      );

   -- Sync extraction
   -- TODO

   -- Handshake when new Goertzel values are available
   handshake_proc : process (clk)
   begin  -- process handshake_proc
      if rising_edge(clk) then
         if goertzel_done_s = '1' then
            module_done <= '1';
         elsif ack_p = '1' then
            module_done <= '0';
         end if;
      end if;
   end process handshake_proc;

end structural;
