-------------------------------------------------------------------------------
-- Title      : Xilinx Dual Port RAM with asymmetric port widths. 
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: VHDL template for Xilinx Block RAM
--
-- True generic VHDL memory interface without instantiation of device specific
-- primitives. Asymmetrical port width are possible and can be both simulated
-- with GHDL and sythesized with Xilinx XST, which recognises the primitives.
--
-- Synchronous, Dual Port RAM, no parity,
-- "read-first" behaviour, which is the recommended behaviour. 
--
-- Possible configurations per port are (see xapp463.pdf):
--
--              +-----------+------+------+
--              |           | Addr | Data |
--              | Addresses | Bits | Bits |
--              +-----------+------+------+
--              |       16K |   14 |    1 |
--              |        8K |   13 |    2 |
--              |        4K |   12 |    4 |
--              |        2K |   11 |    8 |
--              |        2K |   11 |    9 |
--              |        1K |   10 |   16 |
--              |        1K |   10 |   18 |
--              |       512 |    9 |   32 |
--              |       512 |    9 |   36 |
--              |       256 |    8 |   72 |
--              +-----------+------+------+
--
-- To synthesize this HDL template with Xilinx XST it is necessary to choose the "new parser". 
-- 1) Right-click on "Synthesize - XST"
-- 2) Process Properties 
-- 3) Change Property Display Level to Advanced
-- 4) Add "-use_new_parser yes" to Other XST Command Line Options
-- 
-- You will see that XST recognises the Dual Port Block RAM with 
-- asymmetrical port successfully. 
--
-- =========================================================================
-- *                       Advanced HDL Synthesis                          *
-- =========================================================================
--
--
-- Synthesizing (advanced) Unit <xilinx_block_ram_dual_port>.
-- INFO:Xst:3226 - The RAM <Mram_ram> will be implemented as a BLOCK RAM, absorbing the following register(s): <read_a> <read_b>
--    -----------------------------------------------------------------------
--    | ram_type           | Block                               |          |
--    -----------------------------------------------------------------------
--    | Port A                                                              |
--    |     aspect ratio   | 2048-word x 8-bit                   |          |
--    |     mode           | read-first                          |          |
--    |     clkA           | connected to signal <clk_a>         | rise     |
--    |     weA            | connected to signal <we_a>          | high     |
--    |     addrA          | connected to signal <addr_a>        |          |
--    |     diA            | connected to signal <din_a>         |          |
--    |     doA            | connected to signal <read_a>        |          |
--    -----------------------------------------------------------------------
--    | optimization       | speed                               |          |
--    -----------------------------------------------------------------------
--    | Port B                                                              |
--    |     aspect ratio   | 1024-word x 16-bit                  |          |
--    |     mode           | read-first                          |          |
--    |     clkB           | connected to signal <clk_b>         | rise     |
--    |     weB<3>         | connected to signal <we_b>          | high     |
--    |     weB<2>         | connected to signal <we_b>          | high     |
--    |     weB<1>         | connected to signal <we_b>          | high     |
--    |     weB<0>         | connected to signal <we_b>          | high     |
--    |     addrB          | connected to signal <addr_b>        |          |
--    |     diB            | connected to signal <din_b>         |          |
--    |     doB            | connected to signal <read_b>        |          |
--    -----------------------------------------------------------------------
--    | optimization       | speed                               |          |
--    -----------------------------------------------------------------------
-- Unit <xilinx_block_ram_dual_port> synthesized (advanced).
--
--
--
-------------------------------------------------------------------------------
-- Relationship between port A and B
-------------------------------------------------------------------------------
--
--                      35            18 17            0
-- addr 0x00 at port B: |----data-w----| |----data-v----|
-- addr 0x01 at port B: |----data-y----| |----data-x----|
--
--                      17             0
-- addr 0x00 at port A: |----data-v----|
-- addr 0x01 at port A: |----data-w----|
-- addr 0x02 at port A: |----data-x----|
-- addr 0x03 at port A: |----data-y----|
--
--
-------------------------------------------------------------------------------
-- Copyright (c) 2012 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.utils_pkg.all;
use work.xilinx_block_ram_pkg.all;

entity xilinx_block_ram_dual_port is
   generic (
      ADDR_A_WIDTH : positive := 11;
      ADDR_B_WIDTH : positive := 11;
      DATA_A_WIDTH : positive := 8;
      DATA_B_WIDTH : positive := 8);

   port (
      addr_a : in  std_logic_vector(ADDR_A_WIDTH-1 downto 0);
      addr_b : in  std_logic_vector(ADDR_B_WIDTH-1 downto 0);
      din_a  : in  std_logic_vector(DATA_A_WIDTH-1 downto 0);
      din_b  : in  std_logic_vector(DATA_B_WIDTH-1 downto 0);
      dout_a : out std_logic_vector(DATA_A_WIDTH-1 downto 0);
      dout_b : out std_logic_vector(DATA_B_WIDTH-1 downto 0);
      we_a   : in  std_logic;           -- write enable
      we_b   : in  std_logic;           -- write enable
      en_a   : in  std_logic;           -- enable the port
      en_b   : in  std_logic;           -- enable the port
      ssr_a  : in  std_logic;           -- synchronous reset of output latches
      ssr_b  : in  std_logic;           -- synchronous reset of output latches
      clk_a  : in  std_logic;
      clk_b  : in  std_logic);

end xilinx_block_ram_dual_port;

architecture behavourial of xilinx_block_ram_dual_port is

   constant MIN_WIDTH : positive := minn(DATA_A_WIDTH, DATA_B_WIDTH);
   constant MAX_WIDTH : positive := max(DATA_A_WIDTH, DATA_B_WIDTH);
   constant MAX_SIZE  : positive := max(2**ADDR_A_WIDTH, 2**ADDR_B_WIDTH);
   constant RATIO     : positive := MAX_WIDTH / MIN_WIDTH;

   type ram_type is array (0 to MAX_SIZE-1) of std_logic_vector(MIN_WIDTH-1 downto 0);

   shared variable ram : ram_type := (others => (others => '0'));

   signal reg_a : std_logic_vector(DATA_A_WIDTH-1 downto 0) := (others => '0');
   signal reg_b : std_logic_vector(DATA_B_WIDTH-1 downto 0) := (others => '0');
   
begin  -- behavourial
   ram_proc : process (clk_a)
      variable read_a : std_logic_vector(DATA_A_WIDTH-1 downto 0) := (others => '0');
   begin  -- process ram_proc
      if rising_edge(clk_a) then
         if en_a = '1' then
            if ssr_a = '1' then
               read_a := (others => '0');
            else
               read_a := ram(conv_integer(addr_a));
            end if;
            if (we_a = '1') then
               ram(conv_integer(addr_a)) := din_a;
            end if;
         end if;  -- en_a
         reg_a <= read_a;
      end if;
   end process ram_proc;

   ram_b_proc : process(clk_b)
      variable read_b : std_logic_vector(DATA_B_WIDTH-1 downto 0) := (others => '0');
   begin  -- process ram_b_proc
      if rising_edge(clk_b) then
         if en_b = '1' then
            if RATIO = 1 then
               -- symmetrical port widths
               if ssr_b = '1' then
                  read_b := (others => '0');
               else
                  read_b := ram(conv_integer(addr_b));
               end if;
               if we_b = '1' then
                  ram(conv_integer(addr_b)) := din_b;
               end if;
            else
               -- RATIO != 1, asymmetrical port widths
               if ssr_b = '1' then
                  read_b := (others => '0');
               else
                  for i in 0 to RATIO-1 loop
                     read_b((i+1)*MIN_WIDTH-1 downto i*MIN_WIDTH) := ram(conv_integer(addr_b & conv_std_logic_vector(i, log2(RATIO))));
                  end loop;
               end if;
               if we_b = '1' then
                  for i in 0 to RATIO-1 loop
                     ram(conv_integer(addr_b & conv_std_logic_vector(i, log2(RATIO)))) := din_b((i+1)*MIN_WIDTH-1 downto i*MIN_WIDTH);
                  end loop;  -- i
               end if;
            end if;  -- ratio = 1
         end if;  -- en_b = '1'
         reg_b <= read_b;
      end if;
   end process ram_b_proc;

   dout_a <= reg_a;
   dout_b <= reg_b;
   
end behavourial;
