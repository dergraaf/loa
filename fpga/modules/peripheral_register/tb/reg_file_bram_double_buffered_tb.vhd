-------------------------------------------------------------------------------
-- Title      : Testbench for design "reg_file_bram_double_buffered"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : reg_file_bram_double_buffered_tb.vhd
-- Author     : 
-- Company    : 
-- Created    : 2012-04-23
-- Last update: 2012-04-28
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.xilinx_block_ram_pkg.all;
use work.reg_file_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------

entity reg_file_bram_double_buffered_tb is

end reg_file_bram_double_buffered_tb;

-------------------------------------------------------------------------------

architecture tb of reg_file_bram_double_buffered_tb is

   -- component generics
   constant BASE_ADDRESS : integer range 0 to 32767 := 0;

   -- component ports
   signal bus_o : busdevice_out_type := (data => (others => '0'));
   signal bus_i : busdevice_in_type := (addr => (others => '0'),
                                        data => (others => '0'),
                                        we   => '0',
                                        re   => '0');
   signal bram_data_i : std_logic_vector(35 downto 0) := (others => '0');
   signal bram_data_o : std_logic_vector(35 downto 0) := (others => '0');
   signal bram_addr_i : std_logic_vector(7 downto 0)  := (others => '0');
   signal bram_we_p   : std_logic                     := '0';
   signal irq_p       : std_logic                     := '0';
   signal ack_p       : std_logic                     := '0';
   signal ready_p     : std_logic                     := '0';
   signal enable_p    : std_logic                     := '0';

   -- clock
   signal clk : std_logic := '1';

begin  -- tb

   -- component instantiation
   DUT : reg_file_bram_double_buffered
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         bus_o       => bus_o,
         bus_i       => bus_i,
         bram_data_i => bram_data_i,
         bram_data_o => bram_data_o,
         bram_addr_i => bram_addr_i,
         bram_we_p   => bram_we_p,
         irq_p       => irq_p,
         ack_p       => ack_p,
         ready_p     => ready_p,
         enable_p    => enable_p,
         clk         => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   -- purpose: read data from BRAM to bus
   bus_Proc : process
   begin
      -- wait until some data was written to BRAM
      for ii in 0 to 10 loop
         wait until Clk = '0';
      end loop;  -- ii

      ready_p <= '1';
      wait until clk = '0';
      ready_p <= '0';

      -- read from 0 to 511
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0000", bus_i.addr'length)));
      bus_i.re   <= '1';
      wait until clk = '0';
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0001", bus_i.addr'length)));
      wait until clk = '0';
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0002", bus_i.addr'length)));
      wait until clk = '0';
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0003", bus_i.addr'length)));


      -- do not repeat
      wait for 10 ms;
      
   end process bus_Proc;

   -- purpose: Simulates the Application writing and reading data to and from the block RAM port B
   -- type   : sequential
   application_proc : process
   begin  -- process application_proc
      wait until clk = '0';
      wait until clk = '0';

      bram_we_p   <= '1';
      bram_addr_i <= (others => '0');
      bram_data_i <= std_logic_vector(unsigned'(resize(x"3153853fa", bram_data_i'length)));

      wait until clk = '0';
      bram_addr_i <= std_logic_vector(unsigned'(resize(x"00001", bram_addr_i'length)));
      bram_data_i <= std_logic_vector(unsigned'(resize(x"854ff5a41", bram_data_i'length)));
     
      wait until clk = '0';
      bram_we_p   <= '0';

      -- do not repeat
      wait for 10 ms;
   end process application_proc;

end tb;
