-------------------------------------------------------------------------------
-- Title      : reg_file_bram_double_buffered.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : reg_file_bram_double_buffered.vhd
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
--              bus and double buffering is implemented. Double buffering
--              guarantees that the data read by the SPI slave is not
--              comprimised while new data is written to the block RAM by the
--              other component.
--              If no double buffering was implemented new and old data may get
--              mixed up.
--
--              This register file was designed for the Goertzel algorithm.
--              It was implemented with a calc width of 18 bits (because the
--              mulipliers are 18 bits wide). The result and the intermediate
--              data are two words of 18 bits so a data width of 36 bits was
--              chosen. This fits perfectly well to the Block RAM.
--
--              Each SelectRAM in Spartan-3(A/E/AN) has 18432 data bits and can
--              be configured as 512 address x 36 data bits.
--
--              Double buffering is implemented by toggeling the MSB of the
--              address. 
--
--              Port A: parallel bus:
--              2 x 512 addresses of 18 bits, lower two data bits are discarded
--              512 address = 9 bits (8 downto 0)
--
--              Port B: Goertzel Algorithm:
--              2 x 256 addresses of 36 bits
--              256 addresses = 8 bits (7 downto 0)
--
-------------------------------------------------------------------------------
-- Todo:        * Generic widths
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
use work.utils_pkg.all;

-------------------------------------------------------------------------------

entity reg_file_bram_double_buffered is

   generic (
      -- The module uses 9 bits for 512 addresses and the base address must be aligned.
      -- Valid BASE_ADDRESSes are 0x0000, 0x0200, 0x0400, 0x0600, ...
      BASE_ADDRESS : integer range 0 to 2**15-1);

   port (
      -- Interface to the internal parallel bus.
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      -- Read and write interface to the block RAM for the application.
      bram_data_i : in  std_logic_vector(35 downto 0);
      bram_data_o : out std_logic_vector(35 downto 0);
      bram_addr_i : in  std_logic_vector(7 downto 0);
      bram_we_p   : in  std_logic;

      -- Inform the STM that new results are ready to be fetched. 
      irq_o : out std_logic;

      -- Get an acknowledge from the STM that all results are fetched. 
      ack_i : in std_logic;

      -- Get informed by the application that it has written a new set of results
      -- to the block RAM.
      ready_i : in std_logic;

      -- Allow the application to write new data to the block RAM.
      enable_o : out std_logic;

      -- No reset, all signals are initialised.

      clk : in std_logic);

end reg_file_bram_double_buffered;

-------------------------------------------------------------------------------

architecture str of reg_file_bram_double_buffered is

   ----------------------------------------------------------------------------
   -- Configuration
   ----------------------------------------------------------------------------
   constant BASE_ADDRESS_VECTOR : std_logic_vector(14 downto 0) :=
      std_logic_vector(to_unsigned(BASE_ADDRESS, 15));

   -- Port A to bus
   constant ADDR_A_WIDTH : positive := 10;
   constant DATA_A_WIDTH : positive := 18;

   -- Port B to application
   constant ADDR_B_WIDTH : positive := 9;
   constant DATA_B_WIDTH : positive := 36;

   ----------------------------------------------------------------------------
   -- Types
   ----------------------------------------------------------------------------
   type ram_a_in_type is record
      addr : std_logic_vector(ADDR_A_WIDTH-1 downto 0);
      data : std_logic_vector(DATA_A_WIDTH-1 downto 0);
      we   : std_logic;
      en   : std_logic;
      ssr  : std_logic;
   end record;

   type ram_a_out_type is record
      data : std_logic_vector(DATA_A_WIDTH-1 downto 0);
   end record;

   type ram_b_in_type is record
      addr : std_logic_vector(ADDR_B_WIDTH-1 downto 0);
      data : std_logic_vector(DATA_B_WIDTH-1 downto 0);
      we   : std_logic;
      en   : std_logic;
      ssr  : std_logic;
   end record;

   type ram_b_out_type is record
      data : std_logic_vector(DATA_B_WIDTH-1 downto 0);
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------

   signal ram_a_in  : ram_a_in_type;
   signal ram_a_out : ram_a_out_type;

   signal ram_b_in  : ram_b_in_type;
   signal ram_b_out : ram_b_out_type;

   signal data_bus_out : std_logic_vector(15 downto 0) := (others => '0');

   signal bank   : std_logic := '0';
   signal bank_x : std_logic;
   signal bank_y : std_logic;

   signal addr_match_a : std_logic;
   
begin  -- str

   ----------------------------------------------------------------------------
   -- Connections
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Bank switching
   -- Call the banks X and Y to not confuse with Port A and B of the Dual port
   -- RAM.
   -- 
   -- Signals:
   -- ----------------
   -- irq_p    to   bus
   -- ack_p    form bus
   -- ready_p  from app
   -- enable_p to   app
   -- 
   ---------------------------------------------------------------------------
   bank_x <= bank;
   bank_y <= not bank;

   double_buffering_1 : entity work.double_buffering
      port map (
         ready_p  => ready_i,
         enable_p => enable_o,
         irq_p    => irq_o,
         ack_p    => ack_i,
         bank_p   => bank,
         clk      => clk);

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
         addr_a => ram_a_in.addr,
         addr_b => ram_b_in.addr,
         din_a  => ram_a_in.data,
         din_b  => ram_b_in.data,
         dout_a => ram_a_out.data,
         dout_b => ram_b_out.data,
         we_a   => ram_a_in.we,
         we_b   => ram_b_in.we,
         en_a   => ram_a_in.en,
         en_b   => ram_b_in.en,
         ssr_a  => ram_a_in.ssr,
         ssr_b  => ram_b_in.ssr,
         clk_a  => clk,
         clk_b  => clk);

   ----------------------------------------------------------------------------
   -- Port B
   ----------------------------------------------------------------------------
   -- Transfer data to and from the application to and from the RAM
   -- Do the bank switching here. 
   -- 9           =  1     +    8 
   ram_b_in.addr <= bank_y & bram_addr_i;
   ram_b_in.data <= bram_data_i;
   ram_b_in.en   <= '1';
   ram_b_in.we   <= bram_we_p;
   ram_b_in.ssr  <= '0';
   bram_data_o   <= ram_b_out.data;

   -----------------------------------------------------------------------------
   -- Port A: parallel data bus
   ----------------------------------------------------------------------------
   -- enable
   ram_a_in.en <= '1';

   -- Always present the address from the parallel bus to the block RAM.
   -- When the bus address matches the address range of the block RAM
   -- route the result of the Block RAM to the parallel bus.
   -- Do the bank switching here. 
   -----------------------------------------------------------------------------
   -- 10          =      1 +                9
   ram_a_in.addr <= bank_x & bus_i.addr(8 downto 0);
   ram_a_in.data <= "00" & bus_i.data;

   addr_match_a <= '1' when (bus_i.addr(14 downto 9) = BASE_ADDRESS_VECTOR(14 downto 9)) else '0';

   -- The block RAM keeps its output latches when EN is '0'. This behaviour is
   -- not compatible with the parallel bus where the bus output must be 0 when
   -- the device is not selected. 

   -- Solution: Use Synchronous Reset of the output latches:
   ram_a_in.ssr <= '0' when (addr_match_a = '1') and (bus_i.re = '1') else '1';

   -- Write enable
   ram_a_in.we <= '1' when (addr_match_a = '1') and (bus_i.we = '1') else '0';

   -- upper 16 bits of RAM (most significant bits of Q13 number)
   bus_o.data <= ram_a_out.data(17 downto 2);
   
end str;

-------------------------------------------------------------------------------
