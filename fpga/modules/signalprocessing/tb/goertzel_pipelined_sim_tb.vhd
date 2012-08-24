-------------------------------------------------------------------------------
-- Title      : Simulation of Pipelined Goertzel Algorithm with Block RAM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipelined_sim.vhd
-- Author     : strongly-typed
-- Created    : 2012-04-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: This is a testbench that tests the goertzel_pipelined_v2
--              entity with a block ram and artifical signal sources.
--              The read cycle from the STM is simulated, too. The data is read
--              from the block RAM and written to the goertzel.bin file for
--              further simulation with the unit test of signalprocessing.cpp. 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.adc_ltc2351_pkg.all;
use work.reg_file_pkg.all;
use work.bus_pkg.all;
use work.signalprocessing_pkg.all;
use work.signal_sources_pkg.all;

entity goertzel_pipelined_sim_tb is

end goertzel_pipelined_sim_tb;

architecture tb of goertzel_pipelined_sim_tb is

-- signals

   signal clk : std_logic := '0';

   constant FREQUENCIES : natural := 2;
   constant CHANNELS    : natural := 12;
   constant SAMPLES     : natural := 500;
   constant Q           : natural := 13;

   constant BASE_ADDRESS           : natural := 16#0000#;
   constant BASE_ADDRESS_TIMESTAMP : natural := 16#0100#;

   signal data_to_bram   : std_logic_vector(35 downto 0);
   signal data_from_bram : std_logic_vector(35 downto 0);
   signal addr_to_bram   : std_logic_vector(7 downto 0);
   signal we_to_bram     : std_logic;

   signal irq_s : std_logic;
   signal ack_s : std_logic := '0';

   signal bus_i_dummy : busdevice_in_type := (addr => (others => '0'),
                                              data => (others => '0'),
                                              re   => '0',
                                              we   => '0');

   signal bus_to_stm, bus_to_stm_from_bram, bus_to_stm_from_timestamp : busdevice_out_type := (data => (others => '0'));

   signal start_s : std_logic := '0';

   signal ready_s : std_logic;  -- Goertzel result ready, switch RAM bank.

   signal bank_x_s : std_logic := '0';
   signal bank_y_s : std_logic := '0';

   -- One coefficient for each frequency, one input for each channel. 
   signal coefs  : goertzel_coefs_type(FREQUENCIES-1 downto 0) := (others => (others => '0'));
   signal inputs : goertzel_inputs_type(CHANNELS-1 downto 0)   := (others => (others => '0'));

   -- Goertzel results as signals
   signal gv0, gv1 : std_logic_vector(15 downto 0) := (others => '0');  -- value read from register

   type   g_array is array (0 to ((FREQUENCIES * CHANNELS) - 1)) of real;
   signal g_results : g_array := (others => 0.0);

   -- For each frequency the goertzel results from the corresponding channel.
   -- These should be the larges value of all goertzel results. 
   type   g2_array is array (0 to (FREQUENCIES-1)) of real;
   signal g2_results : g2_array := (others => 0.0);

   signal d1, d2, c : real := 0.0;

   -- timestamping
   signal timestamp_s     : timestamp_type;  -- The global timestamp
   signal timestamp_stm_s : integer := 0;    -- The timestamp read by the STM

   -- Signal generation for testbench

   -- Amplitude of signal for each channel
   type amplitude_array is array (0 to (CHANNELS - 1)) of real;
   constant AMPLITUDE : amplitude_array := (
      2.0**7,
      2.0**8,
      2.0**7,
      others => 0.0);

   constant FSAMPLE : real := 100000.0;  -- Sample frequency in Hertz.
                                         -- The sampling frequency in the
                                         -- simulation is higher to speed up the
                                         -- simulation. This value is used for
                                         -- calculation of coefficients only. 

   -- Signal frequency of each channel
   type frequency_array is array (0 to (CHANNELS - 1)) of real;
   constant FSIGNAL : frequency_array := (
      23625.0,
      24375.0,
      16425.0,
      others => 0.0);

   -- Output file
   type IntegerFileType is file of integer;
   
begin  -- tb

   -- Clock generation: 50 MHz
   clk <= not clk after 10 ns;

   -- Connect the busses
   bus_to_stm.data <= bus_to_stm_from_timestamp.data or bus_to_stm_from_bram.data;

   -- The Block RAM
   reg_file_bram_double_buffered_1 : reg_file_bram_double_buffered
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         bus_o       => bus_to_stm_from_bram,
         bus_i       => bus_i_dummy,
         bram_data_i => data_to_bram,
         bram_data_o => data_from_bram,
         bram_addr_i => addr_to_bram,
         bram_we_p   => we_to_bram,
         irq_o       => irq_s,
         ack_i       => ack_s,
         ready_i     => ready_s,
         enable_o    => open,
         bank_x_o    => bank_x_s,
         bank_y_o    => bank_y_s,
         clk         => clk);

   -- The Pipeline
   goertzel_pipelined_v2_1 : goertzel_pipelined_v2
      generic map (
         FREQUENCIES => FREQUENCIES,
         CHANNELS    => CHANNELS,
         SAMPLES     => SAMPLES,
         Q           => Q)
      port map (
         start_p     => start_s,
         bram_addr_p => addr_to_bram,
         bram_data_i => data_from_bram,
         bram_data_o => data_to_bram,
         bram_we_p   => we_to_bram,
         ready_p     => ready_s,
         enable_p    => '0',
         coefs_p     => coefs,
         inputs_p    => inputs,
         clk         => clk);

   -- Take a timestamp whenever the goertzel pipeline finished a set of values
   -- and switches the bnak. 
   timestamp_taker_1 : timestamp_taker
      generic map (
         BASE_ADDRESS => BASE_ADDRESS_TIMESTAMP)
      port map (
         timestamp_i_p => timestamp_s,
         trigger_i_p   => ready_s,
         bank_x_i_p    => bank_x_s,
         bank_y_i_p    => bank_y_s,
         bus_o         => bus_to_stm_from_timestamp,
         bus_i         => bus_i_dummy,
         clk           => clk);

   -- generate a timestamp
   timestamp_generator_1 : timestamp_generator
      port map (
         timestamp_o_p => timestamp_s,
         clk           => clk);

   -- Simulate a signal source for each channel.
   sources : for channel in 0 to (CHANNELS-1) generate
      s_sine : entity work.source_sine
         generic map (
            DATA_WIDTH         => INPUT_WIDTH,
            AMPLITUDE          => AMPLITUDE(channel),
            SIGNAL_FREQUENCY   => FSIGNAL(channel),
            SAMPLING_FREQUENCY => FSAMPLE)
         port map (
            start_i  => start_s,
            signal_o => inputs(channel));
   end generate sources;

   -- Simulate the ADCs that deliver new samples for each channel. 
   adcs : process
   begin  -- process adcs

      -- set goertzel coefficients, one for each frequency
      for frequency in 0 to (FREQUENCIES-1) loop
         coefs(frequency) <= to_signed(
            integer(2.0 * cos(MATH_2_PI * FSIGNAL(frequency) / FSAMPLE) * 2.0**Q),
            coefs(frequency)'length);
      end loop;  -- frequency

      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';

      -- Start a new conversion every x clock ticks
      -- This is more often than in real hardware.
      -- It does not make sense to wait thousands of clock cycles until a new
      -- ADC result is ready. 

      for ii in 0 to 20000 loop
         
         start_s <= '1';
         wait until clk = '0';
         start_s <= '0';

         -- The minimum time to process all channels and all frequencies must
         -- be met.
         for pp in 0 to (4 * (CHANNELS * FREQUENCIES + 1)) loop
            wait until clk = '0';
         end loop;  -- pp
      end loop;  -- ii

      -- do not repeat
      wait;
   end process adcs;

   -- Always acknowledge new data from the Goertzel Algorithm
   -- and calculate the magnitude of the goertzel values in floating point.
   -- This simulates what will be done in the STM32 processor. 
   AckGen : process
      variable d1_v, d2_v, c_v : real                          := 0.0;
      variable gv0_v, gv1_v    : std_logic_vector(15 downto 0) := (others => '0');
      variable ii              : integer                       := 0;
      variable timestamp_v     : integer;
      file data_out            : IntegerFileType open write_mode is "goertzel.bin";
   begin  -- process AckGen
      wait until irq_s = '1';

      -- STM delay
      wait for 100 us;

      ii := 0;                          -- iterate over all frequencies and
                                        -- channels. The memory layout is
                                        -- linear. 
      for fr in 0 to FREQUENCIES-1 loop
         for ch in 0 to CHANNELS-1 loop

            -- read data from bus and display result as a signal
            -- This will happen in the STM
            readWord(addr => BASE_ADDRESS + 0 + (ii * 2), bus_i => bus_i_dummy, clk => clk);
            gv0_v := bus_to_stm.data;

            readWord(addr => BASE_ADDRESS + 1 + (ii * 2), bus_i => bus_i_dummy, clk => clk);
            gv1_v := bus_to_stm.data;

            -- Write the raw bits read from block RAM to a file.
            -- This can be used to check the C++ code.
            -- Interpret data with
            -- $ hexdump -v -e '2/4 "%08x "' -e ' 2/4 " %6d"  "\n"'  goertzel.bin
            write(data_out, to_integer(signed(gv0_v)));
            write(data_out, to_integer(signed(gv1_v)));

            -- convert to real
            d1_v := real(to_integer(signed(gv0_v))) / 2.0**(Q-2);
            d2_v := real(to_integer(signed(gv1_v))) / 2.0**(Q-2);
            c_v  := real(to_integer(coefs(fr))) / 2.0**Q;

            g_results(ii) <= d1_v**2 + d2_v**2 - (d1_v * d2_v * c_v);

            -- Assign variables to signals so the data can be plotted in
            -- gtkwave. Variables cannot be plotted. 
            d1  <= d1_v;
            d2  <= d2_v;
            c   <= c_v;
            gv0 <= gv0_v;
            gv1 <= gv1_v;

            -- wait at least one clock cycle
            wait until rising_edge(clk);
            ii := ii + 1;
         end loop;  -- ch
      end loop;  -- fr

      -- Read timestamp
      timestamp_v := 0;
      for ii in 0 to 2 loop
         readWord(addr => BASE_ADDRESS_TIMESTAMP + ii, bus_i => bus_i_dummy, clk => clk);
         timestamp_v := timestamp_v + to_integer(unsigned(bus_to_stm.data)) * 2**(16 * ii);
      end loop;  -- ii
      timestamp_stm_s <= timestamp_v;


      -- acknowledge that all results were read
      ack_s <= '1';
      wait for 100 ns;
      ack_s <= '0';
   end process AckGen;

   -- purpose: Copy all goertzel values for each channel with the matching frequency
   -- type   : combinational
   -- inputs : g_results
   -- outputs: g2_results
   copyVals : process (g_results)
   begin  -- process copyVals
      for fr in 0 to (FREQUENCIES-1) loop
         g2_results(fr) <= g_results((fr * CHANNELS) + fr);
      end loop;  -- ch
   end process copyVals;

end tb;
