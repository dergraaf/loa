-------------------------------------------------------------------------------
-- Title      : iMotor Sender
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Simple UART that sends parallel data serially.
-- -------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_sender is

   generic (
      DATA_WORDS : positive := 2;
      DATA_WIDTH : positive := 16;
      START_BYTE : std_logic_vector(7 downto 0) := x"50";
      END_BYTE   : std_logic_vector(7 downto 0) := x"A0"

      );
   port (
      -- parallel data in
      data_in_p : in imotor_input_type(DATA_WORDS - 1 downto 0);

      data_out_p  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
      start_out_p : out std_logic;      -- start a transmission of data_in_p
      busy_in_p   : in  std_logic;      -- high when busy

      start_in_p : in std_logic;

      clk : in std_logic
      );

end imotor_sender;

-------------------------------------------------------------------------------

architecture behavioural of imotor_sender is

   type imotor_sender_state_type is (
      IDLE,                             -- Idle state:
      START,                            -- Sending start byte
      STATE1,                           -- State 1: 
      STATE2                            -- State 2:
      );

   type imotor_sender_type is record
      state : imotor_sender_state_type;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : imotor_sender_type := (state => IDLE);

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
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   ----------------------------------------------------------------------------
   -- Combinatorial part of FSM
   ----------------------------------------------------------------------------
   comb_proc : process(r, start_in_p)
      variable v : imotor_sender_type;
      
   begin
      v := r;

      case r.state is
         when IDLE =>
            if start_in_p = '1' then
               v.state := START;
            end if;
         when START => null;
         when STATE1 => null;
         when STATE2 => null;
      end case;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.

end behavioural;
