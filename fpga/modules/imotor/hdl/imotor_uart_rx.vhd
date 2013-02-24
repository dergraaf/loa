-------------------------------------------------------------------------------
-- Title      : iMotor UART receiver
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Simple UART that receives serial data.
--
-- This implementation does not have an baud rate generator. As the intention
-- of this entity is to be used in parallel a global baud rate generator is
-- used. 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_uart_rx is

   generic (
      START_BITS : positive    := 1;
      DATA_BITS  : positive    := 8;
      STOP_BITS  : positive    := 1;
      PARITY     : parity_type := None
      );
   port (
      data_out_p : in std_logic_vector(DATA_BITS - 1 downto 0);  -- parallel
                                                                 -- data out

      rxd_in_p           : in  std_logic;  -- Serial in
      deaf_in_p          : in  std_logic;  -- Ignore rxd_in_p when high. 
      ready_out_p        : out std_logic;  -- High for one clock when new data
                                           -- received
      parity_error_out_p : out std_logic;  -- High when the frame had a parity
                                           -- error

      clock_rx_in_p : in std_logic;     -- Bit clock for receiver
      clk           : in std_logic
      );

end imotor_uart_rx;

-------------------------------------------------------------------------------

architecture behavioural of imotor_uart_rx is

   type imotor_uart_rx_state_type is (
      IDLE,                             -- Idle state: 
      STATE1,                           -- State 1:
      STATE2                            -- State 2:
      );


   type imotor_uart_rx_type is record
      state : imotor_uart_rx_state_type;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : imotor_uart_rx_type := (state => IDLE);

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   parity_error_out_p <= '0';

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
   comb_proc : process(r)
      variable v : imotor_uart_rx_type;

      variable parity_bit : std_logic := '1';  -- Computed parity, default '1'
                                               -- for parity = None

   begin
      v := r;

      case r.state is
         when IDLE   => null;
         when STATE1 => null;
         when STATE2 => null;
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
