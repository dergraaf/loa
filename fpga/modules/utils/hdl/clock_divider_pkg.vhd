
library ieee;
use ieee.std_logic_1164.all;

package clock_divider_pkg is
	component clock_divider is
		generic (
			divider : positive := 2 );
		port (
			clk 	: in  std_logic;	--! System clock
			output	: out std_logic		--! Enable output ('1' for one clock cycle)
		);
	end component;
end package clock_divider_pkg;

