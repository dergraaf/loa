-------------------------------------------------------------------------------
-- Title      : Simulation of Pipelined Goertzel Algorithm with Block RAM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipelined_sim.vhd
-- Author     : 
-- Company    : 
-- Created    : 2012-04-28
-- Last update: 2012-05-04
-- Platform   : 
-- Standard   : VHDL'87
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
   constant CHANNELS    : natural := 3;
   constant SAMPLES     : natural := 250;
   constant Q           : natural := 13;

   constant BASE_ADDRESS : natural := 16#0000#;

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

   signal bus_to_stm : busdevice_out_type := (data => (others => '0'));

   signal start_s : std_logic := '0';

   signal ready_s : std_logic;  -- Goertzel result ready, switch RAM bank.

   signal coefs  : goertzel_coefs_type(FREQUENCIES-1 downto 0) := (others => (others => '0'));
   signal inputs : goertzel_inputs_type(CHANNELS-1 downto 0)   := (others => (others => '0'));

   -- results as signals
   signal gv0, gv1 : std_logic_vector(15 downto 0) := (others => '0');  -- value read from register

   type g_array is array (0 to (FREQUENCIES * CHANNELS) - 1) of real;
   signal g_results : g_array := (others => 0.0);

   -- signal generation for testbench
   constant AMPLITUDE0 : real := 2.0**3 - 10.0;
   constant AMPLITUDE1 : real := 2.0**3 - 10.0;
   constant AMPLITUDE2 : real := 2.0**3 - 10.0;

   constant FSAMPLE  : real := 75000.0;  -- Sample Frequency in Hertz
   constant FSIGNAL0 : real := 16750.0;  -- Signal Frequency in Hertz
   constant FSIGNAL1 : real := 16800.0;  -- Signal Frequency in Hertz
   constant FSIGNAL2 : real := 25600.0;  -- Signal Frequency in Hertz

   
begin  -- tb

   -- clock generation
   clk <= not clk after 20 ns;

   reg_file_bram_double_buffered_1 : reg_file_bram_double_buffered
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         bus_o       => bus_to_stm,
         bus_i       => bus_i_dummy,
         bram_data_i => data_to_bram,
         bram_data_o => data_from_bram,
         bram_addr_i => addr_to_bram,
         bram_we_p   => we_to_bram,
         irq_o       => irq_s,
         ack_i       => ack_s,
         ready_i     => ready_s,
         enable_o    => open,
         clk         => clk);

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

   -- Simulate three Channles of input data
   source_sine_0 : entity work.source_sine
      generic map (
         DATA_WIDTH         => INPUT_WIDTH,
         AMPLITUDE          => AMPLITUDE0,
         SIGNAL_FREQUENCY   => FSIGNAL0,
         SAMPLING_FREQUENCY => FSAMPLE)
      port map (
         start_i  => start_s,
         signal_o => inputs(0));

   source_sine_1 : entity work.source_sine
      generic map (
         DATA_WIDTH         => INPUT_WIDTH,
         AMPLITUDE          => AMPLITUDE1,
         SIGNAL_FREQUENCY   => FSIGNAL1,
         SAMPLING_FREQUENCY => FSAMPLE)
      port map (
         start_i  => start_s,
         signal_o => inputs(1));

   source_sine_2 : entity work.source_sine
      generic map (
         DATA_WIDTH         => INPUT_WIDTH,
         AMPLITUDE          => AMPLITUDE2,
         SIGNAL_FREQUENCY   => FSIGNAL2,
         SAMPLING_FREQUENCY => FSAMPLE)
      port map (
         start_i  => start_s,
         signal_o => inputs(2));

   
   process
   begin  -- process

      -- set goertzel coefficients
      coefs(0) <= to_signed(integer(2.0 * cos(MATH_2_PI * FSIGNAL0 / FSAMPLE) * 2.0**Q), coefs(0)'length);
      coefs(1) <= to_signed(integer(2.0 * cos(MATH_2_PI * FSIGNAL1 / FSAMPLE) * 2.0**Q), coefs(0)'length);
      --  coefs(2) <= to_signed(integer(2.0 * cos(MATH_2_PI * FSIGNAL1 / FSAMPLE) * 2.0**Q), coefs(0)'length);

      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';

      -- Start a new conversion every 50 clock ticks
      -- This is more often than in real hardware.
      -- It does not make sens to wait thousands of clock cycles until a new
      -- ADC result is ready. 

      for ii in 0 to 2000 loop
         
         start_s <= '1';
         wait until clk = '0';
         start_s <= '0';

         for pp in 0 to 30 loop
            wait until clk = '0';
         end loop;  -- pp
      end loop;  -- ii

      wait for 10 ms;
   end process;


   process (clk) is
   begin  -- process
      if rising_edge(clk) then          -- rising clock edge 

      end if;
   end process;

   -- Always acknowledge new data from the Goertzel Algorithm
   AckGen : process
      variable d1, d2, c : real    := 0.0;
      variable ii        : integer := 0;
   begin  -- process AckGen
      wait until irq_s = '1';
      wait for 1 us;

      ii := 0;
      for fr in 0 to FREQUENCIES-1 loop
         for ch in 0 to CHANNELS-1 loop

            -- read data from bus and display result as a signal
            -- This will happen in the STM
            readWord(addr => BASE_ADDRESS + 0 + (ii * 2), bus_i => bus_i_dummy, clk => clk);
            gv0 <= bus_to_stm.data;

            readWord(addr => BASE_ADDRESS + 1 + (ii * 2), bus_i => bus_i_dummy, clk => clk);
            gv1 <= bus_to_stm.data;

            -- convert to real
            d1 := real(to_integer(unsigned(gv0))) / 2.0**(Q-2);
            d2 := real(to_integer(unsigned(gv1))) / 2.0**(Q-2);
            c  := real(to_integer(coefs(fr))) / 2.0**Q;

            g_results(ii) <= d1**2 + d2**2 - (d1 * d2 * c);

            -- wait at least one clock cycle
            wait until rising_edge(clk);
            ii := ii + 1;
         end loop;  -- ch
      end loop;  -- fr

      -- acknowlede that all results were read
      ack_s <= '1';
      wait for 100 ns;
      ack_s <= '0';
   end process AckGen;


   --begin  -- process GoertzelCheck_proc
   --   wait until done_s = '1';

   --   -- new values are available in the result registers
   --   -- convert results from Q-format to real
   --   for ch in 0 to CHANNELS-1 loop
   --      for fr in 0 to FREQUENCIES-1 loop
   --         d1 := real(to_integer(results_s(ch, fr)(0))) / 2.0**(Q-2);
   --         d2 := real(to_integer(results_s(ch, fr)(1))) / 2.0**(Q-2);
   --         c  := real(to_integer(coefs(fr))) / 2.0**Q;

   --         -- calculate goertzel value
   --         goertzel_values_s(ch, fr) <= d1**2 + d2**2 - (d2 * d1 * c);
   --      end loop;  -- fr
   --   end loop;  -- ch
   --end process GoertzelCheck_proc;
   -- signal generation for testbench

end tb;
