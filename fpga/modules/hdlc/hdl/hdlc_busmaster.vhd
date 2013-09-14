-------------------------------------------------------------------------------
-- Title      : Busmaster with HDLC Interface
-------------------------------------------------------------------------------
-- Author     : Carl Treudler (cjt@users.sourceforge.net)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-- Decode 8-Bit HDLC Async framing int 8-Bit Data + Frame Delimiter
--
-- Read access:
-- frame delimiter
-- cmd  - 0x10
-- addr -   ...  
-- crc 
--
-- frame delimiter
-- 0x11
-- data msb
-- data lsb
--
--
--
-- Write access:
-- frame delimiter
-- cmd  - 0x20
-- addr - ...
-- data 
-- crc
--
-- Write reply:
-- frame delimiter
-- 0x21
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
use work.hdlc_crc_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------

entity hdlc_busmaster is
  port(
    din_p  : in  hdlc_dec_out_type;
    dout_p : out hdlc_enc_in_type;
    bus_o  : out busmaster_out_type;
    bus_i  : in  busmaster_in_type;

    clk : in std_logic);

end hdlc_busmaster;
-------------------------------------------------------------------------------

architecture behavioural of hdlc_busmaster is
  type hdlc_busmaster_state_type is (IDLE,  -- idling, waiting for a frame delimiter to arrive
                                     RX_FRAME_CMD,       -- CMD Byte
                                     RX_FRAME_ADDR_MSB,  -- ADDR MSB
                                     RX_FRAME_ADDR_LSB,  -- ADDR LSB
                                     RX_FRAME_DATA_MSB,  -- data 
                                     RX_FRAME_DATA_LSB,  -- data

                                     RX_FRAME_CRC,
                                     BAD_CRC_REPLY_1,
                                     BAD_CRC_REPLY_2,
                                     BAD_CRC_REPLY_3,
                                     BAD_CRC_REPLY_4,

                                     RD_CYCLE_1,  -- these are the states for the read
                                     RD_CYCLE_2,  -- access to the bus. 
                                     RD_CYCLE_3,  -- access to the bus.

                                     RD_REPLY_1,  -- reply 1 
                                     RD_REPLY_2,  -- reply 2
                                     RD_REPLY_3,  -- reply 3
                                     RD_REPLY_4,  -- reply 4
                                     RD_REPLY_5,  -- reply 5
                                     RD_REPLY_6,  -- reply 6

                                     WR_CYCLE_1,  --write access to bus
                                     WR_CYCLE_2,  -- 2nd write cycle

                                     WR_REPLY_1,  -- reply cycle of write
                                     WR_REPLY_2,  -- reply 2
                                     WR_REPLY_3,  -- reply 3
                                     WR_REPLY_4   -- reply 3
                                     );

  type hdlc_busmaster_type is record
    state   : hdlc_busmaster_state_type;
    bus_o   : busmaster_out_type;
    cmd     : std_logic_vector(7 downto 0);
    addr    : std_logic_vector(15 downto 0);
    data    : std_logic_vector(15 downto 0);
    dout    : hdlc_enc_in_type;
    crc_inc : std_logic_vector(7 downto 0);
    crc_out : std_logic_vector(7 downto 0);
  end record;

  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : hdlc_busmaster_type := (
    state   => IDLE,
    bus_o   => (addr => (others => '0'), data => (others => '0'), re => '0', we => '0'),
    cmd     => (others => '0'),
    addr    => (others => '0'),
    data    => x"5678",
    dout    => (data => (others => '0'), enable => '0'),
    crc_inc => (others => '0'),
    crc_out => (others => '0'));

-----------------------------------------------------------------------------
-- Component declarations
-----------------------------------------------------------------------------
-- None here. If any: in package

begin  -- architecture behavourial

  ----------------------------------------------------------------------------
  -- Connections between ports and signals
  ----------------------------------------------------------------------------
  bus_o  <= r.bus_o;
  dout_p <= r.dout;

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
  comb_proc : process(din_p, bus_i, r)
    variable v : hdlc_busmaster_type;
  begin
    v          := r;
    v.bus_o.we := '0';
    v.bus_o.re := '0';

    case r.state is
      when IDLE =>  -- idling, waiting for a frame delimiter to arrive
        if din_p.enable = '1' then
          if din_p.data(8) = '1' then
            v.state := RX_FRAME_CMD;
          end if;
        end if;
      when RX_FRAME_CMD =>
        if din_p.enable = '1' then
          v.cmd   := din_p.data(7 downto 0);
          v.state := RX_FRAME_ADDR_MSB;
        end if;
      when RX_FRAME_ADDR_MSB =>
        if din_p.enable = '1' then
          v.addr(15 downto 8) := din_p.data(7 downto 0);
          v.state             := RX_FRAME_ADDR_LSB;
        end if;
      when RX_FRAME_ADDR_LSB =>
        if din_p.enable = '1' then
          v.addr(7 downto 0) := din_p.data(7 downto 0);
          if r.cmd = x"20" then
            v.state := RX_FRAME_DATA_MSB;
          elsif r.cmd = x"10" then
            v.state := RX_FRAME_CRC;
          else
            v.state := IDLE;
          end if;
        end if;
      when RX_FRAME_DATA_MSB =>
        if din_p.enable = '1' then
          v.data(15 downto 8) := din_p.data(7 downto 0);
          v.state             := RX_FRAME_DATA_LSB;
        end if;
      when RX_FRAME_DATA_LSB =>
        if din_p.enable = '1' then
          v.data(7 downto 0) := din_p.data(7 downto 0);
          v.state            := RX_FRAME_CRC;
        end if;

      when RX_FRAME_CRC =>
        if din_p.enable = '1' then
          if r.crc_inc = din_p.data(7 downto 0) then
            if r.cmd = x"20" then
              v.state := WR_CYCLE_1;
            elsif r.cmd = x"10" then
              v.state := RD_CYCLE_1;
            else
              v.state := IDLE;           -- illegal command
            end if;
          else
            v.state := BAD_CRC_REPLY_1;  -- illegal crc 
          end if;
        end if;

        -----------------------------------------------------------------
        --  Send Bad CRC Reply 
        -----------------------------------------------------------------
      when BAD_CRC_REPLY_1 =>
        v.dout.enable := '1';
        v.dout.data   := "1" & x"00";
        v.crc_out     := (others => '0');
        v.state       := BAD_CRC_REPLY_2;
      when BAD_CRC_REPLY_2 =>
        v.dout.data := "0" & x"03";
        v.crc_out   := calc_crc_8210(v.dout.data(7 downto 0), r.crc_out);
        v.state     := BAD_CRC_REPLY_3;
      when BAD_CRC_REPLY_3 =>
        v.dout.data := "0" & r.crc_out;
        v.state     := BAD_CRC_REPLY_4;
      when BAD_CRC_REPLY_4 =>
        v.dout.enable := '0';
        v.state       := IDLE;

        -----------------------------------------------------------------
        --  Execute Read 
        -----------------------------------------------------------------
      when RD_CYCLE_1 =>
        v.bus_o.re   := '1';
        v.bus_o.addr := r.addr(14 downto 0);
        v.state      := RD_CYCLE_2;

      when RD_CYCLE_2 =>
        v.bus_o.re := '0';
        v.state    := RD_CYCLE_3;

      when RD_CYCLE_3 =>
        v.data  := bus_i.data;
        v.state := RD_REPLY_1;

      when RD_REPLY_1 =>
        v.crc_out     := (others => '0');
        v.dout.data   := "1" & x"00";
        v.dout.enable := '1';
        v.state       := RD_REPLY_2;

      when RD_REPLY_2 =>
        v.dout.data := "0" & x"11";
        v.crc_out   := calc_crc_8210(v.dout.data(7 downto 0), r.crc_out);
        v.state     := RD_REPLY_3;

      when RD_REPLY_3 =>
        v.dout.data := "0" & r.data(15 downto 8);
        v.crc_out   := calc_crc_8210(v.dout.data(7 downto 0), r.crc_out);
        v.state     := RD_REPLY_4;

      when RD_REPLY_4 =>
        v.dout.data := "0" & r.data(7 downto 0);
        v.crc_out   := calc_crc_8210(v.dout.data(7 downto 0), r.crc_out);
        v.state     := RD_REPLY_5;

      when RD_REPLY_5 =>
        v.dout.data := "0" & r.crc_out;
        v.state     := RD_REPLY_6;

      when RD_REPLY_6 =>
        v.dout.enable := '0';
        v.state       := IDLE;

        -----------------------------------------------------------------
        --  Execute Write 
        -----------------------------------------------------------------
      when WR_CYCLE_1 =>
        v.bus_o.addr := r.addr(14 downto 0);
        v.bus_o.data := r.data;
        v.bus_o.we   := '1';
        v.state      := WR_CYCLE_2;
      when WR_CYCLE_2 =>
        v.bus_o.we := '0';
        v.state    := WR_REPLY_1;
      when WR_REPLY_1 =>
        v.dout.enable := '1';
        v.dout.data   := "1" & x"00";
        v.crc_out     := (others => '0');
        v.state       := WR_REPLY_2;
      when WR_REPLY_2 =>
        v.dout.data := "0" & x"21";
        v.crc_out   := calc_crc_8210(v.dout.data(7 downto 0), r.crc_out);
        v.state     := WR_REPLY_3;
      when WR_REPLY_3 =>
        v.dout.data := "0" & r.crc_out;
        v.state     := WR_REPLY_4;
      when WR_REPLY_4 =>
        v.dout.enable := '0';
        v.state       := IDLE;

    end case;

    -- running CRC, reset on frame seperators
    if din_p.enable = '1' then
      if din_p.data(8) = '1' then
        v.crc_inc := (others => '0');
      else
        v.crc_inc := calc_crc_8210(din_p.data(7 downto 0), r.crc_inc);
      end if;
    end if;

    rin <= v;
  end process comb_proc;

-----------------------------------------------------------------------------
-- Component instantiations
-----------------------------------------------------------------------------
-- None.

end behavioural;
