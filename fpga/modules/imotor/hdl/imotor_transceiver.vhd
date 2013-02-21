-------------------------------------------------------------------------------
-- Title      : iMotor Transceiver
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

entity imotor_transceiver is

   generic (
      DATA_WORDS : positive := 2;
      DATA_WIDTH : positive := 16
      );
   port (
      -- parallel data in and out
      data_in_p  : in  std_logic_vector(15 downto 0);
      data_out_p : out std_logic_vector(15 downto 0);

      -- UART RX/TX
      tx_out_p : out std_logic;
      rx_in_p  : in  std_logic;

      -- Clocks for UART and sender
      timer_in_p : in imotor_timer_type;

      clk : in std_logic
      );

end imotor_transceiver;

-------------------------------------------------------------------------------

architecture behavioural of imotor_transceiver is

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Sequential part of finite state machine (FSM)
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Combinatorial part of FSM
   ----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------

end behavioural;
