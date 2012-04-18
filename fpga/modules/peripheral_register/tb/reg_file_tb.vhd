-------------------------------------------------------------------------------
-- Title      : Testbench for design "reg_file"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : reg_file_tb.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2012-03-11
-- Last update: 2012-04-18
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2012-03-11  1.0      calle   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
-------------------------------------------------------------------------------

entity reg_file_tb is

end reg_file_tb;

-------------------------------------------------------------------------------

architecture tb of reg_file_tb is

   -- component generics
   constant BASE_ADDRESS : integer range 0 to 32767 := 0;
   constant REG_ADDR_BIT : natural                  := 1;

   -- component ports
   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type := (addr => (others => '0'),
                                        data => (others => '0'),
                                        we   => '0',
                                        re   => '0');
   signal reg_o : reg_file_type(2**REG_ADDR_BIT-1 downto 0);
   signal reg_i : reg_file_type(2**REG_ADDR_BIT-1 downto 0);
   signal reset : std_logic := '0';
   --signal clk   : std_logic;

   -- clock
   signal Clk : std_logic := '1';

begin  -- tb

   -- component instantiation
   DUT : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => REG_ADDR_BIT)
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_o,
         reg_i => reg_i,
         reset => reset,
         clk   => clk);

   -- clock generation
   Clk <= not Clk after 10 NS;

   -- waveform generation
   WaveGen_Proc : process
   begin
      reset                <= '1';
      reg_i                <= (others => (others => '0'));
      reg_i(0)(3 downto 0) <= "0001";
      reg_i(1)(3 downto 0) <= "0010";


      bus_i.addr <= (others => '0');
      bus_i.data <= (others => '0');
      bus_i.re   <= '0';
      bus_i.we   <= '0';

      wait until Clk = '1';
      reset <= '0';

      wait until Clk = '1';
      bus_i.addr <= (others => '0');
      bus_i.data <= "0000" & "0000" & "0101" & "0101";
      bus_i.re   <= '0';
      bus_i.we   <= '1';

      wait until Clk = '1';
      bus_i.we <= '0';

      wait until Clk = '1';
      wait until Clk = '1';


      wait until Clk = '1';
      bus_i.addr(0) <= '1';
      bus_i.data    <= "0000" & "0000" & "0101" & "1111";
      bus_i.re      <= '0';
      bus_i.we      <= '1';

      wait until Clk = '1';
      bus_i.data <= (others => '0');
      bus_i.we   <= '0';


      wait until Clk = '1';
      wait until Clk = '1';
      wait until Clk = '1';

      -- read the registers
      bus_i.addr(0) <= '0';
      bus_i.re      <= '1';
      wait until Clk = '1';
      bus_i.re      <= '0';
      wait until Clk = '1';


      bus_i.addr(0) <= '1';
      bus_i.re      <= '1';
      wait until Clk = '1';
      bus_i.re      <= '0';
      wait until Clk = '1';

      wait until Clk = '1';
      wait until Clk = '1';
      wait until Clk = '1';


      -- do the same reads, but the DUT shouldn't react
      bus_i.addr(0) <= '0';
      bus_i.addr(8) <= '1';             -- another address
      bus_i.re      <= '1';
      wait until Clk = '1';
      bus_i.re      <= '0';
      wait until Clk = '1';


      bus_i.addr(0) <= '1';
      bus_i.re      <= '1';
      wait until Clk = '1';
      bus_i.re      <= '0';
      wait until Clk = '1';


      wait for 1000 NS;
      
   end process WaveGen_Proc;

end tb;

-------------------------------------------------------------------------------

configuration reg_file_tb_tb_cfg of reg_file_tb is
   for tb
   end for;
end reg_file_tb_tb_cfg;

-------------------------------------------------------------------------------
