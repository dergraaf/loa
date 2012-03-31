-------------------------------------------------------------------------------
-- Title      : Mobile Beacon
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2012-03-31
-- Last update: 2012-03-31
-- Platform   : Spartan 3A-200
-------------------------------------------------------------------------------
-- Description:
-- ...
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.spislave_pkg.all;

use work.peripheral_register_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- Connections to the STM32F407
      cs_np  : in  std_logic;
      sck_p  : in  std_logic;
      miso_p : out std_logic;
      mosi_p : in  std_logic;

      reset_n : in std_logic;
      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is
   signal reset_r : std_logic_vector(1 downto 0) := (others => '0');
   signal reset   : std_logic;

   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);
   
   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;
	
	-- Outputs form the Bus devices
   signal bus_register_out : busdevice_out_type;
begin
   -- synchronize reset and other signals
   process (clk)
   begin
      if rising_edge(clk) then
         reset_r <= reset_r(0) & reset_n;
      end if;
   end process;

   reset <= not reset_r(1);
	
   ----------------------------------------------------------------------------
   -- SPI connection to the STM32F4xx and Busmaster
   -- for the internal bus
   spi : spi_slave
      port map (
         miso_p => miso_p,
         mosi_p => mosi_p,
         sck_p  => sck_p,
         csn_p  => cs_np,

         bus_o => bus_o,
         bus_i => bus_i,

         reset => reset,
         clk   => clk);
	
   bus_i.data <= bus_register_out.data;

   ----------------------------------------------------------------------------
   -- Register
   preg : peripheral_register
      generic map (
         BASE_ADDRESS => 16#0000#)
      port map (
         dout_p => register_out,
         din_p  => register_in,
         bus_o  => bus_register_out,
         bus_i  => bus_o,
         reset  => reset,
         clk    => clk);
	
   register_in <= x"abc" & "0000";
   --led_np <= not register_out(3 downto 0);

end structural;