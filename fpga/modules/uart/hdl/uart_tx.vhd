-------------------------------------------------------------------------------
-- Title      : UART Transmitter with Odd-Parity
-------------------------------------------------------------------------------
-- Standard   : VHDL'x
-------------------------------------------------------------------------------
-- Description:
-- 
-- Data is send with LSB (Least Significat Bit) first.
-- Odd-parity. Example:
--
--    0000 0000 => parity 1
--    0000 0001 => parity 0
--    0000 0010 => parity 0
--    0000 0011 => parity 1
--       ...
--    1111 1111 => parity 1
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Fabian Greif
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.uart_pkg.all;

-------------------------------------------------------------------------------
entity uart_tx is

  port (
    txd_p     : out std_logic;
    busy_p    : out std_logic;
    data_p    : in  std_logic_vector(7 downto 0);
    empty_p   : in  std_logic;
    re_p      : out std_logic;
    clk_tx_en : in  std_logic;
    clk       : in  std_logic);

end uart_tx;

-------------------------------------------------------------------------------
architecture behavioural of uart_tx is

  type transmit_states is (IDLE, START, WAITSTATE, WAITSTATE2, DATA, PARITY, STOP);

  type uart_tx_type is record
    state      : transmit_states;
    bitcount   : integer range 0 to 8;
    parity     : std_logic;
    txd        : std_logic;             -- Output pin
    -- Input FIFO
    shift_reg  : std_logic_vector(7 downto 0);
    fifo_re    : std_logic;
  end record;

  signal r, rin : uart_tx_type := (
    state      => IDLE,
    bitcount   => 0,
    parity     => '0',
    txd        => '1',
    shift_reg  => (others => '0'),
    fifo_re    => '0');

begin
  -- Connections between ports and signals
  txd_p  <= r.txd;
  re_p   <= r.fifo_re;
  busy_p <= '0' when ((r.state = IDLE) and (empty_p = '1')) else '1';

  -- Sequential part of finite state machine (FSM)
  seq_proc : process(clk)
  begin
    if rising_edge(clk) then
      r <= rin;
    end if;
  end process seq_proc;

  -- Combinatorial part of FSM
  comb_proc : process(clk_tx_en, data_p, empty_p, r)
    variable v : uart_tx_type;
  begin
    v := r;

    v.fifo_re := '0';

    case r.state is
      when IDLE =>
        if empty_p = '0' then
          v.fifo_re    := '1';
          v.state      := WAITSTATE;
        end if;

      when WAITSTATE =>
        v.state := WAITSTATE2;
        
      when WAITSTATE2 =>
        v.shift_reg := data_p;
        v.state     := START;
        
      when START =>
        if clk_tx_en = '1' then
          v.txd      := '0';
          v.state    := DATA;
          v.bitcount := 0;
          v.parity   := '0';
        end if;

      when DATA =>
        if clk_tx_en = '1' then
          -- Send data with LSB first
          v.txd := r.shift_reg(0);

          -- data  parity
          --   0 + 0 => 0
          --   0 + 1 => 1
          --   1 + 0 => 1
          --   1 + 1 => 0
          -- => xor
          v.parity := r.parity xor r.shift_reg(0);

          v.shift_reg := '0' & r.shift_reg(7 downto 1);
          if r.bitcount = 7 then
            v.state := PARITY;
          else
            v.bitcount := r.bitcount + 1;
          end if;
        end if;

      when PARITY =>
        if clk_tx_en = '1' then
          v.txd   := not r.parity;
          v.state := STOP;
        end if;

      when STOP =>
        if clk_tx_en = '1' then
          v.txd   := '1';
          v.state := IDLE;
        end if;
    end case;

    rin <= v;
  end process comb_proc;

  -- Component instantiations   
end behavioural;
