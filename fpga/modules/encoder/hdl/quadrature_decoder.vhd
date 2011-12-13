-- ----------------------------------------------------------------------------
--! Quadrature Decoder
--! 
--! @code
--!         ___     ___         ___     ___
--! A   ___|   |___|   |_______|   |___|
--!           ___     ___     ___     ___
--! B   _____|   |___|   |___|   |___|   |_
--! 
--! step_p   1 1 1 1 1 1 1 1 0 1 1 1 1 1 1 1
--! dir_p    1 1 1 1 1 1 1 1 1 0 0 0 0 0 0 0 
--! @endcode
--!

library ieee;
use ieee.std_logic_1164.all;

entity quadrature_decoder is
	port (
		a_p			: in  std_logic;
		b_p			: in  std_logic;
		
		step_p_p	: out std_logic;	--! detected step_p ('1' for one clock cycle)
		dir_p_p		: out std_logic;	--! count direction (1 = up, 0 = down)
		error_p_p	: out std_logic		--! illegal transition (two bits change at the same time)
		
		clk			: in  std_logic;	--! system clock		
	);
end quadrature_decoder;

architecture behavioral of quadrature_decoder is 
	signal a_buf	: std_logic_vector(1 downto 0) := "00";
	signal b_buf	: std_logic_vector(1 downto 0) := "00";
begin
	-- edge detection
	process
	begin
		wait until rising_edge(clk);
		
		a_buf <= a_buf(0) & a_p;
		b_buf <= b_buf(0) & b_p;
	end process;
	
	-- signal decoding
	comb: process(a_buf, b_buf)
		variable state : std_logic_vector(3 downto 0);
	begin
		state := a_buf(0) & b_buf(0) & a_buf(1) & b_buf(1);
		case state is
			-- step_p = a_buf(0) xor a_buf(1) xor b_buf(0) xor b_buf(1)
			-- dir_p  = not (a_buf(0) xor b_buf(1))
			
			-- old -> new
			when "0000" => step_p <= '0'; dir_p <= '1'; error_p <= '0';
			when "0001" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
			when "0010" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
			when "0011" => step_p <= '0'; dir_p <= '0'; error_p <= '1';
			when "0100" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
			when "0101" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
			when "0110" => step_p <= '0'; dir_p <= '1'; error_p <= '1';
			when "0111" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
			when "1000" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
			when "1001" => step_p <= '0'; dir_p <= '1'; error_p <= '1';
			when "1010" => step_p <= '0'; dir_p <= '0'; error_p <= '0';
			when "1011" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
			when "1100" => step_p <= '0'; dir_p <= '0'; error_p <= '1';
			when "1101" => step_p <= '1'; dir_p <= '1'; error_p <= '0';
			when "1110" => step_p <= '1'; dir_p <= '0'; error_p <= '0';
			when "1111" => step_p <= '0'; dir_p <= '1'; error_p <= '0';
		end case;
	end process;
end behavioral;
