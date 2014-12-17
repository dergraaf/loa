-------------------------------------------------------------------------------
-- Title      : Testbench for design "beacon_robot"
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.hdlc_pkg.all;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.fifo_sync_pkg.all;
use work.uart_pkg.all;
use work.utils_pkg.all;

use work.uart_tb_pkg.all;

-------------------------------------------------------------------------------
entity toplevel_tb is
end toplevel_tb;

-------------------------------------------------------------------------------
architecture tb of toplevel_tb is
	component toplevel
		port(
			clk  : in  std_logic;
			rsrx : in  std_logic;
			rstx : out std_logic;
			led  : out std_logic_vector(7 downto 0);
			sw   : in  std_logic_vector(7 downto 0));
	end component;

	signal clk  : std_logic := '0';
	signal rsrx : std_logic := '1';
	signal rstx : std_logic := '1';

begin
	DUT_toplevel : toplevel
		port map(
			clk  => clk,
			rsrx => rsrx,
			rstx => rstx,
			led  => open,
			sw   => x"aa"
		);

	-- clock generation
	Clk <= not Clk after 10 ns;

	process
	begin
		wait for 25 ns;
		--reset_n <= '0';

		wait for 10 us;

		uart_transmit(rsrx, "0" & x"42", 115200);

		uart_transmit(rsrx, "0" & x"7e", 115200);
		uart_transmit(rsrx, "0" & x"10", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"a2", 115200); -- crc good

		wait for 1 ms;
		uart_transmit(rsrx, "0" & x"7e", 115200);
		uart_transmit(rsrx, "0" & x"20", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"55", 115200);
		uart_transmit(rsrx, "0" & x"55", 115200);
		uart_transmit(rsrx, "0" & x"85", 115200); -- crc good


		wait for 1 ms;
		uart_transmit(rsrx, "0" & x"7e", 115200);
		uart_transmit(rsrx, "0" & x"10", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"a2", 115200); -- crc good

		uart_transmit(rsrx, "0" & x"7e", 115200);
		uart_transmit(rsrx, "0" & x"10", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"a1", 115200); -- crc bad

		uart_transmit(rsrx, "0" & x"7e", 115200);
		uart_transmit(rsrx, "0" & x"10", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"00", 115200);
		uart_transmit(rsrx, "0" & x"a2", 115200); -- crc good

		wait for 100 ms;
	end process;

end tb;

