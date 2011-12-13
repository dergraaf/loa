library ieee;
use ieee.std_logic_1164.all;

entity pwm_tb is
end pwm_tb;

architecture behavior of pwm_tb is
	use work.pwm_pkg.all;
	
	signal clk		: std_logic := '0';
	signal clk_en : std_logic := '1';
	signal reset	: std_logic := '1';
	signal value 	: std_logic_vector(7 downto 0) := (others => '0');
	signal output	: std_logic;
begin
	clk	 <= not clk after 10 ns;		 -- 50 Mhz clock
	reset <= '1', '0' after 50 ns; -- erzeugt Resetsignal: --__
	
	tb : process
	begin
		value <= x"7F";
		wait for 50 us;
		value <= x"01";
		wait for 50 us;
		value <= x"FE";
		wait for 50 us;
		value <= x"00";
		wait for 50 us;
		value <= x"FF";
		wait for 50 us;
	end process;
	
	uut : pwm
		generic map (width => 8)
		port map(
			clk => clk,
			clk_en => clk_en,
			reset => reset,
			value => value,
			output => output);
end;