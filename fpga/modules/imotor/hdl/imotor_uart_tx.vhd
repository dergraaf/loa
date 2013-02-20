-------------------------------------------------------------------------------
-- Title      : iMotor UART send
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
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
      START_BITS : natural     := 1;
      DATA_BITS  : natural     := 8;
      STOP_BITS  : natural     := 1;
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

   type entity_name_state_type is (
      IDLE,                             -- Idle state: 
      STATE1,                           -- State 1:
      STATE2                            -- State 2:
      );

   type imotor_uart_tx_type is record
      -- shift register 
      sr : std_logic_vector (START_BITS + DATA_BITS + STOP_BITS - 1 downto 0);

      -- Number of bits
      bitcnt : integer range 0 to START_BITS + DATA_BITS + STOP_BITS;

      state : entity_name_state_type;
   end record;


   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : imotor_uart_tx_type := (state  => IDLE,
                                           sr     => (others => '1'),
                                           bitcnt => START_BITS + DATA_BITS + STOP_BITS);

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   busy_out_p <= '1'     when (start_in_p = '1' or r.bitcnt < (START_BITS + DATA_BITS + STOP_BITS - 1)) else '0';
   txd_out_p  <= r.sr(0) when (r.state = STATE2)                                                        else '1';

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
      
   begin
      v := r;

      case r.state is
         when IDLE =>
            if start_in_p = '1' then
               v.sr     := '1' & data_in_p & '0';  -- FIXME variable number of start
                                                   -- and stop bits
               v.bitcnt := 0;
               v.state  := STATE1;
            end if;
         when STATE1 =>
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
