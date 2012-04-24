----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:58:42 04/22/2012 
-- Design Name: 
-- Module Name:    ram_toplevel - Behavioural 
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
use IEEE.NUMERIC_STD.all;

library work;
use work.xilinx_block_ram_pkg.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ram_toplevel is
   generic (
      ADDR_A_WIDTH : positive := 11;
      ADDR_B_WIDTH : positive := 10;
      DATA_A_WIDTH : positive := 8;
      DATA_B_WIDTH : positive := 16);

   port (addr_a : in  std_logic_vector(ADDR_A_WIDTH-1 downto 0);
         addr_b : in  std_logic_vector(ADDR_B_WIDTH-1 downto 0);
         din_a  : in  std_logic_vector(DATA_A_WIDTH-1 downto 0);
         din_b  : in  std_logic_vector(DATA_B_WIDTH-1 downto 0);
         dout_a : out std_logic_vector(DATA_A_WIDTH-1 downto 0);
         dout_b : out std_logic_vector(DATA_B_WIDTH-1 downto 0);
         we_a   : in  std_logic;
         we_b   : in  std_logic;
         clk    : in  std_logic);
end ram_toplevel;

architecture Behavioural of ram_toplevel is


begin
   dp1 : xilinx_block_ram_dual_port
      generic map (
         ADDR_A_WIDTH => ADDR_A_WIDTH,
         ADDR_B_WIDTH => ADDR_B_WIDTH,
         DATA_A_WIDTH => DATA_A_WIDTH,
         DATA_B_WIDTH => DATA_B_WIDTH)
      port map (
         addr_a => addr_a,
         addr_b => addr_b,
         din_a  => din_a,
         din_b  => din_b,
         dout_a => dout_a,
         dout_b => dout_b,
         we_a   => we_a,
         we_b   => we_b,
         en_a   => '1',
         en_b   => '1',
         clk_a  => clk,
         clk_b  => clk);

end Behavioural;

