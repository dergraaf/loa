-------------------------------------------------------------------------------
-- Title      : Goertzel Algorithm pipelined with BRAM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipelined_v2.vhd
-- Author     : strongly-typed
-- Created    : 2012-04-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:
--
-- ToDos      : The throughput can be increased by:
--               i) Reduce steps in pipeline
--              ii) Do not wait to put a new value into the pipeline until the
--                  last result was processed. Alternate reading and writing to
--                  the BRAM. Need to store the address of the the data
--                  currently in progress. 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.signalprocessing_pkg.all;

entity goertzel_pipelined_v2 is
   
   generic (
      FREQUENCIES  : positive := 5;
      CHANNELS     : positive := 12;
      SAMPLES      : positive := 250;
      Q            : positive := 13);

   port (
      start_p     : in  std_logic;
      bram_addr_p : out std_logic_vector(7 downto 0);
      bram_data_i : in  std_logic_vector(35 downto 0);
      bram_data_o : out std_logic_vector(35 downto 0);
      bram_we_p   : out std_logic;
      ready_p     : out std_logic;
      enable_p    : in  std_logic;
      coefs_p     : in  goertzel_coefs_type(FREQUENCIES-1 downto 0);
      inputs_p    : in  goertzel_inputs_type(CHANNELS-1 downto 0);
      clk         : in  std_logic);

end entity goertzel_pipelined_v2;

architecture structural of goertzel_pipelined_v2 is

   signal start_s : std_logic := '0';


   -- select signals of muxes
   signal mux_delay1_s : std_logic                            := '0';
   signal mux_delay2_s : std_logic                            := '0';
   signal mux_coef_s   : natural range FREQUENCIES-1 downto 0 := 0;
   signal mux_input_s  : natural range CHANNELS-1 downto 0    := 0;

   -- outputs of the muxes
   signal muxed_delay1_s : goertzel_data_type  := (others => '0');
   signal muxed_delay2_s : goertzel_data_type  := (others => '0');
   signal muxed_coef_s   : goertzel_coef_type  := (others => '0');
   signal muxed_input_s  : goertzel_input_type := (others => '0');

   -- inter-instance routing
   signal bram_data_i_s             : goertzel_result_type := (others => (others => '0'));
   signal goertzel_result_to_bram_s : goertzel_result_type := (others => (others => '0'));
   signal pipeline_input_s          : goertzel_result_type := (others => (others => '0'));
   
begin  -- architecture structural

   start_s <= start_p;

   pipeline_input_s(0) <= muxed_delay1_s;
   pipeline_input_s(1) <= muxed_delay2_s;

   -- map generic std_logic_vector(35 downto 0) form bram
   -- to strongly-tyed goertzel_result_type of pipeline
   -- |35 ---- 18||17 ------ 0| BRAM
   -- |--delay2--||--delay1--|| pipeline
   bram_data_i_s(0) <= signed(bram_data_i(17 downto 0));
   bram_data_i_s(1) <= signed(bram_data_i(35 downto 18));

   -- from pipeline to bram
   bram_data_o <= std_logic_vector(goertzel_result_to_bram_s(1)) & std_logic_vector(goertzel_result_to_bram_s(0));

   -- muxes to multiplex one of the channels to the pipeline
   goertzel_muxes_1 : entity work.goertzel_muxes
      generic map (
         CHANNELS    => CHANNELS,
         FREQUENCIES => FREQUENCIES)
      port map (
         mux_delay1_p => mux_delay1_s,
         mux_delay2_p => mux_delay2_s,
         mux_coef     => mux_coef_s,
         mux_input    => mux_input_s,

         bram_data => bram_data_i_s,
         coefs_p   => coefs_p,
         inputs_p  => inputs_p,

         delay1_p => muxed_delay1_s,
         delay2_p => muxed_delay2_s,
         coef_p   => muxed_coef_s,
         input_p  => muxed_input_s);

   -- control the pipeline
   goertzel_control_unit_1 : entity work.goertzel_control_unit
      generic map (
         SAMPLES     => SAMPLES,
         FREQUENCIES => FREQUENCIES,
         CHANNELS    => CHANNELS)
      port map (
         start_p => start_s,
         ready_p => ready_p,

         -- output to the bram
         bram_addr_p => bram_addr_p,
         bram_we_p   => bram_we_p,

         -- outputs to the mux
         mux_delay1_p => mux_delay1_s,
         mux_delay2_p => mux_delay2_s,
         mux_coef_p   => mux_coef_s,
         mux_input_p  => mux_input_s,
         clk          => clk);

   -- the actual pipiline working on one frequency and on one channel
   goertzel_pipeline_1 : entity work.goertzel_pipeline
      generic map (
         Q => Q)
      port map (
         coef_p   => muxed_coef_s,
         input_p  => muxed_input_s,
         delay_p  => pipeline_input_s,
         result_p => goertzel_result_to_bram_s,
         clk      => clk);

end architecture structural;
