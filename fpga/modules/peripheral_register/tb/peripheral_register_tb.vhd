-------------------------------------------------------------------------------
-- Title      : Testbench for design "peripheral_register"
-------------------------------------------------------------------------------
-- Author     : Calle  <calle@Alukiste>
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------
entity peripheral_register_tb is
end peripheral_register_tb;

-------------------------------------------------------------------------------
architecture tb of peripheral_register_tb is

   -- component generics
   constant BASE_ADDRESS : positive := 16#0100#;

   -- component ports
   signal reg : std_logic_vector(15 downto 0) := (others => '0');

   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type :=
      (addr => (others => '0'),
       data => (others => '0'),
       we   => '0',
       re   => '0');
   signal clk   : std_logic := '0';

   signal reg_readback : std_logic_vector(15 downto 0);

   -- comments for the wave view of the testbench
   type comment_type is (idle,
                         read_wrong_addr,
                         read_correct_addr,
                         write_wrong_addr,
                         write_correct_addr,
                         sequential_cycles);
   signal comment : comment_type := idle;

begin

   reg_readback <= not reg;

   -- component instantiation
   DUT : peripheral_register
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         dout_p => reg,
         din_p  => reg_readback,                 -- read back the written values
         bus_o  => bus_o,
         bus_i  => bus_i,
         clk    => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   waveform : process

   begin
      wait for 20 ns;

      -- Read from wrong address
      comment <= read_wrong_addr;
      readWord(addr => 16#0020#, bus_i => bus_i, clk => clk);

      -- Read from correct address
      comment <= read_correct_addr;
      readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);

      -- Write to wrong address
      comment <= write_wrong_addr;
      writeWord(addr => BASE_ADDRESS + 1, data => 16#affe#, bus_i => bus_i, clk => clk);

      -- Write to correct address
      comment <= write_correct_addr;
      writeWord(addr => BASE_ADDRESS, data => 16#54af#, bus_i => bus_i, clk => clk);

      -- Read from wrong address
      comment <= read_wrong_addr;
      readWord(addr => 16#0020#, bus_i => bus_i, clk => clk);

      -- Read from correct address
      comment <= read_correct_addr;
      readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);

      -- Read from wrong address
      comment <= read_wrong_addr;
      readWord(addr => 16#0020#, bus_i => bus_i, clk => clk);

      wait until rising_edge(clk);

      -- generate two read cycles directly following each other
      comment <= sequential_cycles;

      bus_i.re <= '1';
      wait until rising_edge(clk);
      wait until rising_edge(clk);
      bus_i.re <= '0';

      wait until rising_edge(clk);
      bus_i.data <= x"4321";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait until rising_edge(clk);
      bus_i.re <= '1';
      wait until rising_edge(clk);
      bus_i.re <= '0';
      
   end process waveform;
end tb;
