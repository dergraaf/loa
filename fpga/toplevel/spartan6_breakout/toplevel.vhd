-------------------------------------------------------------------------------
-- Title      : Captain Drive
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
-- Main control board of the 2012 robot "captain".
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
--use work.bus_pkg.all;
use work.utils_pkg.all;
--use work.peripheral_register_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- Connections to the STM32F103
      data_p : in std_logic_vector(7 downto 0);
      -- TODO      

      -- Internal connections
      led_p : out std_logic_vector (5 downto 0);

      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is
--   signal register_out : std_logic_vector(15 downto 0);
--   signal register_in  : std_logic_vector(15 downto 0);
   
--   signal reset : std_logic := '0';
	signal led_clock_en : std_logic := '0';
	signal led : std_logic_vector(5 downto 0) := (others => '0');
   
   -- Connection to the Busmaster
--   signal bus_o : busmaster_out_type;
--   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
--   signal bus_register_out : busdevice_out_type;
begin
   ----------------------------------------------------------------------------
   -- SPI connection to the STM32F4xx and Busmaster
   -- for the internal bus
--   spi : spi_slave
--      port map (
--         miso_p => miso_p,
--         mosi_p => mosi_p,
--         sck_p  => sck_p,
--         csn_p  => cs_np,
--
--         bus_o => bus_o,
--         bus_i => bus_i,
--
--         reset => reset,
--         clk   => clk);

--   bus_i.data <= bus_register_out.data;

   ----------------------------------------------------------------------------
   -- Register
--   preg : peripheral_register
--      generic map (
--         BASE_ADDRESS => 16#0000#)
--      port map (
--         dout_p => register_out,
--         din_p  => register_in,
--         bus_o  => bus_register_out,
--         bus_i  => bus_o,
--         reset  => reset,
--         clk    => clk);

--   register_in <= x"4600";
	
   ----------------------------------------------------------------------------
	led_clk : clock_divider
		generic map (
			DIV => 25000000)
		port map (
			clk_out_p => led_clock_en,
			clk       => clk);
	
	process (clk)
	begin
		if rising_edge(clk) then
			if led_clock_en = '1' then
				led(5) <= not led(5);
         end if;
     end if;
   end process;
	
   led(4 downto 0) <= "00000";	--not register_out(3 downto 0);
	led_p <= led;
end structural;
