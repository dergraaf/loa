
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
	port (
		clk			: in  std_logic;
		reset_n		: in  std_logic;
		led_n		: out std_logic_vector (3 downto 0)
--		sw_n		: in  std_logic_vector (1 downto 0)
	);
end toplevel;

architecture behavioral of toplevel is
	signal reset_r 	: std_logic_vector(1 downto 0) := (others => '0');
	signal reset	: std_logic;
	
	signal led		: std_logic_vector(3 downto 0);
	signal cnt		: integer;
begin
	-- synchronize reset
	process (clk)
	begin
		if rising_edge(clk) then
			reset_r <= reset_r(0) & reset_n;
		end if;
	end process;
	
	reset <= not reset_r(1);
	
	-- blinking led
	process
	begin
		wait until rising_edge(clk);
		if reset = '1' then
			led <= "0010";
			cnt <= 0;
		else
			-- 0...24999999 = 25000000 Takte = 1/2 Sekunde bei 50MHz 
			if cnt < (24999999 - 1) then
				cnt <= cnt + 1;
			else
				cnt <= 0;
				led(0) <= not led(0);
				led(1) <= not led(1);
			end if;
		end if;
	end process;
	
	led_n <= not led;
	
end behavioral;
