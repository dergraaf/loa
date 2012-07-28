-------------------------------------------------------------------------------
-- Title      : Testbench for design "xilinx_block_ram"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : xilinx_block_ram_tb.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-23
-- Last update: 2012-07-28
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

-------------------------------------------------------------------------------

entity xilinx_block_ram_tb is

end xilinx_block_ram_tb;

-------------------------------------------------------------------------------

architecture tb of xilinx_block_ram_tb is

   -- component generics
   constant ADDR_A_WIDTH : positive := 11;
   constant ADDR_B_WIDTH : positive := 10;
   constant DATA_A_WIDTH : positive := 8;
   constant DATA_B_WIDTH : positive := 16;

   -- component ports
   signal addr_a : std_logic_vector(ADDR_A_WIDTH-1 downto 0) := (others => '0');
   signal addr_b : std_logic_vector(ADDR_B_WIDTH-1 downto 0) := (others => '0');
   signal din_a  : std_logic_vector(DATA_A_WIDTH-1 downto 0) := (others => '0');
   signal din_b  : std_logic_vector(DATA_B_WIDTH-1 downto 0) := (others => '0');
   signal dout_a : std_logic_vector(DATA_A_WIDTH-1 downto 0) := (others => '0');
   signal dout_b : std_logic_vector(DATA_B_WIDTH-1 downto 0) := (others => '0');
   signal we_a   : std_logic                                 := '0';
   signal we_b   : std_logic                                 := '0';

   -- clock
   signal clk : std_logic := '1';

begin  -- tb

   -- component instantiation
   DUT : xilinx_block_ram_dual_port
      generic map (
         ADDR_A_WIDTH => ADDR_A_WIDTH,
         ADDR_B_WIDTH => ADDR_B_WIDTH,
         DATA_A_WIDTH => DATA_A_WIDTH,
         DATA_B_WIDTH => DATA_B_WIDTH)
      port map (
         addr_a => addr_a,
         addr_b => addr_b,
         din_a  => din_a,
         din_b  => din_b,
         dout_a => dout_a,
         dout_b => dout_b,
         we_a   => we_a,
         we_b   => we_b,
         en_a   => '1',
         en_b   => '1',
         ssr_a  => '0',
         ssr_b  => '0',
         clk_a  => clk,
         clk_b  => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      wait until clk = '0';

      -- write Port A 0xfe at 0x20
      addr_a <= std_logic_vector(unsigned'(resize(x"0020", addr_a'length)));
      din_a  <= std_logic_vector(unsigned'(resize(x"00fe", din_a'length)));
      we_a   <= '1';
      wait until clk = '0';
      we_a   <= '0';

      -- write Port A 0xab at 0x21
      addr_a <= std_logic_vector(unsigned'(resize(x"0021", addr_a'length)));
      din_a  <= std_logic_vector(unsigned'(resize(x"00ab", din_a'length)));
      we_a   <= '1';

      -- read Port B 0x20 / 2
      addr_b <= std_logic_vector(unsigned'(resize(x"0010", addr_b'length)));

      wait until clk = '0';
      we_a <= '0';

      -- Remember the effect of "read-first":
      -- When 0x21 is addressed the memory cell is read before 0xab is
      -- written to that cell. Thus 0x00 will appear at the output of dout_a.
      -- 0xab will appear with the next rising clock edge on the output dout_a. 

      wait until clk = '0';

      -- do not repeat
      wait for 10 ms;
   end process WaveGen_Proc;

end tb;

-------------------------------------------------------------------------------
