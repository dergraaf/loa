-------------------------------------------------------------------------------
-- Title      : Testbench for design "toplevel"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : toplevel_tb.vhd
-- Author     : fabian  <fabian@rechenknecht>
-- Company    : 
-- Created    : 2013-03-24
-- Last update: 2013-03-25
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2013-03-24  1.0      fabian  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------
entity toplevel_tb is
end toplevel_tb;

-------------------------------------------------------------------------------
architecture testbench of toplevel_tb is

   component toplevel
      port (
         data_p       : in    std_logic_vector(7 downto 0);
         led_p        : out   std_logic_vector (5 downto 0);
         fsmc_data_p  : inout std_logic_vector(15 downto 0);
         fsmc_adv_np  : in    std_logic;
         fsmc_clk_p   : in    std_logic;
         fsmc_oe_np   : in    std_logic;
         fsmc_we_np   : in    std_logic;
         fsmc_cs_np   : in    std_logic;
         fsmc_bl_np   : in    std_logic_vector(1 downto 0);
         fsmc_wait_np : out   std_logic;
         clk          : in    std_logic);
   end component;

   -- component ports
   signal data        : std_logic_vector(7 downto 0);
   signal led         : std_logic_vector (5 downto 0);
   signal fsmc_data   : std_logic_vector(15 downto 0);
   signal fsmc_adv_n  : std_logic;
   signal fsmc_clk    : std_logic;
   signal fsmc_oe_n   : std_logic;
   signal fsmc_we_n   : std_logic;
   signal fsmc_cs_n   : std_logic;
   signal fsmc_bl_n   : std_logic_vector(1 downto 0);
   signal fsmc_wait_n : std_logic;

   -- clock
   signal clk : std_logic := '1';

begin  -- testbench

   -- component instantiation
   DUT : toplevel
      port map (
         data_p       => data,
         led_p        => led,
         fsmc_data_p  => fsmc_data,
         fsmc_adv_np  => fsmc_adv_n,
         fsmc_clk_p   => fsmc_clk,
         fsmc_oe_np   => fsmc_oe_n,
         fsmc_we_np   => fsmc_we_n,
         fsmc_cs_np   => fsmc_cs_n,
         fsmc_bl_np   => fsmc_bl_n,
         fsmc_wait_np => fsmc_wait_n,
         clk          => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   wavegen : process
   begin
      wait until rising_edge(clk);
   end process wavegen;

end testbench;
