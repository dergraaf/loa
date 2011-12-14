-------------------------------------------------------------------------------
-- Title      : SPI Slave, synchronous
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spi_Slave.vhd
-- Author     : cjt@users.sourceforge.net
-- Company    : 
-- Created    : 2011-08-27
-- Last update: 2011-12-14
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
    --ireg    : out std_logic_vector(31 downto 0);
    --bit_cnt : out integer;

    miso_p : out std_logic;
    mosi_p : in  std_logic;
    sck_p  : in  std_logic;
    csn_p  : in  std_logic;

    bus_o : out busmaster_out_type;
    --bus_do_p   : out std_logic_vector(15 downto 0);
    --bus_addr_p : out std_logic_vector(14 downto 0);
    --bus_we_p   : out std_logic;
    --bus_re_p   : out std_logic;

    bus_i : in busmaster_in_type;
    --bus_di_p   : in  std_logic_vector(15 downto 0);

    reset : in std_logic;
    clk   : in std_logic
    );

end spi_slave;

-------------------------------------------------------------------------------

architecture behavioral of spi_slave is

  type spi_slave_states is (idle, sel, rd, wr);

  type spi_slave_state_type is record
    ireg     : std_logic_vector(31 downto 0);
    oreg     : std_logic_vector(31 downto 0);
    mosi     : std_logic_vector(2 downto 0);
    miso     : std_logic;
    sck      : std_logic_vector(2 downto 0);
    csn      : std_logic_vector(2 downto 0);
    bit_cnt  : integer;                 --range 0 to 15;
    bus_addr : std_logic_vector(14 downto 0);
    bus_do   : std_logic_vector(15 downto 0);
    bus_re   : std_logic;
    bus_we   : std_logic;
    state    : spi_slave_states;
  end record;

  signal r, rin : spi_slave_state_type;

begin

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

  spi_cmb : process (bus_i, csn_p, mosi_p, r, sck_p)
    
    variable v                       : spi_slave_state_type;
    variable rising_sck, falling_csn : std_logic;
    
  begin  -- process spi_cmb
    
    v           := r;
    v.mosi      := v.mosi(1 downto 0) & mosi_p;
    v.sck       := v.sck(1 downto 0) & sck_p;
    v.csn       := v.csn(1 downto 0) & csn_p;
    rising_sck  := v.sck(1) and not v.sck(2);
    falling_csn := v.csn(2) and not v.csn(1);

    v.bus_we   := '0';
    v.bus_re   := '0';
    v.bus_addr := (others => '0');

    case v.state is
      
      when idle =>
        -- falling chip select 
        if falling_csn = '1' then
          v.state   := sel;
          v.bit_cnt := 31;
        end if;
        
      when sel =>
        if rising_sck = '1' then
          v.ireg(v.bit_cnt) := v.mosi(1);
          v.miso            := v.oreg(v.bit_cnt);

          -- MSB = '0' => read
          if v.ireg(31) = '0' and v.bit_cnt = 16 then
            v.bus_addr := v.ireg(30 downto 16);
            v.bus_re   := '1';
            v.state    := rd;
          end if;

          -- MSB = '1' => write
          if v.ireg(31) = '1' and v.bit_cnt = 0 then
            v.bus_addr := v.ireg(30 downto 16);
            v.bus_do   := v.ireg(15 downto 0);
            v.bus_we   := '1';
            v.state    := wr;
          end if;

          if not (v.bit_cnt = 0) then
            v.bit_cnt := v.bit_cnt - 1;
          end if;
        end if;
        
      when rd =>
        --v.oreg(31 downto 16) := bus_di_p;
        v.oreg(31 downto 16) := bus_i.data;

        v.state   := sel;
        v.bit_cnt := 31;

      when wr =>
        v.state   := sel;
        v.bit_cnt := 31;
      when others => null;
    end case;

    if v.csn(1) = '1' then
      v.state := idle;
    end if;

    rin <= v;
    
  end process spi_cmb;


  -- trisate output is generated comb., to reduce risk of external bus hazard
  miso_p <= r.miso when csn_p = '0' else 'Z';

  --bus_addr_p <= r.bus_addr;
  --bus_do_p   <= r.bus_do;
  --bus_we_p   <= r.bus_we;
  --bus_re_p   <= r.bus_re;

  bus_o.addr <= r.bus_addr;
  bus_o.data <= r.bus_do;
  bus_o.we   <= r.bus_we;
  bus_o.re   <= r.bus_re;

  --ireg    <= r.ireg;
  --bit_cnt <= r.bit_cnt;

  spi_seq : process (clk)
  begin  -- process spi_seq
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

