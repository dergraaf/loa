-------------------------------------------------------------------------------
-- Title      : reg_file_bram_double_buffered.vhd
-- Project    : 
-------------------------------------------------------------------------------
-- File       : reg_file_bram_double_buffered.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-22
-- Last update: 2012-04-23
-- Platform   : Xilinx Spartan 3A
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: A Larger Read-Only Register File Using Block RAM.
--
--              A dual port block RAM is interfaced to the internal parallel
--              bus and double buffering is implemented. Double buffering
--              guarantees that the data read by the SPI slave is not
--              comprimised while new data is written to the block RAM.
--              If no double buffering was implemented new and old data may get
--              mixed up.
--
--              This register file was designed for the Goertzel algorithm.
--              It was implemented with a calc width of 18 bits (because the
--              mulipliers are 18 bits wide). The result and the intermediate
--              data are two words of 18 bits so a data width of 36 bits was
--              chosen. This fits perfectly well to the BlockRAM.
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
      BASE_ADDRESS : integer range 0 to 32767);

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
      irq_p : out std_logic;

      -- Get an acknowledge from the STM that all results are fetched. 
      ack_p : in std_logic;

      -- Get informed by the application that it has written a new set of results
      -- to the block RAM.
      ready_p : in std_logic;

      -- Allow the application to write new data to the block RAM.
      enable_p : out std_logic;

      -- No reset, all signals are initialised.

      clk : in std_logic);

end reg_file_bram_double_buffered;

-------------------------------------------------------------------------------

architecture str of reg_file_bram_double_buffered is

   constant BASE_ADDRESS_VECTOR : std_logic_vector(14 downto 0) :=
      std_logic_vector(to_unsigned(BASE_ADDRESS, 15));

   -- Port A to bus
   constant ADDR_A_WIDTH : positive := 10;
   constant DATA_A_WIDTH : positive := 18;

   -- Port B to application
   constant ADDR_B_WIDTH : positive := 9;
   constant DATA_B_WIDTH : positive := 36;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------

   signal addr_a_s : std_logic_vector(ADDR_A_WIDTH-1 downto 0) := (others => '0');
   signal dout_a_s : std_logic_vector(DATA_A_WIDTH-1 downto 0) := (others => '0');

   signal addr_b_s : std_logic_vector(ADDR_B_WIDTH-1 downto 0) := (others => '0');
   signal dout_b_s : std_logic_vector(DATA_B_WIDTH-1 downto 0) := (others => '0');
   signal din_b_s  : std_logic_vector(DATA_B_WIDTH-1 downto 0) := (others => '0');

   signal we_b_s : std_logic := '0';

   signal data_bus_out : std_logic_vector(15 downto 0) := (others => '0');

   -- Call both 
   signal bank_x : std_logic := '0';
   signal bank_y : std_logic := '1';
   
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
   ----------------------------------------------------------------------------
   double_buffering_1 : entity work.double_buffering
      port map (
         ready_p  => ready_p,
         enable_p => enable_p,
         irq_p    => irq_p,
         ack_p    => ack_p,
         bank_p   => bank_x,
         clk      => clk);

   bank_y <= not bank_x;

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
         addr_a => addr_a_s,
         addr_b => addr_b_s,
         din_a  => (others => '0'),
         din_b  => din_b_s,
         dout_a => dout_a_s,
         dout_b => dout_b_s,
         we_a   => '0',
         we_b   => we_b_s,
         en_a   => '1',
         en_b   => '1',
         clk_a  => clk,
         clk_b  => clk);

   ----------------------------------------------------------------------------
   -- Port B
   ----------------------------------------------------------------------------
   -- Transfer data to and from the application to and from the RAM
   -- Do the bank switching here. 
   -- 9         =  1     +    8 
   addr_b_s    <= bank_y & bram_addr_i;
   din_b_s     <= bram_data_i;
   we_b_s      <= bram_we_p;
   bram_data_o <= dout_b_s;

   -- Transfer data from bus to register
   -- Not implemented, the register is read only form the bus. 

   -----------------------------------------------------------------------------
   -- Port A: parallel data bus
   ----------------------------------------------------------------------------
   -- Output mux to the bus
   -- always present the address to the block RAM and output (others => '0')
   -- if we are not selected).
   -- Do the bank switching here. 
   -----------------------------------------------------------------------------
   -- 10      =      1  +                9
   addr_a_s <= bank_x & bus_i.addr(8 downto 0);

   -- upper 16 bits of RAM (most significant bits of Q13 number)
   bus_o.data <= dout_a_s(17 downto 2) when
                 (bus_i.addr(14 downto 9) = BASE_ADDRESS_VECTOR(14 downto 9)) and bus_i.re = '1' else (others => '0');


end str;

-------------------------------------------------------------------------------
