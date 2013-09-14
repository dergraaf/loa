-------------------------------------------------------------------------------
-- Title      : HDLC async Encoder
-------------------------------------------------------------------------------
-- Author     : Carl Treudler (cjt@users.sourceforge.net)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-- Decode 8-Bit HDLC Async framing int 8-Bit Data + Frame Delimiter
-- 
-- Frame-seperator is encoded as 0x100.
--
-- 0x00 to 0x7C  -> 0x000 to 0x007C
-- 0x7f to 0xff  -> 0x07f to 0x0ff
-- 0x7e          -> 0x1XX
-- 0x7D, 0x5E    -> 0x07E  
-- 0x7D, 0x5D    -> 0x07D
--
-- Input port can't take in data while it outputs an escape sequence!
--    TODO add a busy signal for the input.
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

entity hdlc_dec is

  port (
    din_p  : in  hdlc_dec_in_type;
    dout_p : out hdlc_dec_out_type;
    clk    : in  std_logic);

end hdlc_dec;
-------------------------------------------------------------------------------

architecture behavioural of hdlc_dec is
  type hdlc_dec_state_type is (
    NOM,                                -- previous char was nominal 
    ESC                                 -- previous char was an escape
    );

  type hdlc_dec_type is record
    state  : hdlc_dec_state_type;
    strobe : std_logic;
    dout   : std_logic_vector(8 downto 0);
  end record;

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : hdlc_dec_type := (state => NOM, strobe => '0', dout => (others => '0'));

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
    variable v : hdlc_dec_type;
  begin
    v        := r;
    v.strobe := '0';

    case r.state is
      when NOM =>
        if din_p.enable = '1' then
          if din_p.data = x"7e" then
            v.dout   := "1" & x"00";
            v.strobe := '1';
          elsif din_p.data = x"7d" then
            v.state := ESC;
          else
            v.dout   := "0" & din_p.data;
            v.strobe := '1';
          end if;
        end if;
      when ESC =>
        if din_p.enable = '1' then
          v.dout   := "0" & din_p.data(7 downto 6) & not din_p.data(5) & din_p.data(4 downto 0);
          v.strobe := '1';
          v.state  := NOM;
        end if;
    end case;

    rin <= v;
  end process comb_proc;

-----------------------------------------------------------------------------
-- Component instantiations
-----------------------------------------------------------------------------
-- None.

end behavioural;
