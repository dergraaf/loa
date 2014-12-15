-------------------------------------------------------------------------------
-- Title      : WS2812 Controller
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Description: This is an WS2812 Master, it must be commanded to put out
--              single pixels and finished with a reset sequence. 
--
--              Timing constants are defined in ws2812_cfg_pkg.vhd
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
use work.ws2812_pkg.all;
use work.ws2812_cfg_pkg.all;

entity ws2812 is
  port (
    ws2812_in        : in  ws2812_in_type;
    ws2812_out       : out ws2812_out_type;
    ws2812_chain_out : out ws2812_chain_out_type;
    clk              : in  std_logic);
end ws2812;

architecture rtl of ws2812 is

  type ws2812_states is (idle, reset, write1, write2, write3);

  type ws2812_state_type is record
    timer     : integer range 0 to 3000;
    chain_out : ws2812_chain_out_type;
    o         : ws2812_out_type;
    sr        : std_logic_vector(23 downto 0);
    bit_cnt   : integer range 0 to 23;
    state     : ws2812_states;
  end record;

  signal r, rin : ws2812_state_type := (
    timer     => 0,
    chain_out => (d => '0'),
    o         => (busy => '1'),
    sr        => (others => '0'),
    bit_cnt   => 0,
    state     => idle);

begin  -- ws2812

  ws2812_chain_out <= r.chain_out;
  ws2812_out       <= r.o;

  comb : process(r, ws2812_in)
    variable v : ws2812_state_type;
  begin
    v := r;

    case v.state is
      when idle =>
        v.o.busy := '0';

        if ws2812_in.send_reset = '1' then
          v.state  := reset;
          v.timer  := reset_cycles;
          v.o.busy := '1';
        end if;

        if ws2812_in.we = '1' then
          v.sr      := ws2812_in.d;
          v.bit_cnt := 0;
          v.state   := write1;
          v.o.busy  := '1';
        end if;

        -----------------------------------------------------------------------
        -- Reset
        -----------------------------------------------------------------------
      when reset =>
        v.chain_out.d := '0';
        if v.timer = 0 then
          v.state := idle;
        else
          v.timer := v.timer - 1;
        end if;


        -------------------------------------------------------------------------
        -- Write loop sequence
        -------------------------------------------------------------------------  
      when write1 =>
        v.chain_out.d := '1';

        if v.sr(23) = '0' then
          v.timer := zero_th_cycles;
        else
          v.timer := one_th_cycles;
        end if;

        v.state := write2;

      when write2 =>
        if v.timer = 0 then
          if v.sr(23) = '0' then
            v.timer := zero_tl_cycles;
          else
            v.timer := one_tl_cycles;
          end if;
          v.state := write3;
        else
          v.timer := v.timer - 1;
        end if;
        
      when write3 =>
        v.chain_out.d := '0';
        v.timer       := v.timer - 1;
        if v.timer = 0 then
          v.sr := v.sr(22 downto 0) & '0';
          if v.bit_cnt = 23 then
            v.state := idle;
          else
            v.state   := write1;
            v.bit_cnt := v.bit_cnt + 1;
          end if;

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
