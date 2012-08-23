-------------------------------------------------------------------------------
-- Title      : Module for Receiver for infrared beacons
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ir_rx_module.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-13
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
-- Copyright (c) 2012 strongly-typed
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
   --
   -- Lower 16 bits of Goertzel Coefficient in fixed point format
   -- 
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
   -- Channels * Frequencies <= 256 are possible.
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

      -- Base address at the internal data bus of the dual port block RAM register for
      -- the  results
      BASE_ADDRESS_RESULTS : integer range 0 to 32767;

      -- Base address at the internal data bus of the register with the
      -- timestamp of the last sample. 
      BASE_ADDRESS_TIMESTAMP : integer range 0 to 32767;

      -- How many samples should make a set of goertzel values
      SAMPLES : natural := 500
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

      -- Timestamp input from the timestamp module
      timestamp_i : in timestamp_type;

      clk : in std_logic
      );

end ir_rx_module;

architecture structural of ir_rx_module is
   ----------------------------------------------------------------------------
   -- Constants
   ----------------------------------------------------------------------------

   constant Q           : natural := 13;
   constant CHANNELS    : natural := 12;
   constant FREQUENCIES : natural := 2;

   ----------------------------------------------------------------------------
   -- Internal signal declaration
   ----------------------------------------------------------------------------

   -- twelve ADC channels
   signal adc_values_s : adc_ltc2351_values_type(CHANNELS-1 downto 0) := (others => (others => '0'));

   -- conversion to signed values
   signal adc_values_signed_s         : goertzel_inputs_type(CHANNELS-1 downto 0) := (others => (others => '0'));
   signal adc_values_signed_clipped_s : goertzel_inputs_type(CHANNELS-1 downto 0) := (others => (others => '0'));

   -- Goertzel coefficients, one for each frequency
   signal coefs_s : goertzel_coefs_type(FREQUENCIES-1 downto 0) := (others => (others => '0'));

   signal results_s : goertzel_results_type(CHANNELS-1 downto 0, FREQUENCIES-1 downto 0) := (others => (others => (others => (others => '0'))));

   signal module_done_s : std_logic := '0';

   -- Merge internal bus
   signal bus_coefs_s     : busdevice_out_type;
   signal bus_results_s   : busdevice_out_type;
   signal bus_timestamp_s : busdevice_out_type;

   -- Connection between bram and pipelined
   signal bram_data_i : std_logic_vector(35 downto 0);
   signal bram_data_o : std_logic_vector(35 downto 0);
   signal bram_addr_s : std_logic_vector(7 downto 0);
   signal bram_we_s   : std_logic;

   signal adc_start_s : std_logic := '0';
   signal adc_done_s  : std_logic := '0';

   signal reg_coefs_s : reg_file_type(FREQUENCIES-1 downto 0) := (others => (others => '0'));

   signal goertzel_done_s : std_logic;
   signal ack_s           : std_logic;

   -- Connection between timestamp module and register
   signal reg_timestamp_s : reg_file_type(3 downto 0) := (others => (others => '0'));
   
begin  -- structural

   ----------------------------------------------------------------------------
   -- Connect components
   ----------------------------------------------------------------------------
   bus_o.data <= bus_coefs_s.data or bus_results_s.data or bus_timestamp_s.data;

   adc_values_p <= adc_values_s;
   done_p       <= module_done_s;

   ack_s <= ack_p;

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
         REG_ADDR_BIT => log2(FREQUENCIES)  -- 2**n = FREQUENCIES registers of 16 bits for goertzel coefficients
         )
      port map (
         bus_o => bus_coefs_s,
         bus_i => bus_i,
         reg_o => reg_coefs_s,
         reg_i => reg_coefs_s,
         clk   => clk
         );

   -- Block RAM with double buffering for the results
   -- read only
   reg_file_results_1 : entity work.reg_file_bram_double_buffered
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_RESULTS)
      port map (
         bus_o => bus_results_s,
         bus_i => bus_i,

         bram_data_i => bram_data_i,    -- in
         bram_data_o => bram_data_o,    -- out
         bram_addr_i => bram_addr_s,    -- in
         bram_we_p   => bram_we_s,      -- in

         irq_o    => module_done_s,
         ack_i    => ack_s,
         ready_i  => goertzel_done_s,
         enable_o => open,
         clk      => clk);

   -- Register file for the timestamp,
   -- read only
   reg_file_timestamp_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_TIMESTAMP,
         REG_ADDR_BIT => 2  -- timestamp is a 48 bit register, so 3 registers
       -- of 16 bits each are necessary
         )
      port map (
         bus_o => bus_timestamp_s,
         bus_i => bus_i,
         reg_o => open,
         reg_i => reg_timestamp_s,
         clk   => clk
         );

   -- When the goertzel is finished, the goertzel_done_s signal is strobed.
   -- Copy timestamp to the register at this moment.
   timestamp_taker : process (clk) is
   begin  -- process timestamp_taker
      if rising_edge(clk) then          -- rising clock edge
         if goertzel_done_s = '1' then
            reg_timestamp_s(0) <= std_logic_vector(timestamp_i(15 downto 0));
            reg_timestamp_s(1) <= std_logic_vector(timestamp_i(31 downto 16));
            reg_timestamp_s(2) <= std_logic_vector(timestamp_i(47 downto 32));
         end if;
      end if;
   end process timestamp_taker;

   ------------------------------------------------------------------------------
   -- ADCs
   -------------------------------------------------------------------------------
   ir_rx_adcs_1 : ir_rx_adcs
      generic map (
         CHANNELS => CHANNELS)
      port map (
         clk_sample_en => clk_sample_en,
         adc_out       => adc_out_p,
         adc_in        => adc_in_p,
         adc_values_o  => adc_values_s,
         adc_done_o    => adc_done_s,
         clk           => clk);

   -- translate raw ADC values to signed
   -- 14-bit ADC value, 0x0000 to 0x3fff, 0x2000 on average
   adc_values_loop : for ch in CHANNELS-1 downto 0 generate
      adc_values_signed_s(ch) <= signed(adc_values_s(ch)) - to_signed(16#2000#, 16)(INPUT_WIDTH-1 downto 0);
   end generate adc_values_loop;

   adc_values_clip_loop : for ch in CHANNELS-1 downto 0 generate
      adc_values_signed_clipped_s(ch) <= to_signed(-200, INPUT_WIDTH) when adc_values_signed_s(ch) < -200 else
                                         to_signed(+200, INPUT_WIDTH) when adc_values_signed_s(ch) > +200 else
                                         adc_values_signed_s(ch);
   end generate adc_values_clip_loop;

   goertzel_pipelined_v2_1 : entity work.goertzel_pipelined_v2
      generic map (
         FREQUENCIES => FREQUENCIES,
         CHANNELS    => CHANNELS,
         SAMPLES     => SAMPLES,
         Q           => Q)
      port map (
         start_p => adc_done_s,  -- whenever ADC is done process a new sample

         bram_addr_p => bram_addr_s,
         bram_data_i => bram_data_o,
         bram_data_o => bram_data_i,
         bram_we_p   => bram_we_s,

         ready_p  => goertzel_done_s,
         enable_p => '1',                          -- not used yet
         coefs_p  => coefs_s,
         inputs_p => adc_values_signed_clipped_s,  -- adc_values_signed_s,
         clk      => clk);

   -- Sync extraction
   -- TODO

end structural;
