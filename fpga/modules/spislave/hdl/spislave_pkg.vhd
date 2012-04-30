-------------------------------------------------------------------------------
-- Title      : SPI Slave Package Definition
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spislave_pkg.vhd
-- Author     : cjt@users.sourceforge.net
-- Company    : 
-- Created    : 2011-08-27
-- Last update: 2012-04-29
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;

package spislave_pkg is
  
  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component spi_slave
    port (
      miso_p : out std_logic;
      mosi_p : in  std_logic;
      sck_p  : in  std_logic;
      csn_p  : in  std_logic;

      bus_o : out busmaster_out_type;

      bus_i : in busmaster_in_type;

      reset : in std_logic;
      clk   : in std_logic);
  end component;
  
end spislave_pkg;

-------------------------------------------------------------------------------
