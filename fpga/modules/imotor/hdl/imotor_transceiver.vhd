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
      DATA_WORDS_SEND : positive;
      DATA_WORDS_READ : positive;
      DATA_WIDTH : positive := 16
      );
   port (
      -- parallel data in and out
      data_in_p  : in  imotor_input_type(DATA_WORDS_SEND - 1 downto 0);
      data_out_p : out imotor_output_type(DATA_WORDS_READ - 1 downto 0);

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
   constant DATA_BITS  : positive    := 8;
   constant START_BITS : positive    := 1;
   constant STOP_BITS  : positive    := 1;
   constant PARITY     : parity_type := Odd;

   signal uart_start_s : std_logic;
   signal uart_start_ns : std_logic;
   signal uart_busy_s  : std_logic;
   signal uart_ready_s : std_logic;

   signal data_tx_s : std_logic_vector(7 downto 0);

   signal data_rx_s : std_logic_vector(7 downto 0);  -- Received data from uart
                                                     -- to receiver

   signal parity_error_s : std_logic;  -- Info about parity error from uart to receiver



   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   uart_start_ns <= not uart_start_s;

   ----------------------------------------------------------------------------
   -- Sequential part of finite state machine (FSM)
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Combinatorial part of FSM
   ----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   imotor_sender_1 : entity work.imotor_sender
      generic map (
         DATA_WORDS => DATA_WORDS_SEND,
         DATA_WIDTH => DATA_WIDTH)
      port map (
         data_in_p   => data_in_p,
         data_out_p  => data_tx_s,
         start_out_p => uart_start_s,
         busy_in_p   => uart_busy_s,
         start_in_p  => timer_in_p.send,
         clk         => clk);

   --imotor_uart_tx_1 : entity work.imotor_uart_tx
   --   generic map (
   --      START_BITS => START_BITS,
   --      DATA_BITS  => DATA_BITS,
   --      STOP_BITS  => STOP_BITS,
   --      PARITY     => PARITY)
   --   port map (
   --      data_in_p     => data_tx_s,
   --      start_in_p    => uart_start_s,
   --      busy_out_p    => uart_busy_s,
   --      txd_out_p     => tx_out_p,
   --      clock_tx_in_p => timer_in_p.tx,
   --      clk           => clk);

   uart_tx_1: entity work.uart_tx
      port map (
         txd_p     => tx_out_p,
         busy_p    => uart_busy_s,
         data_p    => data_tx_s,
         empty_p   => uart_start_ns,
         re_p      => open,
         clk_tx_en => timer_in_p.tx,
         clk       => clk);
   
   uart_rx_1: entity work.uart_rx
      port map (
         rxd_p     => rx_in_p,
         disable_p => uart_busy_s,
         data_p    => data_rx_s,
         we_p      => uart_ready_s,
         error_p   => parity_error_s,
         full_p    => '0',              -- always get data
         clk_rx_en => timer_in_p.rx,
         clk       => clk);
   
   --imotor_uart_rx_1 : entity work.imotor_uart_rx
   --   generic map (
   --      START_BITS => START_BITS,
   --      DATA_BITS  => DATA_BITS,
   --      STOP_BITS  => STOP_BITS,
   --      PARITY     => PARITY)
   --   port map (
   --      data_out_p         => data_rx_s,
   --      rxd_in_p           => rx_in_p,
   --      deaf_in_p          => uart_busy_s,  -- make the receiver deaf when the
   --                                          -- transmitter is active
   --      ready_out_p        => uart_ready_s,
   --      parity_error_out_p => parity_error_s,
   --      clock_rx_in_p      => timer_in_p.rx,
   --      clk                => clk);

   imotor_receiver_1 : entity work.imotor_receiver
      generic map (
         DATA_WORDS => DATA_WORDS_READ,
         DATA_WIDTH => DATA_WIDTH)
      port map (
         data_out_p        => data_out_p,
         data_in_p         => data_rx_s,
         parity_error_in_p => parity_error_s,
         ready_in_p        => uart_ready_s,
         clk               => clk);

end behavioural;
