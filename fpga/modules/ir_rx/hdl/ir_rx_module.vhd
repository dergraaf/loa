-------------------------------------------------------------------------------
-- Title      : Module for Receiver for infrared beacons
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_module.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-13
-- Last update: 2012-04-26
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

   -- Memory maps
   --
   -- Coefficient Register
   -- offset | R/W | Description
   -- -------+-------------------------------------------------
   --    +00 |   W | Goertzel Coefficient           Frequency 0
   --    +01 |   W | Goertzel Coefficient           Frequency 1
   -- 
   -- Result Register
   -- offset | R/W | Description
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
   --    +18 |   R | Goertzel Result 0, Channel  0, Frequency 1
   --    +19 |   R | Goertzel Result 1, Channel  0, Frequency 1
   --    +1A |   R | Goertzel Result 0, Channel  1, Frequency 1
   --    +1B |   R | Goertzel Result 1, Channel  1, Frequency 1
   --    +1C |   R | Goertzel Result 0, Channel  2, Frequency 1
   --    +1D |   R | Goertzel Result 1, Channel  2, Frequency 1
   --    +1E |   R | Goertzel Result 0, Channel  3, Frequency 1
   --    +1F |   R | Goertzel Result 1, Channel  3, Frequency 1
   --    +20 |   R | Goertzel Result 0, Channel  4, Frequency 1
   --    +21 |   R | Goertzel Result 1, Channel  4, Frequency 1
   --    +22 |   R | Goertzel Result 0, Channel  5, Frequency 1
   --    +23 |   R | Goertzel Result 1, Channel  5, Frequency 1
   --    +24 |   R | Goertzel Result 0, Channel  6, Frequency 1
   --    +25 |   R | Goertzel Result 1, Channel  6, Frequency 1
   --    +26 |   R | Goertzel Result 0, Channel  7, Frequency 1
   --    +27 |   R | Goertzel Result 1, Channel  7, Frequency 1
   --    +28 |   R | Goertzel Result 0, Channel  8, Frequency 1
   --    +29 |   R | Goertzel Result 1, Channel  8, Frequency 1 
   --    +2A |   R | Goertzel Result 0, Channel  9, Frequency 1
   --    +2B |   R | Goertzel Result 1, Channel  9, Frequency 1 
   --    +2C |   R | Goertzel Result 0, Channel 10, Frequency 1
   --    +2D |   R | Goertzel Result 1, Channel 10, Frequency 1
   --    +2E |   R | Goertzel Result 0, Channel 11, Frequency 1
   --    +2F |   R | Goertzel Result 1, Channel 11, Frequency 1
   --
   -- +000 to +03f = 6 Bits = 2^6 = 64 words
   --
   -- The Block RAM is bigger and other working sets up to
   -- Channels * Frequenies <= 256 are possible.
   --
   -- Mind the execution time for big datasets:
   -- 4 cycles per channel and frequency + 4 cycles to fill the pipeline
   --
   -- E.g.: 12 channels, 5 frequencies, f_clk = 50 MHz, f_sample = 250 kHz
   --
   -- 1/f_clk = 20 ns
   -- 1/f_sample = 4 us
   -- 12 * 5 * 4 = 240 * 20 ns = 4.8 us > 4.0 us (clash!)
   --

   
   generic (
      -- Base address at the internal data bus of the register for the coefficients
      BASE_ADDRESS_COEFS : integer range 0 to 32767;

      -- Bas address at the internal data bus of the dual port block RAM register for
      -- the  results
      BASE_ADDRESS_RESULTS : integer range 0 to 32767
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
      -- starts a new ADC conversion and starts processing with goertzel algorithm.
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

   signal module_done_s : std_logic := '0';

   -- Connection between bram and pipelined
   signal bram_data_i : std_logic_vector(35 downto 0);
   signal bram_data_o : std_logic_vector(35 downto 0);
   signal bram_addr_s : std_logic_vector(7 downto 0);
   signal bram_we_s   : std_logic;


   signal adc_start_s : std_logic := '0';
   signal adc_done_s  : std_logic := '0';

   signal reg_coefs_s : reg_file_type(7 downto 0);

   signal goertzel_done_s : std_logic;
   
begin  -- structural

   ----------------------------------------------------------------------------
   -- Connect components
   ----------------------------------------------------------------------------
   adc_values_p <= adc_values_s;
   done_p       <= module_done_s;


   -- convert std_logic_vector to goertzel coefficients
   coef_loop : for ii in 0 to FREQUENCIES-1 generate
      coefs_s(ii) <= "00" & signed(reg_coefs_s(ii));
   end generate coef_loop;


   ----------------------------------------------------------------------------
   -- Component Instantiation
   ----------------------------------------------------------------------------

   -- Register file for the goertzel coefficients,
   -- write only
   reg_file_coefs_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_COEFS,
         REG_ADDR_BIT => 3  -- 2**3 = 8 registers of 16 bits for goertzel coefficients
         )
      port map (
         bus_o => open,
         bus_i => bus_i,
         reg_o => reg_coefs_s,
         reg_i => reg_coefs_s,
         reset => '0',
         clk   => clk
         );

   -- Block RAM with double buffering for the results
   -- read only
   reg_file_results_1 : entity work.reg_file_bram_double_buffered
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_RESULTS)
      port map (
         bus_o => bus_o,
         bus_i => bus_i,

         bram_data_i => bram_data_i,
         bram_data_o => bram_data_o,
         bram_addr_i => bram_addr_s,
         bram_we_p   => bram_we_s,

         irq_p    => module_done_s,
         ack_p    => ack_p,
         ready_p  => goertzel_done_s,
         enable_p => open,
         clk      => clk);

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

   -- translate raw ADC values to signed
   -- 14-bit ADC value, 0x0000 to 0x3fff, 0x2000 on average
   adc_values_loop : for ch in CHANNELS-1 downto 0 generate
      adc_values_signed_s(ch) <= signed(adc_values_s(ch)) - to_signed(16#2000#, 16)(INPUT_WIDTH-1 downto 0);
   end generate adc_values_loop;

   goertzel_pipelined_v2_1: entity work.goertzel_pipelined_v2
      generic map (
         FREQUENCIES  => FREQUENCIES,
         CHANNELS     => CHANNELS,
         SAMPLES      => SAMPLES,
         Q            => Q,
         BASE_ADDRESS => BASE_ADDRESS_RESULTS)
      port map (
         start_p     => adc_done_s,     -- whenever ADC is done process a new sample
         
         bram_addr_p => bram_addr_s,
         bram_data_i => bram_data_i,
         bram_data_o => bram_data_o,
         bram_we_p   => bram_we_s,
         
         ready_p     => goertzel_done_s,
         enable_p    => '1',            -- not used yet
         coefs_p     => coefs_s,
         inputs_p    => adc_values_signed_s,
         clk         => clk);
   
   -- Sync extraction
   -- TODO

end structural;
