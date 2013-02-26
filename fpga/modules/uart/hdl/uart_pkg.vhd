-------------------------------------------------------------------------------
-- Title      : UART package
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 Fabian Greif
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package uart_pkg is

   component uart_tx
      port (
         txd_p : out std_logic;         -- Output pin (active low)

         -- FIFO interface
         data_p  : in  std_logic_vector(7 downto 0);
         empty_p : in  std_logic;       -- Set if the FIFO is empty
         re_p    : out std_logic;       -- Read enable

         clk_tx_en : in std_logic;      -- Enable pulse for the bitrate
         clk       : in std_logic);
   end component;

end uart_pkg;
