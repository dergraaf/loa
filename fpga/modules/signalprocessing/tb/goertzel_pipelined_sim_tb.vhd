-------------------------------------------------------------------------------
-- Title      : Simulation of Pipelined Goertzel Algorithm with Block RAM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipelined_sim.vhd
-- Author     : 
-- Company    : 
-- Created    : 2012-04-28
-- Last update: 2012-05-02
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

entity goertzel_pipelined_sim_tb is

end goertzel_pipelined_sim_tb;

architecture tb of goertzel_pipelined_sim_tb is

-- signals

   signal clk : std_logic := '0';

   constant FREQUENCIES : natural := 2;
   constant CHANNELS    : natural := 3;
   constant SAMPLES     : natural := 5;
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

   signal start_s : std_logic := '0';

   signal ready_s : std_logic;          -- Goertzel result ready, switch RAM bank.
   
   signal coefs  : goertzel_coefs_type(FREQUENCIES-1 downto 0) := (others => (others => '0'));
   signal inputs : goertzel_inputs_type(CHANNELS-1 downto 0)   := (others => (others => '0'));

   
   -- signal generation for testbench
   signal PHASE0 : real := 0.1;
   signal PHASE1 : real := 0.2;
   signal PHASE2 : real := 0.3;

   constant SCALE  : real := 2.0**7 - 10.0;
   constant OFFSET : real := 2.0**13;

   constant FSAMPLE  : real := 75000.0;  -- Sample Frequency in Hertz
   constant FSIGNAL0 : real := 16750.0;  -- Signal Frequency in Hertz
   constant FSIGNAL1 : real := 18700.0;  -- Signal Frequency in Hertz
   constant FSIGNAL2 : real := 25600.0;  -- Signal Frequency in Hertz

   signal PHASE_INCREMENT0 : real := 2.0 * 3.1415 * FSIGNAL0 / FSAMPLE;
   signal PHASE_INCREMENT1 : real := 2.0 * 3.1415 * FSIGNAL1 / FSAMPLE;
   signal PHASE_INCREMENT2 : real := 2.0 * 3.1415 * FSIGNAL2 / FSAMPLE;

   
begin  -- tb

   -- clock generation
   clk <= not clk after 20 ns;

   reg_file_bram_double_buffered_1 : reg_file_bram_double_buffered
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         bus_o       => open,
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

   process
   begin  -- process

      for ii in 0 to FREQUENCIES-1 loop
         coefs(ii) <= to_signed(ii*16 + ii + 1, 18);
      end loop;  -- ii

      wait until clk = '0';
      wait until clk = '0';
      wait until clk = '0';

      for ii in 0 to 2000 loop
         
         start_s <= '1';
         wait until clk = '0';
         start_s <= '0';

         for pp in 0 to 100 loop
            wait until clk = '0';
         end loop;  -- pp
           end loop;  -- ii

      wait for 10 ms;
   end process;

   WaveGen_Proc : process
   begin
      for n in 0 to 10000 loop
         wait until start_s = '1';
         -- signed values from three ADC channels
         inputs(0) <= to_signed(integer(SCALE * sin(PHASE0)), INPUT_WIDTH);
         inputs(1) <= to_signed(integer(SCALE * sin(PHASE1)), INPUT_WIDTH);
         inputs(2) <= to_signed(integer(SCALE * sin(PHASE2)), INPUT_WIDTH);

         PHASE0 <= PHASE0 + PHASE_INCREMENT0;
         PHASE1 <= PHASE1 + PHASE_INCREMENT1;
         PHASE2 <= PHASE2 + PHASE_INCREMENT2;
      end loop;

      -- end, do not repeat pattern
      wait for 10 ms;
   end process WaveGen_Proc;


   AckGen: process
   begin  -- process AckGen
      wait for 40 us;
      ack_s <= '1';
      wait for 100 ns;
      ack_s <= '0';

      wait until false;
      
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
