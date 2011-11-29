----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:43:46 08/08/2011 
-- Design Name: 
-- Module Name:    toplevel_nexys2 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library work;
use work.spislave_pkg.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity toplevel_nexys2 is
  port (clk     : in  std_logic;
        reset_p : in  std_logic;
        sck     : in  std_logic;
        miso    : out std_logic;
        mosi    : in  std_logic;
        csn     : in  std_logic;
        led     : out std_logic_vector (7 downto 0);
        sw      : in  std_logic_vector (7 downto 0)
        );
end toplevel_nexys2;

architecture Behavioral of toplevel_nexys2 is

  signal reset_sync : std_logic_vector(1 downto 0) := (others => '0');
  signal led_mux    : std_logic_vector(7 downto 0);

  signal bus_o   : busmaster_out_type;
  signal bus_i   : busmaster_in_type;

  signal reg : std_logic_vector(15 downto 0);
  
begin

  spiSlave_1 : spi_slave
    port map (
      miso_p => miso,
      mosi_p => mosi,
      sck_p  => sck,
      csn_p  => csn,

      bus_o   => bus_o,
      bus_i   => bus_i,
      
      reset => reset_sync(1),
      clk   => clk
      );

  process(clk)
  begin
    if rising_edge(clk) then
      if reset_sync(1) = '1' then
        reg <= (others => '0');
      else
        if bus_o.we = '1' then
          reg <= bus_o.data;
        end if;
      end if;
    end if;

  end process;

  bus_i.data <= reg(15 downto 8) & sw;

  led <= sw when reset_sync(1) = '1' else bus_o.data(7 downto 0);


  process(clk)
  begin
    if rising_edge(clk) then
      reset_sync <= reset_sync(0) & reset_p;
    end if;
  end process;
  
end Behavioral;

