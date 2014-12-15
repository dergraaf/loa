-------------------------------------------------------------------------------
-- Title      : Onewire Master
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Description: This is an Onewire Master, intended for use with dedicated
--              protocol FSMs.
--
--              Timing constants are defined in onwire_cfg_pkg.vhd
--              
-------------------------------------------------------------------------------
-- Created    : 2014-12-13
-------------------------------------------------------------------------------
-- Copyright (c) 2014, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.onewire_pkg.all;
use work.onewire_cfg_pkg.all;

entity onewire is
  
  port (
    onewire_in      : in  onewire_in_type;
    onewire_out     : out onewire_out_type;
    onewire_bus_in  : in  onewire_bus_in_type;
    onewire_bus_out : out onewire_bus_out_type;
    clk             : in  std_logic);

end onewire;

architecture rtl of onewire is

  type onewire_states is (idle, reset1, reset2, reset3, write1, write2, write3, read1, read2, read3, read4);

  type onewire_state_type is record
    timer   : integer range 0 to 25000;
    bus_o   : onewire_bus_out_type;
    o       : onewire_out_type;
    sr      : std_logic_vector(7 downto 0);
    bit_cnt : integer range 0 to 7;
    sync    : std_logic_vector(1 downto 0);
    state   : onewire_states;
  end record;

  signal r, rin : onewire_state_type := (
    timer   => 0,
    bus_o   => (d => '0', en_driver => '0'),
    o       => (d => (others => '0'), busy => '1', err => '0'),
    sr      => (others => '0'),
    bit_cnt => 0,
    sync    => "11",
    state   => idle);

begin  -- onewire

  onewire_bus_out <= r.bus_o;
  onewire_out     <= r.o;

  comb : process(onewire_bus_in, onewire_in, r)
    variable v          : onewire_state_type;
    variable bus_d_sync : std_logic := '1';
  begin
    v          := r;
    v.bus_o.d  := '0';                  -- not used, devices don't used
                                        -- parasitic power (yet!).
    bus_d_sync := v.sync(1);
    v.sync(1)  := v.sync(0);
    v.sync(0)  := onewire_bus_in.d;

    case v.state is
      when idle =>
        v.o.busy := '0';
        if onewire_in.reset_bus = '1' then
          v.state  := reset1;
          v.timer  := bus_reset_cycles;
          v.o.busy := '1';
        end if;

        if onewire_in.we = '1' then
          v.sr      := onewire_in.d;
          v.bit_cnt := 0;
          v.state   := write1;
          v.o.busy  := '1';
        end if;

        if onewire_in.re = '1' then
          v.state   := read1;
          v.bit_cnt := 0;
          v.o.busy  := '1';
        end if;

        -----------------------------------------------------------------------
        -- reset sequence
        -- samples response from bus
        -----------------------------------------------------------------------
      when reset1 =>
        v.bus_o.en_driver := '1';
        v.timer           := v.timer - 1;
        if v.timer = 0 then
          v.bus_o.en_driver := '0';
          v.timer           := bus_reset_wait_for_response;
          v.state           := reset2;
        end if;

      when reset2 =>
        v.timer := v.timer - 1;
        if v.timer = 0 then
          v.o.err := bus_d_sync;
          v.timer := bus_reset_cycles;
          v.state := reset3;
        end if;

      when reset3 =>
        v.timer := v.timer - 1;
        if v.timer = 0 then
          v.state := idle;
        end if;


        -------------------------------------------------------------------------
        -- Write loop sequence
        -- lsb first
        -------------------------------------------------------------------------  
      when write1 =>
        if v.sr(0) = '0' then
          v.timer := bus_write_zero;
        else
          v.timer := bus_write_one;
        end if;

        v.state := write2;

      when write2 =>
        v.bus_o.en_driver := '1';
        if v.timer = 0 then
          if v.sr(0) = '0' then
            v.timer := bus_write_zero_gap;
          else
            v.timer := bus_write_one_gap;
          end if;
          v.state := write3;
        else
          v.timer := v.timer - 1;
        end if;
        
      when write3 =>
        v.bus_o.en_driver := '0';
        v.timer           := v.timer - 1;
        if v.timer = 0 then
          v.sr := "0" & v.sr(7 downto 1);
          if v.bit_cnt = 7 then
            v.state := idle;
          else
            v.state   := write1;
            v.bit_cnt := v.bit_cnt + 1;
          end if;

        end if;


        -----------------------------------------------------------------------
        -- Read loop Sequence
        -----------------------------------------------------------------------
      when read1 =>
        v.timer := bus_read_pulse;
        v.state := read2;
        
      when read2 =>
        v.bus_o.en_driver := '1';
        v.timer           := v.timer - 1;
        if v.timer = 0 then
          v.state := read3;
          v.timer := bus_read_delay;
        end if;

      when read3 =>
        v.bus_o.en_driver := '0';
        v.timer           := v.timer - 1;
        if v.timer = 0 then
          v.sr    := bus_d_sync & v.sr(7 downto 1);
          v.state := read4;
          v.timer := bus_read_gap;
        end if;
        
      when read4 =>
        v.timer := v.timer - 1;
        if v.timer = 0 then
          if v.bit_cnt = 7 then
            v.state := idle;

          else
            v.state   := read1;
            v.bit_cnt := v.bit_cnt + 1;
          end if;
        end if;

      when others => null;
    end case;
    v.o.d := v.sr;                      -- output register could be optimised
                                        -- away ...
    rin   <= v;
  end process comb;

  seq : process (clk)
  begin  -- process seq
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process seq;

end rtl;
