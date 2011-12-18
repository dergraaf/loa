-------------------------------------------------------------------------------
-- Title      : Testbench for design "bldc_motor_module"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : bldc_motor_module_tb.vhd
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Company    : 
-- Created    : 2011-12-13
-- Last update: 2011-12-14
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-12-13  1.0      fabian  Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.motor_control_pkg.all;
use work.bldc_motor_module_pkg.all;

-------------------------------------------------------------------------------
entity bldc_motor_module_tb is
end bldc_motor_module_tb;

-------------------------------------------------------------------------------
architecture tb of bldc_motor_module_tb is

   -- component generics
   constant BASE_ADDRESS : positive := 16#0100#;
   constant WIDTH        : positive := 12;
   constant PRESCALER    : positive := 2;

   -- component ports
   signal driver_stage : bldc_driver_stage_type;
   signal hall_sensors : hall_sensor_type := ('0', '0', '0');

   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type :=
      (addr => (others => '0'),
       data => (others => '0'),
       we   => '0',
       re   => '0');
   signal reset : std_logic;
   signal clk   : std_logic := '0';

begin

   -- component instantiation
   DUT : bldc_motor_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         WIDTH        => WIDTH,
         PRESCALER    => PRESCALER)
      port map (
         driver_stage_p => driver_stage,
         hall_p         => hall_sensors,
         bus_o          => bus_o,
         bus_i          => bus_i,
         reset          => reset,
         clk            => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- reset generation
   reset <= '1', '0' after 50 ns;

   waveform : process
   begin
      wait until falling_edge(reset);
      wait for 100 ns;

      -- wrong address
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0020", bus_i.addr'length)));
      bus_i.data <= x"0123";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait for 30 US;

      -- correct address
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
      bus_i.data <= x"07ff";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait for 30 US;

      -- wrong address
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0110", bus_i.addr'length)));
      bus_i.data <= x"0123";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';
      
   end process waveform;
end tb;
