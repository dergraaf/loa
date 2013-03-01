-------------------------------------------------------------------------------
-- Title      : UART receiver/transmitter
-------------------------------------------------------------------------------
-- Standard   : VHDL'x
-------------------------------------------------------------------------------
-- Description:
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
entity uart is

   port (
      txd_p : out std_logic;
      rxd_p : in  std_logic;

      din_p   : in  std_logic_vector(7 downto 0);
      empty_p : in  std_logic;
      re_p    : out std_logic;

      dout_p  : out std_logic_vector(7 downto 0);
      we_p    : out std_logic;
      error_p : out std_logic;
      full_p  : in  std_logic;

      clk_en : in std_logic;
      clk    : in std_logic);

end uart;

-------------------------------------------------------------------------------
architecture behavioural of uart is
   
   signal busy      : std_logic := '0';
   signal clk_tx_en : std_logic := '0';
   
begin
   -- 1/5 clock divider for generating the transmission clock
   divider : process (clk)
      variable counter : integer range 0 to 5 := 0;
   begin
      if rising_edge(clk) then
         if clk_en = '1' then
            counter := counter + 1;
            if counter = 5 then
               counter   := 0;
               clk_tx_en <= '1';
            end if;
         else
            clk_tx_en <= '0';
         end if;
      end if;
   end process;

   -- Receiver
   rx : uart_rx
      port map (
         rxd_p     => rxd_p,
         disable_p => busy,
         data_p    => dout_p,
         we_p      => we_p,
         error_p   => error_p,
         full_p    => full_p,
         clk_rx_en => clk_en,
         clk       => clk);

   -- Transmitter
   tx : uart_tx
      port map (
         txd_p     => txd_p,
         busy_p    => busy,
         data_p    => din_p,
         empty_p   => empty_p,
         re_p      => re_p,
         clk_tx_en => clk_tx_en,
         clk       => clk);

end behavioural;
