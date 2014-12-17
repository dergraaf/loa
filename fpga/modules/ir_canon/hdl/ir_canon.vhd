-------------------------------------------------------------------------------
-- Title      : IR Remote Shutter release for Canon DSLR
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-16
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
use work.ir_canon_pkg.all;
use work.ir_canon_cfg_pkg.all;

entity ir_canon is
  port (
    ir_canon_in  : in  ir_canon_in_type;
    ir_canon_out : out ir_canon_out_type;
    clk          : in  std_logic
    );
end ir_canon;

architecture rtl of ir_canon is

  type ir_canon_states is (idle, carrier1, carrier2, carrier3, gap, hold_off);

  type ir_canon_state_type is record
    timer       : integer range 0 to 25000000;
    carrier_cnt : integer range 0 to 15;
    burst_cnt   : integer range 0 to 1;
    o           : ir_canon_out_type;
    state       : ir_canon_states;
  end record;

  signal r, rin : ir_canon_state_type := (
    timer       => 0,
    burst_cnt   => 0,
    carrier_cnt => 0,
    o           => (ired => '0', busy => '1'),
    state       => idle);

begin  -- ir_canon

  ir_canon_out <= r.o;

  comb : process(ir_canon_in, r)
    variable v : ir_canon_state_type;
  begin
    v := r;

    case v.state is
      when idle =>
        v.o.busy := '0';

        if ir_canon_in.trigger = '1' then
          v.burst_cnt := 0;
          v.state     := carrier1;
          v.o.busy    := '1';
        end if;

        -------------------------------------------------------------------------
        -- Burst loop sequence
        -------------------------------------------------------------------------  
      when carrier1 =>
        v.timer       := carrier_cycles;
        v.carrier_cnt := 15;
        v.state       := carrier2;

      when carrier2 =>
        v.o.ired := '1';
        if v.timer = 0 then
          v.state := carrier3;
          v.timer := carrier_cycles;
        else
          v.timer := v.timer - 1;
        end if;
        
      when carrier3 =>
        v.o.ired := '0';
        if v.timer = 0 then
          if v.carrier_cnt = 0 then
            if v.burst_cnt = 0 then
              v.state     := gap;
              v.timer     := gap_cycles;
              v.burst_cnt := 1;         -- increment not yet needed
            else
              v.timer := hold_off_cycles;
              v.state := hold_off;
            end if;
          else
            v.state       := carrier2;
            v.timer       := carrier_cycles;
            v.carrier_cnt := v.carrier_cnt - 1;
          end if;
        else
          v.timer := v.timer - 1;
        end if;
        
      when gap =>
        if v.timer = 0 then
          v.state := carrier1;
        else
          v.timer := v.timer - 1;
        end if;

      when hold_off =>
        if v.timer = 0 then
          v.state := idle;
        else
          v.timer := v.timer - 1;
        end if;
        
      when others => null;
    end case;
    rin <= v;
  end process comb;

  seq : process (clk)
  begin  -- process seq
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process seq;

end rtl;
