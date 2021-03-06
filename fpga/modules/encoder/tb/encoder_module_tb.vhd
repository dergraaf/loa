-------------------------------------------------------------------------------
-- Title      : Testbench for design "encoder_module"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.encoder_module_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity encoder_module_tb is
end encoder_module_tb;

-------------------------------------------------------------------------------
architecture tb of encoder_module_tb is

   -- component generics
   constant BASE_ADDRESS : positive := 16#0100#;

   -- component ports
   signal encoder : encoder_type := ('0', '0');
   signal index   : std_logic    := '0';
   signal load    : std_logic    := '0';

   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type :=
      (addr => (others => '0'),
       data => (others => '0'),
       we   => '0',
       re   => '0');
   signal clk   : std_logic := '0';

begin
   -- component instantiation
   DUT : encoder_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         encoder_p => encoder,
         index_p   => index,
         load_p    => load,
         bus_o     => bus_o,
         bus_i     => bus_i,
         clk       => clk);

   -- clock generation
   clk <= not clk after 10 NS;

   waveform : process
   begin
      wait for 20 NS;

      for i in 1 to 3 loop
         wait until rising_edge(clk);
         encoder.a <= '1';
         wait until rising_edge(clk);
         encoder.b <= '1';
         wait until rising_edge(clk);
         encoder.a <= '0';
         wait until rising_edge(clk);
         encoder.b <= '0';
         wait until rising_edge(clk);
      end loop;  -- i

      wait for 50 NS;

      -- wrong address
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0020", bus_i.addr'length)));
      bus_i.data <= x"0000";
      bus_i.re   <= '1';
      wait until rising_edge(clk);
      bus_i.re   <= '0';

      wait for 30 NS;

      -- correct address
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
      bus_i.data <= x"0000";
      bus_i.re   <= '1';
      wait until rising_edge(clk);
      bus_i.re   <= '0';

      wait for 30 NS;

      wait until rising_edge(clk);
      load <= '1';
      wait until rising_edge(clk);
      load <= '0';

      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
      bus_i.data <= x"0000";
      bus_i.re   <= '1';
      wait until rising_edge(clk);
      bus_i.re   <= '0';
      wait until rising_edge(clk);

      -- generate two read cycles directly following each other
      bus_i.re <= '1';
      wait until rising_edge(clk);
      wait until rising_edge(clk);
      bus_i.re <= '0';

      -- wrong address
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0110", bus_i.addr'length)));
      bus_i.data <= x"0000";
      bus_i.re   <= '1';
      wait until rising_edge(clk);
      bus_i.re   <= '0';
      
   end process waveform;
end tb;
