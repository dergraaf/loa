-------------------------------------------------------------------------------
-- Title      : SPI Slave, synchronous
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Description: This is an SPI slave that is a busmaster to the local bus.
--              Data can be transfered to and from the bus slaves on the bus.
--
-- Protocol:    The SPI transfers are always 32 bits
--              SPI mode 0, CPOL = 0, CPAH = 0
--              The first 16 bits are the address and the second 16 bits are
--              the data. 
--
--              If the MSB of the address is not set (MSB = '0') a read access
--              to the parallel bus is performed. The result of this read access
--              is retrieved while sending the next 16 bits. The contents of
--              these bits can be used as the address for the next access (read
--              or write).  
--
--              If the MSB of the address is set (MSB = '1') a write access to
--              the parallel bus is performed. 
--              
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.spislave_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity spi_slave is

   port (
      miso_p : out std_logic;
      mosi_p : in  std_logic;
      sck_p  : in  std_logic;
      csn_p  : in  std_logic;

      bus_o : out busmaster_out_type;
      bus_i : in  busmaster_in_type;

      clk   : in std_logic
      );

end spi_slave;

-------------------------------------------------------------------------------

architecture behavioral of spi_slave is

   type spi_slave_states is (IDLE, SEL, WAIT_RD, RD, WR);

   type spi_slave_state_type is record
      ireg     : std_logic_vector(31 downto 0);
      oreg     : std_logic_vector(31 downto 0);
      mosi     : std_logic_vector(1 downto 0);
      miso     : std_logic;
      sck      : std_logic_vector(2 downto 0);
      csn      : std_logic_vector(2 downto 0);
      bit_cnt  : integer range 0 to 31;
      bus_addr : std_logic_vector(14 downto 0);
      bus_do   : std_logic_vector(15 downto 0);
      bus_re   : std_logic;
      bus_we   : std_logic;
      state    : spi_slave_states;
   end record;

   signal r, rin : spi_slave_state_type := (
      ireg     => (others => '0'),
      oreg     => (others => '0'),
      mosi     => (others => '0'),
      miso     => '0',
      sck      => (others => '0'),
      csn      => (others => '0'),
      bit_cnt  => 31,
      bus_addr => (others => '0'),
      bus_do   => (others => '0'),
      bus_re   => '0',
      bus_we   => '0',
      state    => IDLE
      );
   
begin

   spi_cmb : process (bus_i.data, csn_p, mosi_p, r, r.csn(1 downto 0),
                      r.mosi(0), r.sck(1 downto 0), r.state, sck_p)

      variable v                       : spi_slave_state_type;
      variable rising_sck, falling_csn : std_logic;
      
   begin
      v := r;

      v.mosi := r.mosi(0) & mosi_p;
      v.sck  := r.sck(1 downto 0) & sck_p;
      v.csn  := r.csn(1 downto 0) & csn_p;

      rising_sck  := v.sck(1) and not v.sck(2);
      falling_csn := v.csn(2) and not v.csn(1);

      v.bus_we   := '0';
      v.bus_re   := '0';
      v.bus_addr := (others => '0');

      case r.state is
         when IDLE =>
            -- falling chip select 
            if falling_csn = '1' then
               v.state   := SEL;
               v.bit_cnt := 31;
            end if;
            
         when SEL =>
            v.miso := v.oreg(v.bit_cnt);

            if rising_sck = '1' then
               v.ireg(v.bit_cnt) := v.mosi(1);

               -- MSB = '0' => read
               if v.ireg(31) = '0' and v.bit_cnt = 16 then
                  v.bus_addr := v.ireg(30 downto 16);
                  v.bus_re   := '1';
                  v.state    := WAIT_RD;
               end if;

               -- MSB = '1' => write
               if v.ireg(31) = '1' and v.bit_cnt = 0 then
                  v.bus_addr := v.ireg(30 downto 16);
                  v.bus_do   := v.ireg(15 downto 0);
                  v.bus_we   := '1';
                  v.state    := WR;
               end if;

               if not (v.bit_cnt = 0) then
                  v.bit_cnt := v.bit_cnt - 1;
               end if;
            end if;

         -- delay for one clock cycle to give the devices on the bus
         -- some time to output their data
         when WAIT_RD =>
            v.state := RD;
            
         when RD =>
            v.oreg(31 downto 16) := bus_i.data;

            -- reset the bit counter to 31 to make sequential reads possible. 
            v.state   := SEL;
            v.bit_cnt := 31;

         when WR =>
            -- reset the bit counter to 31 to make sequential writes possible.
            v.state   := SEL;
            v.bit_cnt := 31;
      end case;

      if v.csn(1) = '1' then
         v.state := IDLE;
      end if;

      rin <= v;
   end process spi_cmb;

   -- trisate output is generated comb., to reduce risk of external bus hazard
   miso_p <= r.miso when csn_p = '0' else 'Z';

   bus_o.addr <= r.bus_addr;
   bus_o.data <= r.bus_do;
   bus_o.we   <= r.bus_we;
   bus_o.re   <= r.bus_re;

   spi_seq : process (clk)
   begin
      if rising_edge(clk) then
            r <= rin;
      end if;
   end process spi_seq;

end behavioral;

