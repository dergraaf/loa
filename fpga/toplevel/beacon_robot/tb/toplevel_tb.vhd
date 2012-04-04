-------------------------------------------------------------------------------
-- Title      : Testbench for design "beacon_robot"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : toplevel_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2012-04-03
-- Last update: 2012-04-03
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.spislave_pkg.all;
use work.bus_pkg.all;
use work.motor_control_pkg.all;

-------------------------------------------------------------------------------

entity toplevel_tb is

end toplevel_tb;

-------------------------------------------------------------------------------

architecture tb of toplevel_tb is

   component toplevel is
      port (
         us_tx0_p : out half_bridge_type;
         us_tx1_p : out half_bridge_type;
         us_tx2_p : out half_bridge_type;
         ir_tx_p  : out std_logic;
         cs_np    : in  std_logic;
         sck_p    : in  std_logic;
         miso_p   : out std_logic;
         mosi_p   : in  std_logic;
         reset_n  : in  std_logic;
         clk      : in  std_logic);
   end component toplevel;

   -- component ports
   signal us_tx0  : half_bridge_type;
   signal us_tx1  : half_bridge_type;
   signal us_tx2  : half_bridge_type;
   signal ir_tx   : std_logic;
   signal cs_n    : std_logic := '1';
   signal sck     : std_logic;
   signal miso    : std_logic;
   signal mosi    : std_logic;
   signal reset_n : std_logic := '1';
   signal clk     : std_logic := '0';

begin  -- tb

   toplevel_1 : entity work.toplevel
      port map (
         us_tx0_p => us_tx0,
         us_tx1_p => us_tx1,
         us_tx2_p => us_tx2,
         ir_tx_p  => ir_tx,
         cs_np    => cs_n,
         sck_p    => sck,
         miso_p   => miso,
         mosi_p   => mosi,
         reset_n  => reset_n,
         clk      => clk);

   -- clock generation
   Clk <= not Clk after 5.0 NS;

   process
   begin
      wait for 25 NS;
      reset_n <= '0';
   end process;

  

end tb;

