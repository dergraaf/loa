-------------------------------------------------------------------------------
-- Title      : Testbench for design "reg_file_bram"
-------------------------------------------------------------------------------
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------

entity reg_file_bram_tb is

end entity reg_file_bram_tb;

-------------------------------------------------------------------------------

architecture tb of reg_file_bram_tb is

   -- component generics
   constant BASE_ADDRESS : integer := 16#0400#;

   -- component ports
   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type := (addr => (others => '0'),
                                        data => (others => '0'),
                                        we   => '0',
                                        re   => '0');
   signal bram_data_i : std_logic_vector(15 downto 0) := (others => '0');
   signal bram_data_o : std_logic_vector(15 downto 0) := (others => '0');
   signal bram_addr_i : std_logic_vector(9 downto 0)  := (others => '0');
   signal bram_we_p   : std_logic                     := '0';

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture tb

   -- component instantiation
   DUT : entity work.reg_file_bram
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         bus_o       => bus_o,
         bus_i       => bus_i,
         bram_data_i => bram_data_i,
         bram_data_o => bram_data_o,
         bram_addr_i => bram_addr_i,
         bram_we_p   => bram_we_p,
         clk         => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      
      wait until clk = '1';

      -- write a word to valid addresses
      writeWord(addr => BASE_ADDRESS + 0, data => 16#55aa#, bus_i => bus_i, clk => clk);
      writeWord(addr => BASE_ADDRESS + 1, data => 16#33dd#, bus_i => bus_i, clk => clk);

      -- write to invalid address
      writeWord(addr => 0, data => 16#2211#, bus_i => bus_i, clk => clk);


      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      -- read from valid address
      readWord(addr => BASE_ADDRESS + 1, bus_i => bus_i, clk => clk);

      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      -- read from invalid address
      readWord(addr => BASE_ADDRESS - 1, bus_i => bus_i, clk => clk);

      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      -- read from valid address
      readWord(addr => BASE_ADDRESS + 0, bus_i => bus_i, clk => clk);
      readWord(addr => BASE_ADDRESS + 1, bus_i => bus_i, clk => clk);
      readWord(addr => BASE_ADDRESS + 2, bus_i => bus_i, clk => clk);
      readWord(addr => BASE_ADDRESS + 3, bus_i => bus_i, clk => clk);

      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';

      -- write all the block ram
      bram_we_p <= '1';
      for ii in 0 to 16#00ff# loop
         bram_addr_i <= std_logic_vector(to_unsigned(ii, 10));
         bram_data_i <= std_logic_vector(to_unsigned(ii, 16));
         wait until clk = '1';
      end loop;  -- ii
      bram_we_p <= '0';

      -- read from port A
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      readWord(addr => BASE_ADDRESS + 16#23#, bus_i => bus_i, clk => clk);

      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';
      wait until clk = '1';



      -- test the address match
      -- the addr_match_a signal is only '1' when the bus address
      -- matches the range between including BASE_ADDRESS to BASE_ADDRESS + 0x03ff
      bus_i.re <= '1';
      for addr in 0 to 16#0800# loop
         bus_i.addr <= std_logic_vector(to_unsigned(addr, bus_i.addr'length));
         wait until rising_edge(clk);
      end loop;  -- addr


      -- do not repeat
      wait for 10 ms;
      
   end process WaveGen_Proc;

   

end architecture tb;

