-------------------------------------------------------------------------------
-- Title      : DS18b20 Reader
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Description: Trigger by the "refresh" signal this ip-core requests a 
--              temperature reading from the connected DS18b20 sensor. 
--
--              Uses the skip rom command to avoid handling ROM-IDs of sensors.
--              Only a single sensor can be used.
--
-- DS18b20 Sequence is:
--  reset bus
--  skip rom (0xcc)
--  convert emperature (0x44)
--  read bytes - sensor active while 0 are read
--  reset bus
--  skip rom (0xcc)
--  "read scratchpad" (0xbe)
--  Rx Temperature LSB
--  Rx Temperature MSB
--  (drop the rest and idle)
--
-------------------------------------------------------------------------------
-- Created    : 2014-12-14
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

library work;
use work.onewire_pkg.all;
use work.ds18b20_pkg.all;

entity ds18b20 is

  port (
    ow_out      : in  onewire_out_type;
    ow_in       : out onewire_in_type;
    ds18b20_in  : in  ds18b20_in_type;
    ds18b20_out : out ds18b20_out_type;
    clk         : in  std_logic);

end ds18b20;



architecture behavioural of ds18b20 is

  type ds18b20_state_type is (idle,
                              reset1, reset2,
                              skip_rom1, skip_rom2,
                              conv_temp1, conv_temp2,
                              wait_for_conversion1, wait_for_conversion2, wait_for_conversion3,
                              reset3, reset4,
                              skip_rom3, skip_rom4,
                              read_sp1, read_sp2, read_sp3, read_sp4, read_sp5, read_sp6);

  type ds18b20_type is record
    state       : ds18b20_state_type;
    ow_in       : onewire_in_type;
    ds18b20_out : ds18b20_out_type;
    byte_cnt    : integer range 0 to 3;
  end record;


  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : ds18b20_type := (state       => IDLE,
                                   ow_in       => (d => (others => '0'), re => '0', we => '0', reset_bus => '0'),
                                   ds18b20_out => (value => (others => '0'), update => '0', err => '0'),
                                   byte_cnt    => 0);


begin  -- architecture behavourial

  ----------------------------------------------------------------------------
  -- Connections between ports and signals
  ----------------------------------------------------------------------------

  ds18b20_out <= r.ds18b20_out;
  ow_in       <= r.ow_in;

  ----------------------------------------------------------------------------
  -- Combinatorial part of FSM
  ----------------------------------------------------------------------------
  comb_proc : process(ds18b20_in, ow_out, r)
    variable v : ds18b20_type;
  begin
    v := r;

    case r.state is
      when idle =>
        if ds18b20_in.refresh = '1' then
          v.state           := reset1;
          v.ow_in.reset_bus := '1';
        end if;

      when reset1 =>
        v.ow_in.reset_bus := '0';
        v.state           := reset2;

      when reset2 =>
        if ow_out.busy = '0' then
          v.state    := skip_rom1;
          v.ow_in.d  := x"CC";
          v.ow_in.we := '1';
        end if;

      when skip_rom1 =>
        v.ow_in.we := '0';
        v.state    := skip_rom2;
        
      when skip_rom2 =>
        if ow_out.busy = '0' then
          v.state    := conv_temp1;
          v.ow_in.d  := x"44";
          v.ow_in.we := '1';
        end if;

      when conv_temp1 =>
        v.ow_in.we := '0';
        v.state    := conv_temp2;
        
      when conv_temp2 =>
        if ow_out.busy = '0' then
          v.state := wait_for_conversion1;
        end if;

      when wait_for_conversion1 =>
        v.ow_in.re := '1';
        v.state    := wait_for_conversion2;

      when wait_for_conversion2 =>
        v.ow_in.re := '0';
        v.state    := wait_for_conversion3;
        
      when wait_for_conversion3 =>
        if ow_out.busy = '0' then
          if ow_out.d = x"ff" then
            v.state           := reset3;
            v.ow_in.reset_bus := '1';
          else
            v.state := wait_for_conversion1;
          end if;
        end if;

      when reset3 =>
        v.ow_in.reset_bus := '0';
        v.state           := reset4;

      when reset4 =>
        if ow_out.busy = '0' then
          v.state    := skip_rom3;
          v.ow_in.d  := x"CC";
          v.ow_in.we := '1';
        end if;

      when skip_rom3 =>
        v.ow_in.we := '0';
        v.state    := skip_rom4;
        
      when skip_rom4 =>
        if ow_out.busy = '0' then
          v.state := read_sp1;
        end if;

      when read_sp1 =>
        v.ow_in.d  := x"be";
        v.ow_in.we := '1';
        v.byte_cnt := 0;
        v.state    := read_sp2;

      when read_sp2 =>
        v.ow_in.we := '0';
        v.state    := read_sp3;

      when read_sp3 =>
        if ow_out.busy = '0' then
          v.state := read_sp4;
        end if;

      when read_sp4 =>
        v.ow_in.re := '1';
        v.state    := read_sp5;

      when read_sp5 =>
        v.ow_in.re := '0';
        v.state    := read_sp6;
        
      when read_sp6 =>
        if ow_out.busy = '0' then
          if v.byte_cnt = 0 then
            v.ds18b20_out.value(7 downto 0) := ow_out.d;
            v.byte_cnt                      := v.byte_cnt + 1;
            v.state                         := read_sp4;
          elsif v.byte_cnt = 1 then
            v.ds18b20_out.value(15 downto 8) := ow_out.d;
            v.state                          := idle;
          end if;
        end if;

      when others =>
        v.state := IDLE;
    end case;

    rin <= v;
  end process comb_proc;

  ----------------------------------------------------------------------------
  -- Sequential part of finite state machine (FSM)
  ----------------------------------------------------------------------------
  seq_proc : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process seq_proc;


  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------
  -- None.
  
end behavioural;
