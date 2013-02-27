-------------------------------------------------------------------------------
-- Title      : UART Receiver (Odd-Parity)
-------------------------------------------------------------------------------
-- Standard   : VHDL'x
-------------------------------------------------------------------------------
-- Description:
-- 
-- Data is received with LSB (Least Significat Bit) first.
-- The receiver uses 5x oversampling, therefore clk_rx_en needs to five times
-- higher than the desired bitrate.
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
entity uart_rx is

   port (
      rxd_p     : in  std_logic;
      disable_p : in  std_logic;
      data_p    : out std_logic_vector(7 downto 0);
      we_p      : out std_logic;
      error_p   : out std_logic;
      full_p    : in  std_logic;
      clk_rx_en : in  std_logic;
      clk       : in  std_logic);

end uart_rx;

-------------------------------------------------------------------------------
architecture behavioural of uart_rx is

   type receive_states is (IDLE, START, DATA);

   type uart_rx_type is record
      state       : receive_states;
      bitcount    : integer range 0 to 10;
      samplecount : integer range 0 to 4;
      samples     : std_logic_vector(4 downto 0);
      parity      : std_logic;

      -- is set when the reception has been
      -- disabled during the last byte
      disabled  : std_logic;
      shift_reg : std_logic_vector(9 downto 0);

      -- Output FIFO
      fifo_data  : std_logic_vector(7 downto 0);
      fifo_we    : std_logic;
      fifo_error : std_logic;           -- parity of framing error
   end record;

   signal r, rin : uart_rx_type := (
      state       => IDLE,
      bitcount    => 0,
      samplecount => 0,
      samples     => (others => '0'),
      parity      => '0',
      disabled    => '0',
      shift_reg   => (others => '0'),
      fifo_data   => (others => '0'),
      fifo_we     => '0',
      fifo_error  => '0');

   signal voter_output : std_logic := '0';

   -- Five bit majority voter.
   --
   -- Returns '1' if more than two bits in the input vector are set, and
   -- '0' otherwise.
   function voter(samples : in std_logic_vector(4 downto 0)) return std_logic is
   signal voter_input  : std_logic_vector(4 downto 0) := (others => '0');
   signal voter_output : std_logic                    := '0';

   procedure voter (
      signal samples : in  std_logic_vector(4 downto 0);
      signal value   : out std_logic) is
      variable cnt : integer range 0 to 5 := 0;
   begin
      for c in 0 to 4 loop
         if samples(c) = '1' then
            cnt := cnt + 1;
         end if;
      end loop;
      if cnt >= 3 then
         return '1';
      else
         return '0';
      end if;
   end voter;

begin
   -- Connections between ports and signals
   data_p  <= r.fifo_data;
   we_p    <= r.fifo_we;
   error_p <= r.fifo_error;

   -- Sequential part of finite state machine (FSM)
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   -- Combinatorial part of FSM
   comb_proc : process(clk_rx_en, disable_p, r, rxd_p, voter_output)
      variable v : uart_rx_type;
   begin
      v := r;

      v.fifo_we    := '0';
      v.fifo_error := '0';
      v.fifo_data  := (others => '0');

      -- RXD line is constantly sampled.
      if clk_rx_en = '1' then
         v.samples    := r.samples(3 downto 0) & rxd_p;
         voter_output <= voter(r.samples);
      end if;

      if disable_p = '1' then
         v.disabled := '1';
      end if;

      case r.state is
         when IDLE =>
            if rxd_p <= '0' then
               v.state       := START;
               v.samplecount := 0;
            end if;

         when START =>
            if clk_rx_en = '1' then
               if r.samplecount = 3 then

                  if voter_output = '0' then
                     v.state       := DATA;
                     v.samplecount := 0;
                     v.bitcount    := 0;
                  else
                     v.state := IDLE;
                  end if;
               else
                  v.samplecount := r.samplecount + 1;
               end if;
            end if;

         when DATA =>
            if clk_rx_en = '1' then
               if r.samplecount = 4 then
                  v.samplecount := 0;

                  v.shift_reg := voter_output & r.shift_reg(9 downto 1);
                  v.parity    := r.parity xor voter_output;

                  if r.bitcount = 9 then
                     v.state    := IDLE;
                     v.disabled := '0';

                     -- Only forward the received data if the receiver
                     -- wasn't disabled during the receiption.
                     if r.disabled = '0' then
                        v.fifo_we := '1';
                     end if;

                     -- Check for framing errors (= no stop bit) or parity errors
                     if v.shift_reg(9) = '0' or v.parity = '1' then
                        v.fifo_error := '1';
                     else
                        v.fifo_data := v.shift_reg(7 downto 0);
                     end if;
                  else
                     v.bitcount := r.bitcount + 1;
                  end if;
               else
                  v.samplecount := r.samplecount + 1;
               end if;
            end if;

      end case;

      rin <= v;
   end process comb_proc;

-- Component instantiations
end behavioural;
