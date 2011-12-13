
library ieee;
use ieee.std_logic_1164.all;

entity clock_divider_tb is
end clock_divider_tb;

architecture behavior of clock_divider_tb is
	use work.clock_divider_pkg.all;
	
	signal clk		: std_logic := '0';
	signal output	: std_logic;
begin
	clk	 <= not clk after 10 ns;		 -- 50 Mhz clock
	
	uut : clock_divider
		generic map (divider => 5)
		port map(
			clk => clk,
			output => output);
end;
