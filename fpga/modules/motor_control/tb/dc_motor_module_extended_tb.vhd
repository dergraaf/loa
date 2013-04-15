-------------------------------------------------------------------------------
-- Title      : Testbench for design "dc_motor_module_extended"
-------------------------------------------------------------------------------
-- Author     : Fabian Greif
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.motor_control_pkg.all;

-------------------------------------------------------------------------------
entity dc_motor_module_extended_tb is
end dc_motor_module_extended_tb;

-------------------------------------------------------------------------------
architecture tb of dc_motor_module_extended_tb is

   -- component generics
   constant BASE_ADDRESS : positive := 16#0100#;
   constant WIDTH        : positive := 8;
   constant PRESCALER    : positive := 2;

   -- component ports
   signal pwm1  : std_logic := '0';
   signal pwm2  : std_logic := '0';
   signal sd    : std_logic := '1';
   signal break : std_logic := '0';

   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type :=
      (addr => (others => '0'),
       data => (others => '0'),
       we   => '0',
       re   => '0');
   signal clk : std_logic := '0';

begin

   -- component instantiation
   DUT : dc_motor_module_extended
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         WIDTH        => WIDTH,
         PRESCALER    => PRESCALER)
      port map (
         pwm1_p  => pwm1,
         pwm2_p  => pwm2,
         sd_p    => sd,
         break_p => break,
         bus_o   => bus_o,
         bus_i   => bus_i,
         clk     => clk);

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
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0101", bus_i.addr'length)));
      bus_i.data <= x"000f";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait for 150 us;

      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0100", bus_i.addr'length)));
      bus_i.data <= x"000f";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0101", bus_i.addr'length)));
      bus_i.data <= x"00f0";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait for 200 us;

      -- Disable PWM via break
      wait until rising_edge(clk);
      bus_i.addr <= std_logic_vector(unsigned'(resize(x"0101", bus_i.addr'length)));
      bus_i.data <= x"80ff";
      bus_i.we   <= '1';
      wait until rising_edge(clk);
      bus_i.we   <= '0';

      wait;
   end process;

   -- Test break signal
   process
   begin
      wait for 220 us;
      break <= '1';
      wait for 30 us;
      break <= '0';
   end process;
end tb;
