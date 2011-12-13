
library ieee;
use ieee.std_logic_1164.all;

package pwm_pkg is
	component pwm is
	generic ( WIDTH : natural := 12 );	--! Number of bits used for the PWM (12bit => 0..4095)
	port (
		reset	: in  std_logic;		--! High active, Restarts the PWM period
		clk 	: in  std_logic;		--! system clock
		clk_en	: in  std_logic;		--! clock enable
		value 	: in  std_logic_vector(WIDTH - 1 downto 0);
		output	: out std_logic );
	end component;
end package pwm_pkg;

