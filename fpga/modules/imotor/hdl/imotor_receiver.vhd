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
      START_BYTE : std_logic_vector(7 downto 0) := x"51";  -- expected start byte
      END_BYTE   : std_logic_vector(7 downto 0) := x"A1"  -- expected stop byte

      );
   port (
      -- parallel data out
      data_out_p : out imotor_output_type(DATA_WORDS - 1 downto 0);

      -- parallel data from UART RX
      data_in_p         : in std_logic_vector(7 downto 0);
      parity_error_in_p : in std_logic;
      ready_in_p        : in std_logic;

      clk : in std_logic
      );

end imotor_receiver;

-------------------------------------------------------------------------------

architecture behavioural of imotor_receiver is

   type imotor_receiver_state_type is (
      IDLE,                             -- Idle state:
      DATA,                             -- Receiving data bytes
      STOP                              -- Expecting end byte
      );

   type imotor_receiver_type is record
      state : imotor_receiver_state_type;

      -- Store all bytes until proper end byte received
      data_store : imotor_output_type(DATA_WORDS - 1 downto 0);

      -- The output to the register file is only updated when proper end byte
      -- received. 
      data_out   : imotor_output_type(DATA_WORDS - 1 downto 0);
      byte_count : integer range 0 to 5;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : imotor_receiver_type := (
      state      => IDLE,
      data_out   => (others => (others => '0')),
      data_store => (others => (others => '0')),
      byte_count => 0
      );

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   data_out_p <= r.data_out;

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
   comb_proc : process(data_in_p, r, ready_in_p)
      variable v : imotor_receiver_type;

   begin
      v := r;

      case r.state is
         
         when IDLE =>
            if ready_in_p = '1' and data_in_p = START_BYTE then
               -- It is the correct byte
               v.byte_count := 0;
               v.state      := DATA;
            end if;
            
         when DATA =>
            if ready_in_p = '1' then
               -- Store byte in data_store
               if r.byte_count mod 2 = 0 then
                  v.data_store(r.byte_count / 2)(7 downto 0) := data_in_p;
               else
                  v.data_store(r.byte_count / 2)(15 downto 8) := data_in_p;
               end if;

               -- All received?
               if v.byte_count = 3 then
                  v.state := STOP;      -- expect END byte
               end if;

               -- Always count
               v.byte_count := r.byte_count + 1;
            end if;
            
         when STOP =>
            if ready_in_p = '1' then
               -- Next state is always idle
               v.state := IDLE;
               if data_in_p = END_BYTE then
                  -- Correct end byte received. Copy data to register file
                  v.data_out := r.data_store;
               end if;
            end if;
            
      end case;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.

end behavioural;
