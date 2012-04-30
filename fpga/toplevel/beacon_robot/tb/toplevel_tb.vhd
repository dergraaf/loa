-------------------------------------------------------------------------------
-- Title      : Testbench for design "beacon_robot"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : toplevel_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2012-04-03
-- Last update: 2012-04-28
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.spislave_pkg.all;
use work.bus_pkg.all;
use work.motor_control_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.uss_tx_pkg.all;

-------------------------------------------------------------------------------

entity toplevel_tb is

end toplevel_tb;

-------------------------------------------------------------------------------

architecture tb of toplevel_tb is

   component toplevel
      port (
         cs_np           : in    std_logic;
         sck_p           : in    std_logic;
         miso_p          : out   std_logic;
         mosi_p          : in    std_logic;
         
         sram_addr_p     : out   std_logic_vector(18 downto 0);
         sram_data_p     : inout std_logic_vector(7 downto 0);
         sram_oe_np      : out   std_logic;
         sram_we_np      : out   std_logic;
         sram_ce_np      : out   std_logic;
         
         us_tx0_p        : out   half_bridge_type;
         us_tx1_p        : out   half_bridge_type;
         us_tx2_p        : out   half_bridge_type;
         
         us_rx_spi_in_p  : in    adc_ltc2351_spi_in_type;
         us_rx_spi_out_p : out   adc_ltc2351_spi_out_type;
         
         ir_tx_p         : out   std_logic;
         
         ir_rx_spi_out_p : out   adc_ltc2351_spi_out_type;
         ir_rx0_spi_in_p : in    adc_ltc2351_spi_in_type;
         ir_rx1_spi_in_p : in    adc_ltc2351_spi_in_type;

         ir_ack_p : in std_logic;
         ir_irq_p : out std_logic;

         us_ack_p : in std_logic;
         us_irq_p : out std_logic;
         
         clk             : in    std_logic);
   end component;

   -- signals for component ports
   signal us_tx0 : half_bridge_type;
   signal us_tx1 : half_bridge_type;
   signal us_tx2 : half_bridge_type;

   signal ir_tx : std_logic;

   signal cs_n : std_logic := '1';
   signal sck  : std_logic;
   signal miso : std_logic;
   signal mosi : std_logic;
   signal irq  : std_logic;

   signal sram_addr : std_logic_vector(18 downto 0) := (others => '0');
   signal sram_data : std_logic_vector(7 downto 0) := (others => '0');
   signal sram_oe_n : std_logic := '1';
   signal sram_we_n : std_logic := '1';
   signal sram_ce_n : std_logic := '1';

   signal us_rx_spi_in : adc_ltc2351_spi_in_type;
   signal us_rx_spi_out : adc_ltc2351_spi_out_type;

   signal ir_rx0_spi_in : adc_ltc2351_spi_in_type;
   signal ir_rx1_spi_in : adc_ltc2351_spi_in_type;
   signal ir_rx_spi_out : adc_ltc2351_spi_out_type;

   
   signal reset_n : std_logic := '1';
   signal clk     : std_logic := '0';

begin  -- tb

   toplevel_1 : toplevel
      port map (
         cs_np  => cs_n,
         sck_p  => sck,
         miso_p => miso,
         mosi_p => mosi,

         sram_addr_p => sram_addr,
         sram_data_p => sram_data,
         sram_oe_np   => sram_oe_n,
         sram_we_np   => sram_we_n,
         sram_ce_np   => sram_ce_n,

         us_tx0_p        => us_tx0,
         us_tx1_p        => us_tx1,
         us_tx2_p        => us_tx2,
         
         us_rx_spi_in_p  => us_rx_spi_in,
         us_rx_spi_out_p => us_rx_spi_out,
         
         ir_tx_p         => ir_tx,
         ir_rx_spi_out_p => ir_rx_spi_out,
         ir_rx0_spi_in_p => ir_rx0_spi_in,
         ir_rx1_spi_in_p => ir_rx1_spi_in,

         ir_ack_p => '0',
         ir_irq_p => open,

         us_ack_p => '0',
         us_irq_p => open,
         
         clk             => clk);

   -- clock generation
   Clk <= not Clk after 5.0 ns;

   process
   begin
      wait for 25 ns;
      reset_n <= '0';
   end process;

   

end tb;

