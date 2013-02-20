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

   -- components here!
   component imotor_timer
      generic (
         CLOCK          : positive;
         BAUD           : positive;
         SEND_FREQUENCY : positive);
      port (
         clk              : in  std_logic;
         clock_tx_out_p   : out std_logic;
         clock_rx_out_p   : out std_logic;
         clock_send_out_p : out std_logic);
   end component;

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

end imotor_module_pkg;
