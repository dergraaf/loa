-------------------------------------------------------------------------------
-- Title : FSMC Test design for Loa v3 Board
-------------------------------------------------------------------------------
-- Author : Carl Treudler (Carl.Treudler@DLR.de)
-------------------------------------------------------------------------------
-- Description: to be used with STM32 {TBD} firmware
-------------------------------------------------------------------------------
-- Copyright (c) 2014, German Aerospace Center (DLR)
-- All Rights Reserved.
-- 
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fsmcslave_pkg.all;
use work.bus_pkg.all;
use work.reg_file_pkg.all;


entity toplevel is
  port (
    fsmc_data   : inout std_logic_vector(15 downto 0);
    fsmc_adv_n  : in    std_logic;
    fsmc_wr_n   : in    std_logic;
    fsmc_cs_n   : in    std_logic;
    fsmc_oe_n   : in    std_logic;
    fsmc_wait_n : out   std_logic;

    debug : out std_logic_vector(5 downto 0);

    led_n : out std_logic;
    clk   : in  std_logic
    );
end toplevel;

architecture behavioral of toplevel is
  signal reset_r : std_logic_vector(1 downto 0) := (others => '0');
  signal reset   : std_logic;

  signal led : std_logic_vector(3 downto 0) := (others => '0');
  signal cnt : integer;

  signal fsmcslave_o : fsmc_in_type;
  signal fsmcslave_i : fsmc_out_type;

  signal bus_o : busmaster_out_type;
  signal bus_i : busmaster_in_type;

  signal reg_o : std_logic_vector(15 downto 0);
  signal reg_i : std_logic_vector(15 downto 0);
  
begin

  -----------------------------------------------------------------------------
  -- FSMC slave to Loa Master Bridge
  -----------------------------------------------------------------------------
  fsmc_interface : fsmcslave
    port map (
      fsmcslave_o => fsmcslave_o,
      fsmcslave_i => fsmcslave_i,
      bus_o       => bus_o,
      bus_i       => bus_i,
      clk         => clk);

  -- tristate driver for datalines, Note: Async ctrl through OEn.
  fsmc_data <= fsmcslave_o.data when fsmc_oe_n = '0' else (others => 'Z');

  fsmcslave_i.adv_n <= fsmc_adv_n;
  fsmcslave_i.wr_n  <= fsmc_wr_n;
  fsmcslave_i.cs_n  <= fsmc_cs_n;
  fsmcslave_i.oe_n  <= fsmc_oe_n;
  fsmcslave_i.data  <= fsmc_data;

  fsmc_wait_n <= '1';

  -----------------------------------------------------------------------------
  -- Debug output,
  -- to allow the timing of the FSMC to be tuned.
  -----------------------------------------------------------------------------
  debug(0) <= fsmc_oe_n;
  debug(1) <= fsmc_adv_n;
  debug(2) <= fsmc_cs_n;
  debug(3) <= fsmc_wr_n;
  debug(4) <= fsmc_data(0);
  debug(5) <= fsmc_data(6);

  -----------------------------------------------------------------------------
  -- Single word register (to have some device on the bus)
  -----------------------------------------------------------------------------
  reg_1 : peripheral_register
    generic map (
      BASE_ADDRESS => 16#0000#)
    port map (
      bus_o  => bus_i,
      bus_i  => bus_o,
      dout_p => reg_o,
      din_p  => reg_i,
      clk    => clk);

  -- do something not so obvious with the data and loop it back
  reg_i <= reg_o xor std_logic_vector(to_unsigned(16#5555#, 16));

  -- LED is "active low"
  led_n <= not reg_o(0);
  
end behavioral;
