-------------------------------------------------------------------------------
-- Title      : iMotor package
-- Project    : 
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;

package imotor_module_pkg is

   type parity_type is (None, Even, Odd);

   -- Data types of a single iMotor
   type imotor_input_type is array (natural range <>) of std_logic_vector(15 downto 0);
   type imotor_output_type is array (natural range <>) of std_logic_vector(15 downto 0);

   -- Data types for all iMotors in one
   type imotor_timer_type is record
      tx   : std_logic;                 -- TX bit timing
      rx   : std_logic;                 -- RX bit timing
      send : std_logic;                 -- Trigger start of new message
   end record imotor_timer_type;

   -- components here!
   component imotor_timer is
      generic (
         CLOCK          : positive;
         BAUD           : positive;
         SEND_FREQUENCY : positive);
      port (
         clock_out_p : out imotor_timer_type;
         clk         : in  std_logic);
   end component imotor_timer;

   component imotor_uart_tx
      generic (
         START_BITS : positive;
         DATA_BITS  : positive;
         STOP_BITS  : positive;
         PARITY     : parity_type);
      port (
         data_in_p     : in  std_logic_vector(DATA_BITS - 1 downto 0);
         start_in_p    : in  std_logic;
         busy_out_p    : out std_logic;
         txd_out_p     : out std_logic;
         clock_tx_in_p : in  std_logic;
         clk           : in  std_logic);
   end component;

   component imotor_sender
      generic (
         DATA_WORDS : positive;
         DATA_WIDTH : positive);
      port (
         data_in_p   : in  imotor_input_type(DATA_WORDS - 1 downto 0);
         data_out_p  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
         start_out_p : out std_logic;
         busy_in_p   : in  std_logic;
         start_in_p  : in  std_logic;
         clk         : in  std_logic);
   end component;

   component imotor_uart_rx is
      generic (
         START_BITS : positive;
         DATA_BITS  : positive;
         STOP_BITS  : positive;
         PARITY     : parity_type);
      port (
         data_out_p         : in  std_logic_vector(DATA_BITS - 1 downto 0);
         rxd_in_p           : in  std_logic;
         deaf_in_p          : in  std_logic;
         ready_out_p        : out std_logic;
         parity_error_out_p : out std_logic;
         clock_rx_in_p      : in  std_logic;
         clk                : in  std_logic);
   end component imotor_uart_rx;
   
   component imotor_receiver is
      generic (
         DATA_WORDS : positive;
         DATA_WIDTH : positive;
         START_BYTE : std_logic_vector(7 downto 0);
         END_BYTE   : std_logic_vector(7 downto 0));
      port (
         data_out_p        : in  imotor_output_type(DATA_WORDS - 1 downto 0);
         data_in_p         : out std_logic_vector(7 downto 0);
         parity_error_in_p : in  std_logic;
         ready_in_p        : in  std_logic;
         clk               : in  std_logic);
   end component imotor_receiver;
   
   component imotor_transceiver is
      generic (
         DATA_WORDS : positive;
         DATA_WIDTH : positive);
      port (
         data_in_p  : in  imotor_input_type(DATA_WORDS - 1 downto 0);
         data_out_p : in  imotor_output_type(DATA_WORDS - 1 downto 0);
         tx_out_p   : out std_logic;
         rx_in_p    : in  std_logic;
         timer_in_p : in  imotor_timer_type;
         clk        : in  std_logic);
   end component imotor_transceiver;
   
   component imotor_module is
      generic (
         BASE_ADDRESS : integer range 0 to 32767;
         MOTORS       : positive);
      port (
         tx_out_p : out std_logic_vector(MOTORS - 1 downto 0);
         rx_in_p  : in  std_logic_vector(MOTORS - 1 downto 0);
         bus_o    : out busdevice_out_type;
         bus_i    : in  busdevice_in_type;
         clk      : in  std_logic);
   end component imotor_module;

end imotor_module_pkg;
