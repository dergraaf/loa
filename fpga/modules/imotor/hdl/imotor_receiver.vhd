-------------------------------------------------------------------------------
-- Title      : iMotor Receiver
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Receives messages from the slave.
--
-- Endianess: Little (as it is the default of ARM)
-- (Transmits lower byte first)
-- -------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_receiver is

   generic (
      DATA_WORDS : positive                     := 2;
      DATA_WIDTH : positive                     := 16;
      START_BYTE : std_logic_vector(7 downto 0) := x"51";
      END_BYTE   : std_logic_vector(7 downto 0) := x"A1"

      );
   port (
      -- parallel data in
      data_out_p : in imotor_output_type(DATA_WORDS - 1 downto 0);

      -- parallel data from UART RX
      data_in_p         : out std_logic_vector(7 downto 0);
      parity_error_in_p : in  std_logic;
      ready_in_p        : in  std_logic;

      clk : in std_logic
      );

end imotor_receiver;

-------------------------------------------------------------------------------

architecture behavioural of imotor_sender is

   type imotor_receiver_state_type is (
      IDLE,                             -- Idle state:
      START,                            -- Receiving start byte
      DATA,                             -- Receiving data bytes
      STOP                              -- Receiving stop byte
      );

   type imotor_sender_type is record
      state      : imotor_receiver_state_type;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : imotor_receiver_type := (
      state      => IDLE
      );

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   data_out_p  <= r.data_out;
   start_out_p <= r.start;

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
      variable v : imotor_sender_type;

   begin
      v := r;

      case r.state is
         when IDLE  => null;
         when START => null;
         when DATA  => null;
         when STOP  => null;
      end case;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.

end behavioural;
