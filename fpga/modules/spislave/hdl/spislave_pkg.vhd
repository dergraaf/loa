-------------------------------------------------------------------------------
-- Title      : SPI Slave Package Definition
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spislave_pkg.vhd
-- Author     : cjt@users.sourceforge.net
-- Company    : 
-- Created    : 2011-08-27
-- Last update: 2011-11-04
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-08-27  1.0      calle	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

package spislave_pkg is

  type busmaster_out_type is record
    addr : std_logic_vector(14 downto 0);
    data   : std_logic_vector(15 downto 0);
    re   : std_logic;
    we   : std_logic;
  end record;

  type busmaster_in_type is record
    data : std_logic_vector(15 downto 0);
  end record;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component spi_slave
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
    clk   : in std_logic);
  end component;
  
end spislave_pkg;

-------------------------------------------------------------------------------
