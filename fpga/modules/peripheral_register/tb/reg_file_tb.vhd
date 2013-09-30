-------------------------------------------------------------------------------
-- Title      : Testbench for design "reg_file"
-------------------------------------------------------------------------------
-- Author     : Calle  <calle@Alukiste>
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
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
   constant BASE_ADDRESS : integer range 0 to 16#7FFF# := 16#0010#;
   constant REG_ADDR_BIT : natural                     := 1;

   -- component ports
   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type := (addr => (others => '0'),
                                        data => (others => '0'),
                                        we   => '0',
                                        re   => '0');
   signal reg_o : reg_file_type(2**REG_ADDR_BIT-1 downto 0);
   signal reg_i : reg_file_type(2**REG_ADDR_BIT-1 downto 0);

   -- clock
   signal clk : std_logic := '1';

   type comment_type is (idle, write, read);
   signal comment : comment_type := idle;

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
         clk   => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- Reset
      reg_i                <= (others => (others => '0'));
      reg_i(0)(3 downto 0) <= "0001";
      reg_i(1)(3 downto 0) <= "0010";

      bus_i.addr <= (others => '0');
      bus_i.data <= (others => '0');
      bus_i.re   <= '0';
      bus_i.we   <= '0';

      wait until Clk = '1';
      
      comment <= write;
      writeWord(addr => 16#0010#, data => 16#0055#, bus_i => bus_i, clk => clk); 

      wait until Clk = '1';
      wait until Clk = '1';

      writeWord(addr => 16#0011#, data => 16#005f#, bus_i => bus_i, clk => clk); 

      wait until Clk = '1';
      wait until Clk = '1';

      -- read the registers
      -- expected data is the input to the register_file reg_i(0) and reg_i(1)
      comment <= read;
      readWord(addr => BASE_ADDRESS, bus_i => bus_i, clk => clk);

      readWord(addr => BASE_ADDRESS + 1, bus_i => bus_i, clk => clk);

      -- do the same reads, but the DUT shouldn't react
      -- bus data should be 0000
      readWord(addr => BASE_ADDRESS + 2, bus_i => bus_i, clk => clk);

      -- read from correct address again
      readWord(addr => BASE_ADDRESS + 1, bus_i => bus_i, clk => clk);

      wait for 1000 ns;
   end process WaveGen_Proc;

end tb;

-------------------------------------------------------------------------------
