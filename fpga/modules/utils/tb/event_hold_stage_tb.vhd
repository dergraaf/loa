
library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

entity event_hold_stage_tb is
end event_hold_stage_tb;

architecture tb of event_hold_stage_tb is
   signal dout    : std_logic := '0';
   signal din     : std_logic := '0';
   signal period : std_logic := '0';
   signal clk     : std_logic := '0';
begin
   clk <= not clk after 10 NS;          -- 50 Mhz clock

   uut : event_hold_stage
      port map (
         dout_p => dout,
         din_p  => din,
         period_p => period,
         clk    => clk);

   process
   begin
      wait for 10 NS;
      din <= '1';
      wait for 20 NS;
      din <= '0';

      wait for 100 NS;
      period <= '1';
      wait for 20 NS;
      period <= '0';

      wait for 100 NS;
      period <= '1';
      wait for 20 NS;
      period <= '0';

      wait for 100 NS;
      period <= '1';
      din     <= '1';
      wait for 20 NS;
      period <= '0';
      din     <= '0';
      
      wait for 100 NS;
      period <= '1';
      wait for 20 NS;
      period <= '0';

      wait for 100 NS;
      period <= '1';
      wait for 20 NS;
      period <= '0';
      
      wait for 100 US;
   end process;
end tb;
