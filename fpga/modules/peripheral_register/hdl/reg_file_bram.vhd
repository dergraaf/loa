-------------------------------------------------------------------------------
-- Title      : A Register File Made of Dual Port Block RAM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : reg_file_bram.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-22
-- Last update: 2012-05-01
-- Platform   : Xilinx Spartan 3A
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: A Larger Register File Using Block RAM.
--
--              A dual port block RAM is interfaced to the internal parallel
--              bus.
--              
--              Each SelectRAM in Spartan-3(A/E/AN) has 18432 data bits and can
--              be configured as 1024 address x 16 data bits.
--
--              Port A of Block RAM: connected to the internal parallel bus:
--              1024 addresses of 16 bits
--              1024 address = 10 bits (9 downto 0)
--
--              Port B: used by the internal processes of the design.
--              Same configuration
--
-------------------------------------------------------------------------------
-- Copyright (c) 2012 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.xilinx_block_ram_pkg.all;

-------------------------------------------------------------------------------

entity reg_file_bram is

   generic (
      -- The module uses 10 bits for 1024 addresses and the base address must be aligned.
      -- Valid BASE_ADDRESSes are 0x0000, 0x0400, 0x0800, ...
      BASE_ADDRESS : integer range 0 to 2**15-1);

   port (
      -- Interface to the internal parallel bus.
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      -- Read and write interface to the block RAM for the application.
      bram_data_i : in  std_logic_vector(15 downto 0) := (others => '0');
      bram_data_o : out std_logic_vector(15 downto 0) := (others => '0');
      bram_addr_i : in  std_logic_vector(9 downto 0)  := (others => '0');
      bram_we_p   : in  std_logic                     := '0';

      -- No reset, all signals are initialised.

      clk : in std_logic);

end reg_file_bram;

-------------------------------------------------------------------------------

architecture str of reg_file_bram is

   constant BASE_ADDRESS_VECTOR : std_logic_vector(14 downto 0) :=
      std_logic_vector(to_unsigned(BASE_ADDRESS, 15));

   -- Port A to bus
   constant ADDR_A_WIDTH : positive := 10;
   constant DATA_A_WIDTH : positive := 16;

   -- Port B to application
   constant ADDR_B_WIDTH : positive := 10;
   constant DATA_B_WIDTH : positive := 16;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------

   signal ram_a_addr : std_logic_vector(ADDR_A_WIDTH-1 downto 0) := (others => '0');
   signal ram_a_out  : std_logic_vector(DATA_A_WIDTH-1 downto 0) := (others => '0');
   signal ram_a_in   : std_logic_vector(DATA_A_WIDTH-1 downto 0) := (others => '0');

   signal ram_a_we  : std_logic := '0';
   signal ram_a_en  : std_logic := '0';
   signal ram_a_ssr : std_logic := '0';

   signal ram_b_addr : std_logic_vector(ADDR_B_WIDTH-1 downto 0) := (others => '0');
   signal ram_b_out  : std_logic_vector(DATA_B_WIDTH-1 downto 0) := (others => '0');
   signal ram_b_in   : std_logic_vector(DATA_B_WIDTH-1 downto 0) := (others => '0');

   signal ram_b_we  : std_logic := '0';
   signal ram_b_en  : std_logic := '0';
   signal ram_b_ssr : std_logic := '0';

   --
   signal addr_match_a    : std_logic;
   signal bus_o_enable_d  : std_logic := '0';
   signal bus_o_enable_d2 : std_logic := '0';

begin  -- str

   ----------------------------------------------------------------------------
   -- Connections
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Block RAM as dual port RAM with asymmetrical port widths. 
   ----------------------------------------------------------------------------

   dp_1 : xilinx_block_ram_dual_port
      generic map (
         ADDR_A_WIDTH => ADDR_A_WIDTH,
         ADDR_B_WIDTH => ADDR_B_WIDTH,
         DATA_A_WIDTH => DATA_A_WIDTH,
         DATA_B_WIDTH => DATA_B_WIDTH)
      port map (
         addr_a => ram_a_addr,
         addr_b => ram_b_addr,
         din_a  => ram_a_in,
         din_b  => ram_b_in,
         dout_a => ram_a_out,
         dout_b => ram_b_out,
         we_a   => ram_a_we,
         we_b   => ram_b_we,
         en_a   => ram_a_en,
         en_b   => ram_b_en,
         ssr_a  => ram_a_ssr,
         ssr_b  => ram_b_ssr,
         clk_a  => clk,
         clk_b  => clk);

   ----------------------------------------------------------------------------
   -- Port A: parallel bus
   ----------------------------------------------------------------------------
   -- Always present the address from the parallel bus to the block RAM.
   -- When the bus address matches the address range of the block RAM
   -- route the result of the Block RAM to the paralle bus.
   ram_a_addr <= bus_i.addr(ADDR_A_WIDTH-1 downto 0);
   ram_a_in   <= bus_i.data;

   -- ADDR_A_WIDTH = 10
   -- 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
   --                |<---- match ---->|
   addr_match_a <= '1' when (bus_i.addr(14 downto ADDR_A_WIDTH) = BASE_ADDRESS_VECTOR(14 downto ADDR_A_WIDTH)) else '0';

   -- Always enable RAM
   ram_a_en <= '1';

   -- The block RAM keeps its output latches when EN is '0'. This behaviour is
   -- not compatible with the parallel bus where the bus output must be 0 when
   -- the device is not selected. 

   -- Solution: Use Synchronous Reset of the output latches:
   ram_a_ssr <= '0' when (addr_match_a = '1') and (bus_i.re = '1') else '1';

   -- Write enable
   ram_a_we  <= '1' when (addr_match_a = '1') and (bus_i.we = '1') else '0';

   bus_o.data <= ram_a_out;

   ----------------------------------------------------------------------------
   -- Port B: internal device
   ----------------------------------------------------------------------------

   -- always enable the RAM
   ram_b_en <= '1';

   -- write to the RAM
   ram_b_we <= bram_we_p;

   ram_b_addr  <= bram_addr_i;
   ram_b_in    <= bram_data_i;
   bram_data_o <= ram_b_out;
   
end str;

-------------------------------------------------------------------------------
