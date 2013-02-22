-------------------------------------------------------------------------------
-- Title      : iMotor UART send
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Simple UART that sends parallel data serially.
--
-- This implementation does not have an baud rate generator. As the intention
-- of this entity is to be used in parallel a global baud rate generator is
-- used. When new data is to be send the entity needs to wait for the first
-- clock enable of the baud rate generator. Otherwise the length of the start
-- bit would be different.
--
-- The parity bit is always present. If parity is set to None it is set '1'
-- which is interpreted as the stop bit. In this case there is one more
-- stop bit then requested. 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_uart_tx is

   generic (
      START_BITS : positive    := 1;
      DATA_BITS  : positive    := 8;
      STOP_BITS  : positive    := 1;
      PARITY     : parity_type := None
      );
   port (
      data_in_p  : in  std_logic_vector(DATA_BITS - 1 downto 0);  -- parallel
                                                                  -- data in
      start_in_p : in  std_logic;       -- start a transmission of data_in_p
      busy_out_p : out std_logic;       -- high when busy
      txd_out_p  : out std_logic;       -- output to transceiver

      clock_tx_in_p : in std_logic;     -- Bit clock for transmitter
      clk           : in std_logic
      );

end imotor_uart_tx;

-------------------------------------------------------------------------------

architecture behavioural of imotor_uart_tx is

   type imotor_uart_tx_state_type is (
      IDLE,                             -- Idle state: 
      STATE1,  -- State 1: Request to send received, wait for first bit time.
      STATE2                            -- State 2: Sending of bis in progress
      );


   type imotor_uart_tx_type is record
      -- shift register
      -- Omitting -1 because of the parity bit
      sr : std_logic_vector (START_BITS + DATA_BITS + STOP_BITS downto 0);

      -- Number of bits
      -- One more for parity bit
      bitcnt : integer range 0 to START_BITS + DATA_BITS + 1 + STOP_BITS;

      state : imotor_uart_tx_state_type;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : imotor_uart_tx_type := (state  => IDLE,
                                           sr     => (others => '1'),
                                           bitcnt => START_BITS + DATA_BITS + 1 + STOP_BITS);

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   busy_out_p <= '1'     when (start_in_p = '1' or r.state /= IDLE) else '0';
   txd_out_p  <= r.sr(0) when (r.state = STATE2)                    else '1';

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
   comb_proc : process(clock_tx_in_p, data_in_p, r, start_in_p)
      variable v : imotor_uart_tx_type;

      variable parity_bit : std_logic := '1';  -- Computed parity, default '1'
                                               -- for parity = None

   begin
      -- Parity bit:
      parity_bit := '1';
      for i in data_in_p'range loop
         parity_bit := parity_bit xor data_in_p(i);
      end loop;

      v := r;

      case r.state is
         when IDLE =>
            if start_in_p = '1' then
               -- Set the shift register:
               -- STOP_BITS PARITY_BIT DATA_BITS START_BITS


               -- Upper bits: STOP_BITS set to '1':
               v.sr(START_BITS + DATA_BITS + STOP_BITS downto START_BITS + DATA_BITS + 1) := (others => '1');

               -- Set parity bit in shift register
               case PARITY is
                  when None => v.sr(START_BITS + DATA_BITS) := '1';
                  when Even => v.sr(START_BITS + DATA_BITS) := parity_bit;
                  when Odd  => v.sr(START_BITS + DATA_BITS) := not parity_bit;
               end case;

               -- Lower bits: START_BITS set to '0':
               v.sr(START_BITS - 1 downto 0) := (others => '0');

               -- Middle bits: DATA_BITS
               v.sr(START_BITS + DATA_BITS - 1 downto START_BITS) := data_in_p;

               v.bitcnt := 0;
               v.state  := STATE1;
            end if;
         when STATE1 =>
            -- Bit clock enable arrived, send start bit now. 
            if clock_tx_in_p = '1' then
               v.state := STATE2;
            end if;
         when STATE2 =>
            if clock_tx_in_p = '1' then
               if v.bitcnt < (START_BITS + DATA_BITS + STOP_BITS) then
                  -- Next bit
                  v.bitcnt := r.bitcnt + 1;
                  v.sr     := '1' & r.sr(v.sr'left downto 1);
               else
                  v.state := IDLE;
               end if;
            end if;
         when others =>
            v.state := IDLE;
      end case;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.

end behavioural;
