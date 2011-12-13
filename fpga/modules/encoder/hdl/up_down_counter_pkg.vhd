
library ieee;
use ieee.std_logic_1164.all;

package up_down_counter_pkg is
	component up_down_counter is
		generic (
			WIDTH : positive := 8 );
		port (
			clk_en_p	: in  std_logic;	--! Clock enable
			up_down_p	: in  std_logic;	--! '1' = up, '0' = down
		
			value_p		: out std_logic_vector(WITH - 1 downto 0);		
		
			reset		: in  std_logic;	--! Reset counter
	 		clk			: in  std_logic		--! System clock
		);
	end component;
end package;

