-------------------------------------------------------------------------------
-- Title      : HDLC async Encoder
-------------------------------------------------------------------------------
-- Author     : Carl Treudler (cjt@users.sourceforge.net)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-- Encode 8-Bit input + frame boundary marker to 8 bit HDLC Async framing
-- 
-- Frame-seperator is encoded as 0x100.
--
-- 0x000 to 0x007C -> 0x00 to 0x7C
-- 0x07f to 0x0ff  -> 0x7f to 0xff
-- 0x1XX           -> 0x7e (Frame boundary marker) 
-- 0x07E           -> 0x7D, 0x5E
-- 0x07D           -> 0x7D, 0x5D
--
-- Input port can't take in data while it outputs an escape sequence!
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2013, Carl Treudler
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
use work.hdlc_pkg.all;

-------------------------------------------------------------------------------

entity hdlc_enc is
  port(
    din_p  : in  hdlc_enc_in_type;
    dout_p : out hdlc_enc_out_type;
    busy_p : out std_logic;
    clk    : in  std_logic
    );

end hdlc_enc;

-------------------------------------------------------------------------------

architecture behavioural of hdlc_enc is
  type hdlc_enc_state_type is (
    NOM,                                -- previous char was nominal 
    ESC                                 -- previous char was an escape
    );

  type hdlc_enc_type is record
    state     : hdlc_enc_state_type;
    strobe    : std_logic;
    next_char : std_logic_vector(7 downto 0);
    dout      : std_logic_vector(7 downto 0);
    busy      : std_logic;
  end record;

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : hdlc_enc_type := (state => NOM, strobe => '0', next_char => (others => '0'), dout => (others => '0'), busy => '0');

-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------
-- None here. If any: in package

begin  -- architecture behavourial

  ----------------------------------------------------------------------------
  -- Connections between ports and signals
  ----------------------------------------------------------------------------
  dout_p.data   <= r.dout;
  dout_p.enable <= r.strobe;

  busy_p <= r.busy;
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
  comb_proc : process(din_p, r)
    variable v : hdlc_enc_type;
  begin
    v        := r;
    v.strobe := '0';
    v.busy   := '0';
    case r.state is
      when NOM =>
        if din_p.enable = '1' then
          if din_p.data(8) = '1' then
            v.dout   := x"7e";
            v.strobe := '1';
          elsif (din_p.data(7 downto 0) = x"7e") or (din_p.data(7 downto 0) = x"7d") then
            v.dout      := x"7d";
            v.next_char := din_p.data(7 downto 6) & not din_p.data(5) & din_p.data(4 downto 0);
            v.strobe    := '1';
            v.state     := ESC;
            v.busy      := '1';
          else
            v.dout   := din_p.data(7 downto 0);
            v.strobe := '1';
          end if;
        end if;
      when ESC =>
        v.strobe := '1';
        v.dout   := v.next_char;
        v.state  := NOM;
    end case;

    rin <= v;
  end process comb_proc;

-----------------------------------------------------------------------------
-- Component instantiations
-----------------------------------------------------------------------------
-- None.

end behavioural;
