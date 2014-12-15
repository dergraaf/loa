-------------------------------------------------------------------------------
-- Title      : 8x1 Pixel Controller
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-15
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

entity ws2812_8x1 is
  port (
    pixels     : in  ws2812_8x1_in_type;
    ws2812_in  : out ws2812_in_type;
    ws2812_out : in  ws2812_out_type;
    clk        : in  std_logic);
end ws2812_8x1;

architecture rtl of ws2812_8x1 is

  type ws2812_8x1_states is (idle, write1, write2, write3, finish1, finish2);

  type ws2812_8x1_state_type is record
    o         : ws2812_in_type;
    pixel_cnt : integer range 0 to 7;
    state     : ws2812_8x1_states;
  end record;

  signal r, rin : ws2812_8x1_state_type := (
    o         => (d => (others => '0'), we => '0', send_reset => '0'),
    pixel_cnt => 0,
    state     => idle);

begin  -- ws2812_8x1

  ws2812_in <= r.o;

  comb : process(pixels, r, ws2812_out)
    variable v : ws2812_8x1_state_type;
  begin
    v := r;

    case v.state is
      when idle =>
        -- busy := '0';

        if pixels.refresh = '1' then
          v.state     := write1;
          v.pixel_cnt := 7;
          --busy    := '1';
        end if;

        -------------------------------------------------------------------------
        -- Write loop sequence
        -------------------------------------------------------------------------  
      when write1 =>
        v.o.d   := pixels.pixel(v.pixel_cnt);
        v.o.we  := '1';
        v.state := write2;
        
      when write2 =>
        v.o.we  := '0';
        v.state := write3;
        
      when write3 =>
        if ws2812_out.busy = '0' then
          if v.pixel_cnt = 0 then
            v.state        := finish1;
            v.o.send_reset := '1';
          else
            v.pixel_cnt := v.pixel_cnt - 1;
            v.state     := write1;
          end if;
        end if;

        -----------------------------------------------------------------------
        -- Send a reset seqence to update transfered data to output registers
        -- of the LEDs
        -----------------------------------------------------------------------
      when finish1 =>
        v.o.send_reset := '0';
        v.state        := finish2;
      when finish2 =>
        if ws2812_out.busy = '0' then
          v.state := idle;
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
