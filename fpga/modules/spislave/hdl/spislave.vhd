-------------------------------------------------------------------------------
-- Title      : SPI Slave, synchronous
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spi_Slave.vhd
-- Author     : cjt@users.sourceforge.net
-- Company    : 
-- Created    : 2011-08-27
-- Last update: 2011-12-19
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-08-27  1.0      calle   Created
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

      reset : in std_logic;
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
      csn      => (others => '1'),
      bit_cnt  => 31,
      bus_addr => (others => '0'),
      bus_do   => (others => '0'),
      bus_re   => '0',
      bus_we   => '0',
      state    => IDLE
      );

begin

   spi_cmb : process (bus_i, csn_p, mosi_p, r, sck_p)

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
            --v.oreg(31 downto 16) := bus_di_p;
            v.oreg(31 downto 16) := bus_i.data;

            v.state   := SEL;
            v.bit_cnt := 31;

         when WR =>
            v.state   := SEL;
            v.bit_cnt := 31;
            
         when others => null;
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
         if reset = '1' then
            r.state    <= idle;
            r.mosi     <= (others => '0');
            r.miso     <= '0';
            r.csn      <= (others => '0');
            r.ireg     <= (others => '0');
            r.oreg     <= X"0000aa55";
            r.bus_addr <= (others => '0');
            r.bit_cnt  <= 0;
            r.bus_do   <= (others => '0');
         else
            r <= rin;
         end if;
      end if;
   end process spi_seq;

end behavioral;

