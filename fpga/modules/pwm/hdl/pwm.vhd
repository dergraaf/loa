--! 
--! Simple PWM generator
--! 
--! PWM frequency (f_pwm) is: f_pwm = clk / ((2 ^ width) - 1)
--! 
--! Example:
--! clk = 50 MHz
--! clk_en = constant '1' (no prescaler)
--! width = 8 => value = 0..255
--! 
--! => f_pwm = 1/510ns = 0,1960784 MHz = 50/255 MHz 
--! 
--! Value (for width = 8):
--!     0 => output constant low
--!    1 => 254 cycle low, 1 cycle high
--!   127 => 50% (128 cycles low, 127 cycles high)
--!   128 => 50% (127 cycles low, 128 cycles high)
--!   254 => 1 cycle low, 254 cycles high
--!   255 => output constant high
--! 
--! @author		Fabian Greif
--! 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm is
	generic (
		WIDTH	: natural := 12 );
	port (
		reset	: in  std_logic;
		clk		: in  std_logic;
		clk_en	: in  std_logic;
		value	: in  std_logic_vector (width - 1 downto 0);
		output	: out std_logic );
end pwm;

-- ----------------------------------------------------------------------------
architecture simple of pwm is
	signal count 		: integer range 0 to ((2 ** WIDTH) - 2) := 0;
	signal value_buf	: std_logic_vector(width - 1 downto 0) := (others => '0');
begin
	-- Counter
	process
	begin
		wait until rising_edge(clk);
		
		if reset = '1' then
			-- Load new value and reset counter => restart periode
			count <= 0;
			value_buf <= value;
		elsif clk_en = '1' then
			-- counter
			if count < ((2 ** WIDTH) - 2) then
				count <= count + 1;
			else
				count <= 0;
				
				-- Load new value from the shadow register (not active before
				-- the next clock cycle)
				value_buf <= value;
			end if;
		end if;
	end process;
	
	-- Generate Output
	process (clk)
	begin
		wait until rising_edge(clk);
		
		if reset = '1' then
			output <= '0';
		else
			-- comparator for the output
			if count >= to_integer(unsigned(value_buf)) then
				output <= '0';
			else
				output <= '1';
			end if;
		end if;
	end process;
end simple;

