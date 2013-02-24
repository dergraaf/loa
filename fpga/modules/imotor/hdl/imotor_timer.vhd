-------------------------------------------------------------------------------
-- Title      : iMotor Timer
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: The iMotor Timer generates clock enables for
--              * UART transmit clock (e.g. 1 MHz for sending at 1 MBit)
--              * UART receive clock  (e.g. 5 MHz for 5x oversampling at 1 MBit)
--              * Send state machine  (e.g. 1 kHz for sending messages)
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.utils_pkg.all;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_timer is
   generic (
      CLOCK          : positive := 50E6;
      BAUD           : positive := 1E6;
      SEND_FREQUENCY : positive := 1E3
      );
   port (
      clock_out_p : out imotor_timer_type;

      clk : in std_logic
      );

end imotor_timer;

-------------------------------------------------------------------------------

architecture behavioural of imotor_timer is

begin  -- architecture behavourial

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------

   clock_divider_tx : clock_divider
      generic map (
         DIV => CLOCK / BAUD)
      port map (
         clk_out_p => clock_out_p.tx,
         clk       => clk);

   clock_divider_rx : clock_divider
      generic map (
         DIV => CLOCK / BAUD / 5)
      port map (
         clk_out_p => clock_out_p.rx,
         clk       => clk);

   clock_divider_send : clock_divider
      generic map (
         DIV => CLOCK / SEND_FREQUENCY)
      port map (
         clk_out_p => clock_out_p.send,
         clk       => clk);

end behavioural;
