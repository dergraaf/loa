-------------------------------------------------------------------------------
-- Title      : iMotor Sender
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
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

entity imotor_sender is

   generic (
      DATA_WORDS : positive                     := 2;
      DATA_WIDTH : positive                     := 16;
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
      DATA,                             -- Sending data bytes
      STOP                              -- Sending stop byte
      );

   type imotor_sender_type is record
      state      : imotor_sender_state_type;
      data_out   : std_logic_vector(7 downto 0);
      start      : std_logic;
      byte_count : integer range 0 to DATA_WORDS * 2;  -- ToDo: Make dependent
                                                       -- from data width
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : imotor_sender_type := (
      state      => IDLE,
      start      => '0',
      data_out   => (others => '0'),
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
   comb_proc : process(busy_in_p, data_in_p(0)(7 downto 0), r, start_in_p)
      variable v : imotor_sender_type;

   begin
      v := r;

      case r.state is
         when IDLE =>
            if start_in_p = '1' then
               -- Send Start Byte
               v.state    := START;
               v.start    := '1';
               v.data_out := START_BYTE;
            end if;
         when START =>
            v.start := '0';
            if busy_in_p = '0' then
               -- Send Data
               v.state      := DATA;
               v.start      := '1';
               v.byte_count := 0;

               if v.byte_count mod 2 = 0 then
                  v.data_out := data_in_p(v.byte_count / 2)(7 downto 0);
               else
                  v.data_out := data_in_p(v.byte_count / 2)(15 downto 8);
               end if;
            end if;
         when DATA =>
            v.start := '0';
            if busy_in_p = '0' then
               v.byte_count := v.byte_count + 1;
               v.start      := '1';

               if v.byte_count = DATA_WORDS * 2 then
                  v.state    := STOP;
                  v.data_out := END_BYTE;
               elsif v.byte_count mod 2 = 0 then
                  v.data_out := data_in_p(v.byte_count / 2)(7 downto 0);
               else
                  v.data_out := data_in_p(v.byte_count / 2)(15 downto 8);
               end if;
            end if;
         when STOP =>
            v.start := '0';
            if busy_in_p = '0' then
               -- Do not send more data
               v.state := IDLE;
            end if;
      end case;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.

end behavioural;
