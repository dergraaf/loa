-------------------------------------------------------------------------------
-- Title      : Goertzel Pipelined Control Unit
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_control_unit.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-24
-- Last update: 2012-04-26
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Control Unit (a state machine) that controls the muxes and the
-- pipeline of the goertzel algorithm. 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.signalprocessing_pkg.all;

entity goertzel_control_unit is
   
   generic (
      SAMPLES     : positive := 250;
      FREQUENCIES : positive := 5;
      CHANNELS    : positive := 12);

   port (
      start_p      : in  std_logic;  -- start the FSM when new ADC values arrived
      ready_p      : out std_logic                    := '0';  -- inform STM about new data
      bram_addr_p  : out std_logic_vector(7 downto 0) := (others => '0');  -- address where to read/write
      bram_we_p    : out std_logic;     -- write to the Block RAM
      mux_delay1_p : out std_logic;     -- select delay1 from BRAM
      mux_delay2_p : out std_logic;     -- select delay2 from BRAM
      mux_coef_p   : out natural range FREQUENCIES-1 downto 0;
      mux_input_p  : out natural range CHANNELS-1 downto 0;
      clk          : in  std_logic);

end entity goertzel_control_unit;

architecture behavourial of goertzel_control_unit is

   type cu_state_type is (
      IDLE,                             -- do nothing, wait for start signal
      READ1,                            -- reads data from BRAM
      CALC1,                            -- first RTL
      CALC2,                            -- second RTL
      WRITE1                            -- write the result back to BRAM
      );

   type cu_type is record
      state      : cu_state_type;
      ready      : std_logic;
      mux_coef   : natural range FREQUENCIES-1 downto 0;
      mux_input  : natural range CHANNELS-1 downto 0;
      bram_addr  : unsigned(7 downto 0);
      bram_we    : std_logic;
      samples    : natural range SAMPLES-1 downto 0;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : cu_type := (state      => IDLE,
                               ready      => '0',
                               mux_coef   => 0,
                               mux_input  => 0,
                               bram_addr  => (others => '0'),
                               bram_we    => '0',
                               samples    => 0);


   ----------------------------------------------------------------------------
   -- Component declarations
   ----------------------------------------------------------------------------
   -- None here, if any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   ready_p      <= r.ready;
   mux_coef_p   <= r.mux_coef;
   mux_input_p  <= r.mux_input;
   bram_we_p    <= r.bram_we;
   bram_addr_p  <= std_logic_vector(r.bram_addr);

   ----------------------------------------------------------------------------
   -- Sequential part of finite state machine (FSM)
   ----------------------------------------------------------------------------
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   ----------------------------------------------------------------------------
   -- Combinatorial part of FSM
   ----------------------------------------------------------------------------
   comb_proc : process(r, r.bram_addr, r.mux_coef, r.mux_input, r.state,
                       start_p)
      variable v : cu_type;
      
   begin
      v := r;

      case r.state is
         when IDLE =>
            v.ready := '0';
            if (start_p = '1') then
               v.state := READ1;

               -- select coef and input
               v.bram_addr := (others => '0');
               v.mux_coef  := 0;
               v.mux_input := 0;
            -- bram_addr               
            end if;
         when READ1 =>
            v.state := CALC1;
         when CALC1 =>
            v.state := CALC2;
         when CALC2 =>
            v.state   := WRITE1;
            v.bram_we := '1';
         when WRITE1 =>
            v.state     := READ1;
            v.bram_we   := '0';
            -- Three nested loops:
            -- inner: channel
            --        frequency
            -- outer: sample
            v.bram_addr := r.bram_addr + 1;
            if r.mux_input = CHANNELS-1 then
               v.mux_input := 0;
               if r.mux_coef = FREQUENCIES-1 then
                  v.mux_coef := 0;
                  v.bram_addr := (others => '0');
                  if r.samples = SAMPLES-1 then
                     v.samples := 0;
                     v.state := IDLE;
                     v.ready := '1';
                  else
                     v.samples := r.samples + 1;
                  end if;
               else
                  v.mux_coef := r.mux_coef + 1;
               end if;
            else
               v.mux_input := r.mux_input + 1;
            end if;
         when others =>
            null;
      end case;

      rin <= v;
      
   end process comb_proc;

   -- For the first sample ignore the value in the BRAM  and overwrite it
   -- with zero. No special erase cycle is needed. At the end of the first
   -- sample the old data is overwritten in the BRAM. 
   mux_delay1_p <= '0' when (r.samples = 0) else '1';
   mux_delay2_p <= '0' when (r.samples = 0) else '1';

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- none

end architecture behavourial;
