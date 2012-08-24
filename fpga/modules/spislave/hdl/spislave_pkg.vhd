-------------------------------------------------------------------------------
-- Title      : SPI Slave Package Definition
-- Project    : 
-------------------------------------------------------------------------------
-- File       : spislave_pkg.vhd
-- Author     : cjt@users.sourceforge.net
-- Company    : 
-- Created    : 2011-08-27
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

         clk   : in std_logic);
   end component;

   procedure spiReadWord (
      constant addr : in  natural range 0 to 2**15-1;
      signal sck    : out std_logic;
      signal mosi   : out std_logic;
      signal cs_n   : out std_logic;
      signal clk    : in  std_logic);

   procedure spiWriteWord (
      signal addr : in  std_logic_vector(14 downto 0);
      signal data : in  std_logic_vector(15 downto 0);
      signal sck  : out std_logic;
      signal mosi : out std_logic;
      signal cs_n : out std_logic;
      signal clk  : in  std_logic);

end spislave_pkg;

-------------------------------------------------------------------------------

package body spislave_pkg is

   procedure spiReadWord (
      constant addr : in  natural range 0 to 2**15-1;
      signal sck    : out std_logic;
      signal mosi   : out std_logic;
      signal cs_n   : out std_logic;
      signal clk    : in  std_logic) is
      variable d : std_logic_vector(31 downto 0) := (others => '0');
   begin
      d(31 downto 16) := std_logic_vector(to_unsigned(addr, 16));

      -- start 
      cs_n <= '1';
      sck  <= '0';
      mosi <= '0';
      wait for 50 ns;
      cs_n <= '0';
      wait for 100 ns;

      -- 32 data bits
      for ii in 31 downto 0 loop
         sck  <= '0';
         mosi <= d(ii);
         wait for 50 ns;
         sck  <= '1';
         wait for 50 ns;
      end loop;  -- ii

      -- end
      sck  <= '0';
      wait for 50 ns;
      cs_n <= '1';
      sck  <= '0';
      mosi <= 'Z';
      wait for 100 ns;
   end procedure;

   procedure spiWriteWord (
      signal addr : in  std_logic_vector(14 downto 0);
      signal data : in  std_logic_vector(15 downto 0);
      signal sck  : out std_logic;
      signal mosi : out std_logic;
      signal cs_n : out std_logic;
      signal clk  : in  std_logic) is
      variable d : std_logic_vector(31 downto 0) := (others => '0');
   begin
      d(31) := '1';                     -- MSB = '1' <=> write
      d(30 downto 16) := addr(14 downto 0);
      d(15 downto 0) := data;

      -- start 
      cs_n <= '1';
      sck  <= '0';
      mosi <= '0';
      wait for 50 ns;
      cs_n <= '0';
      wait for 100 ns;

      -- 32 data bits
      for ii in 31 downto 0 loop
         sck  <= '0';
         mosi <= d(ii);
         wait for 50 ns;
         sck  <= '1';
         wait for 50 ns;
      end loop;  -- ii

      -- end
      sck  <= '0';
      wait for 50 ns;
      cs_n <= '1';
      sck  <= '0';
      mosi <= 'Z';
      wait for 100 ns;
   end procedure;

end package body spislave_pkg;
