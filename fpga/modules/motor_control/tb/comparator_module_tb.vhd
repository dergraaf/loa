-------------------------------------------------------------------------------
-- Title      : Testbench for design "comparator_module"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian@kleinvieh>
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.motor_control_pkg.all;

-------------------------------------------------------------------------------
entity comparator_module_tb is
end comparator_module_tb;

-------------------------------------------------------------------------------
architecture tb of comparator_module_tb is

   -- component generics
   constant BASE_ADDRESS : positive := 16#0100#;
   constant CHANNELS     : positive := 3;
   
   -- component ports
   signal value    : comparator_values_type(CHANNELS-1 downto 0) := (others => (others => '0'));
   signal overflow : std_logic_vector(CHANNELS-1 downto 0);

   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type :=
      (addr => (others => '0'),
       data => (others => '0'),
       we   => '0',
       re   => '0');

   signal clk   : std_logic := '0';

begin
   -- component instantiation
   DUT : comparator_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         CHANNELS     => CHANNELS)
      port map (
         value_p    => value,
         overflow_p => overflow,
         bus_o      => bus_o,
         bus_i      => bus_i,
         clk        => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   bus_waveform : process
   begin
      wait for 100 ns;

      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
      bus_i.data <= x"00f0";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait for 30 US;

      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
      bus_i.data <= x"000f";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait for 100 US;

      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
      bus_i.data <= x"010f";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';
   end process;

   -- Generate different values
   process
   begin
      wait for 20 US;
      value(0) <= "0000010000";
      wait for 30 US;
      value(0) <= "0000000000";
      
      wait for 50 US;
      value(0) <= "0000010000";

      wait for 100 US;
      value(0) <= "0100000000";
      
   end process;
end tb;
