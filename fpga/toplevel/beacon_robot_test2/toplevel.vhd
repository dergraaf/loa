-------------------------------------------------------------------------------
-- Title      : Mobile Beacon
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : strongly-typed
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2012-03-31
-- Last update: 2012-05-01
-- Platform   : Spartan 3A-200
-------------------------------------------------------------------------------
-- Description: Test file for testing the Block SRAM in hardware with double
-- buffering.
-- 
-- A process writes some test data into the Block RAM immediately after reset
-- so that it can be read from the SPI bus.
--
-- What to test with the STM:
--
-- 1) The process starts to write data to the BRAM.
-- 2) When it finishes it assigns ready_i = '1'.
-- 3) This signalises the STM that new data is available by pulling IRQ = '1'.
-- 4) The STM can read data from the BRAM with the SPI slave.
-- 5) The STM signalises that it has finished reading by sending a pulse on
--    ACK. 
-- 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.spislave_pkg.all;

use work.reg_file_pkg.all;
use work.motor_control_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.utils_pkg.all;
use work.ir_rx_module_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- Connections to the STM32F407
      -- SPI
      cs_np  : in  std_logic;
      sck_p  : in  std_logic;
      miso_p : out std_logic;
      mosi_p : in  std_logic;

      -- hardwired
      ir_irq_p : out std_logic;
      us_irq_p : out std_logic;

      ir_ack_p : in std_logic;
      us_ack_p : in std_logic;

      -- 4 MBit SRAM CY7C1049DV33-10ZSXI (428-1982-ND)
      sram_addr_p : out   std_logic_vector(18 downto 0);
      sram_data_p : inout std_logic_vector(7 downto 0);
      sram_oe_np  : out   std_logic;
      sram_we_np  : out   std_logic;
      sram_ce_np  : out   std_logic;

      -- US TX
      us_tx0_p : out half_bridge_type;
      us_tx1_p : out half_bridge_type;
      us_tx2_p : out half_bridge_type;

      -- US RX: one LTC2351 ADC
      us_rx_spi_in_p  : in  adc_ltc2351_spi_in_type;
      us_rx_spi_out_p : out adc_ltc2351_spi_out_type;

      -- IR TX
      ir_tx_p : out std_logic;

      -- IR RX: two LTC2351 ADC
      ir_rx_spi_out_p : out adc_ltc2351_spi_out_type;
      ir_rx0_spi_in_p : in  adc_ltc2351_spi_in_type;

      ir_rx1_spi_in_p : in adc_ltc2351_spi_in_type;

      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is

   constant BASE_ADDR_REG           : natural := 16#0000#;
   constant BASE_ADDR_REG_FILE_BRAM : natural := 16#0400#;

   -- reset is unused in this design!
   signal reset : std_logic := '0';

   signal register_out : std_logic_vector(15 downto 0);
   signal register_in  : std_logic_vector(15 downto 0);

   -- Modulation
   signal mod_cnt             : natural                      := 0;
   signal modulation_us       : std_logic_vector(2 downto 0) := (others => '0');
   signal clk_modulation_us_s : std_logic                    := '0';

   -- Synchronise inputs
   signal ir_ack_r : std_logic_vector(1 downto 0) := (others => '0');
   signal ir_ack   : std_logic;

   signal us_ack_r : std_logic_vector(1 downto 0) := (others => '0');
   signal us_ack   : std_logic;

   -- Connection to the Busmaster
   signal bus_from_spi : busmaster_out_type;
   signal bus_i        : busmaster_in_type;

   -- Outputs form the Bus devices
   signal bus_register_out      : busdevice_out_type;
   signal bus_reg_file_bram_out : busdevice_out_type;


   -- Common clock enable for ADCs
   signal clk_adc_en_s : std_logic;

   -- Connections to and from the IR ADCs
   signal ir_rx_module_spi_out : ir_rx_module_spi_out_type;
   signal ir_rx_module_spi_in  : ir_rx_module_spi_in_type;

   -- Bidirectional SRAM pins
   signal sram_data_o  : std_logic_vector(7 downto 0) := (others => '0');
   signal sram_data_i  : std_logic_vector(7 downto 0) := (others => '0');
   signal sram_data_en : std_logic                    := '0';

   -- signals to and from BRAM
   signal bram_data_o : std_logic_vector(35 downto 0);
   signal bram_data_i : std_logic_vector(35 downto 0);
   signal bram_we     : std_logic := '0';
   signal bram_addr   : std_logic_vector(7 downto 0);

   -- debug signal
   signal debug_data_done : std_logic := '0';

begin

   ----------------------------------------------------------------------------
   -- Bus connections
   ----------------------------------------------------------------------------
   bus_i.data <= bus_register_out.data or
                 bus_reg_file_bram_out.data;

   ----------------------------------------------------------------------------
   -- SPI connection to the STM32F4xx and Busmaster for the internal bus
   ----------------------------------------------------------------------------
   spi : spi_slave
      port map (
         miso_p => miso_p,
         mosi_p => mosi_p,
         sck_p  => sck_p,
         csn_p  => cs_np,

         bus_o => bus_from_spi,
         bus_i => bus_i,

         reset => reset,
         clk   => clk);

   ----------------------------------------------------------------------------
   -- 4 MBit SRAM CY7C1049DV33-10ZSXI (428-1982-ND)
   ----------------------------------------------------------------------------
   -- purpose: Bidirectional Interface for SRAM
   -- type   : sequential
   sram_data_p <= sram_data_o when (sram_data_en = '1') else (others => 'Z');
   sram_data_i <= sram_data_p;

   sram_addr_p <= (others => '0');
   sram_ce_np  <= 'Z';
   sram_we_np  <= 'Z';
   sram_oe_np  <= 'Z';

   ----------------------------------------------------------------------------
   -- Single Register
   ----------------------------------------------------------------------------
   preg : peripheral_register
      generic map (
         BASE_ADDRESS => BASE_ADDR_REG)
      port map (
         dout_p => register_out,
         din_p  => register_in,
         bus_o  => bus_register_out,
         bus_i  => bus_from_spi,
         reset  => reset,
         clk    => clk);

   -- test Data
   register_in <= x"abc" & "0000";      -- test data, required by C++

   ----------------------------------------------------------------------------
   -- Block RAM as register
   ----------------------------------------------------------------------------
   --reg_file_bram_1 : entity work.reg_file_bram
   --   generic map (
   --      BASE_ADDRESS => BASE_ADDR_REG_FILE_BRAM)
   --   port map (
   --      bus_o       => bus_reg_file_bram_out,
   --      bus_i       => bus_from_spi,
   --      bram_data_i => bram_data_i,
   --      bram_data_o => bram_data_o,
   --      bram_addr_i => bram_addr,
   --      bram_we_p   => bram_we,
   --      clk         => clk);
   reg_file_bram_double_buffered_1 : reg_file_bram_double_buffered
      generic map (
         BASE_ADDRESS => BASE_ADDR_REG_FILE_BRAM)
      port map (
         bus_o       => bus_reg_file_bram_out,
         bus_i       => bus_from_spi,
         bram_data_i => bram_data_i,
         bram_data_o => bram_data_o,
         bram_addr_i => bram_addr,
         bram_we_p   => bram_we,
         irq_o       => ir_irq_p,
         ack_i       => ir_ack_p,
         ready_i     => debug_data_done,
         enable_o    => open,
         clk         => clk);

   -- purpose: Fills the Bram with some test data
   fill_bram : process (clk) is
      variable addr : unsigned(7 downto 0) := (others => '0');
      variable en   : std_logic            := '1';
   begin  -- process fill_bram
      if rising_edge(clk) then          -- rising clock edge
         if en = '1' then
            bram_we     <= '1';
            bram_addr   <= std_logic_vector(addr);
            -- 8 + 8 + 2 + 8 + 8 + 2 = 36
            bram_data_i <= std_logic_vector(addr) & "0" & std_logic_vector(addr) & "0" &
                           std_logic_vector(addr) & "0" & std_logic_vector(addr) & "0";
            addr := addr + 1;
            if addr = "11111111" then
               debug_data_done <= '1';
            else
               if addr = "00000000" then
                  en              := '0';
                  bram_we         <= '0';
                  debug_data_done <= '0';
               end if;
            end if;
         end if;
      end if;
   end process fill_bram;

   ----------------------------------------------------------------------------
   -- Unconnected pins
   ----------------------------------------------------------------------------
   -- ir_irq_p <= ir_ack_p;
   us_irq_p <= us_ack_p;

   us_rx_spi_out_p.sck  <= '0';
   us_rx_spi_out_p.conv <= '0';

   us_tx0_p.low  <= '0';
   us_tx0_p.high <= '0';

   us_tx1_p.low  <= '0';
   us_tx1_p.high <= '0';

   us_tx2_p.low  <= '0';
   us_tx2_p.high <= '0';

   ir_tx_p <= '0';

   ir_rx_spi_out_p.sck  <= '0';
   ir_rx_spi_out_p.conv <= '0';

   
end structural;
