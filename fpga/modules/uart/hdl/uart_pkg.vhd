-------------------------------------------------------------------------------
-- Title      : UART package
-------------------------------------------------------------------------------
-- Standard   : VHDL'x
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Fabian Greif
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package uart_pkg is

   -- UART transmitter
   component uart_tx
      port (
         txd_p  : out std_logic;        -- Output pin (active low)
         busy_p : out std_logic;  -- High if a transmission is in progress

         -- FIFO interface
         data_p  : in  std_logic_vector(7 downto 0);
         empty_p : in  std_logic;       -- Set if the FIFO is empty
         re_p    : out std_logic;       -- Read enable

         clk_tx_en : in std_logic;      -- Enable pulse for the bitrate
         clk       : in std_logic);
   end component;

   -- UART receiver
   component uart_rx
      port (
         rxd_p : in std_logic;          -- Input pin

         -- Set high to disable the reception of any data. Aborts any
         -- incoming transmission.
         disable_p : in std_logic;

         -- FIFO interface
         data_p  : out std_logic_vector(7 downto 0);
         we_p    : out std_logic;       -- Write enable
         error_p : out std_logic;       -- Framing or parity error
         full_p  : in  std_logic;       -- Set if FIFO is full and can't receive any further data

         -- Enable pulse for the rx bitrate, needs to be five timer higher
         -- than the actual bitrate
         clk_rx_en : in std_logic;
         clk       : in std_logic);
   end component;

   -- UART receiver/transmitter
   --
   -- Module with echo rejection. 
   component uart
      port(
         txd_p : out std_logic;         -- Output pin (active low)
         rxd_p : in  std_logic;         -- Input pin

         -- FIFO transmit interface
         din_p   : in  std_logic_vector(7 downto 0);
         empty_p : in  std_logic;       -- Set if the FIFO is empty
         re_p    : out std_logic;       -- Read enable

         -- FIFO receive interface
         dout_p  : out std_logic_vector(7 downto 0);
         we_p    : out std_logic;       -- Write enable
         error_p : out std_logic;       -- Framing or parity error
         -- Set if FIFO is full and can't receive any further data
         full_p  : in  std_logic;

         -- Enable pulse for the rx bitrate, needs to be five timer higher
         -- than the actual bitrate
         clk_en : in std_logic;
         clk    : in std_logic);

   end component;

end uart_pkg;
