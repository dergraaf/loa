

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.utils_pkg.all;

package xilinx_block_ram_pkg is
   
   component xilinx_block_ram_dual_port
      generic (
         ADDR_A_WIDTH : positive;
         ADDR_B_WIDTH : positive;
         DATA_A_WIDTH : positive;
         DATA_B_WIDTH : positive);
      port (
         addr_a : in  std_logic_vector(ADDR_A_WIDTH-1 downto 0);
         addr_b : in  std_logic_vector(ADDR_B_WIDTH-1 downto 0);
         din_a  : in  std_logic_vector(DATA_A_WIDTH-1 downto 0);
         din_b  : in  std_logic_vector(DATA_B_WIDTH-1 downto 0);
         dout_a : out std_logic_vector(DATA_A_WIDTH-1 downto 0);
         dout_b : out std_logic_vector(DATA_B_WIDTH-1 downto 0);
         we_a   : in  std_logic;
         we_b   : in  std_logic;
         en_a   : in  std_logic;
         en_b   : in  std_logic;
         ssr_a  : in  std_logic;
         ssr_b  : in  std_logic;
         clk_a  : in  std_logic;
         clk_b  : in  std_logic);
   end component;
   
end xilinx_block_ram_pkg;
