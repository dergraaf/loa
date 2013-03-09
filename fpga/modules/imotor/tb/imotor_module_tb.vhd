-------------------------------------------------------------------------------
-- Title      : Testbench for design "imotor_module"
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_module_tb is
end entity imotor_module_tb;

-------------------------------------------------------------------------------

architecture behavourial of imotor_module_tb is

   -- component generics
   constant BASE_ADDRESS : positive := 16#0100#;
   constant MOTORS       : positive := 2;

   -- Component ports
   signal tx_out    : std_logic_vector(MOTORS-1 downto 0);
   signal rx_in     : std_logic_vector(MOTORS-1 downto 0) := (others => '1');
   signal rx_in_can : std_logic_vector(MOTORS-1 downto 0);  -- simulated signal on the CAN link

   signal bus_o : busdevice_out_type;
   signal bus_i : busdevice_in_type :=
      (addr => (others => '0'),
       data => (others => '0'),
       we   => '0',
       re   => '0');

   -- clock
   signal clk : std_logic := '1';

begin  -- architecture behavourial

   -- component instantiation

   -- MUT
   imotor_module_1 : entity work.imotor_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         MOTORS       => 2)
      port map (
         tx_out_p => tx_out,
         rx_in_p  => rx_in_can,
         bus_o    => bus_o,
         bus_i    => bus_i,
         clk      => clk);

   -- clock generation 50 MHz
   clk <= not clk after 10 ns;

   -- CAN simulation
   can_sim : for ii in 0 to MOTORS-1 generate
      rx_in_can(ii) <= '0' when rx_in(ii) = '0' or tx_out(ii) = '0' else '1';
   end generate can_sim;

   -- waveform generation
   WaveGen_Proc : process
      variable rxd_testvector : std_logic_vector(0 to 54) :=
         "00000" & -- startbit
         "11111" & "00000" & "00000" & "00000" &
         "11111" & "00000" & "11111" & "00000" & "00000" &
         -- x"51" with odd parity = 0, LSB is sent first
         "11111";                       -- stop bit, 5x oversampling
      
   begin
      -- insert signal assignments here

      wait until clk = '1';

      -- Fill registers at simulation start

      -- iMotor #0, PWM
      writeWord(addr => 16#0100#, data => 16#2211#, bus_i => bus_i, clk => clk);

      -- iMotor #0, CUR
      writeWord(addr => 16#0101#, data => 16#4433#, bus_i => bus_i, clk => clk);

      -- iMotor #1, PWM
      writeWord(addr => 16#0102#, data => 16#6655#, bus_i => bus_i, clk => clk);

      -- iMotor #1, CUR
      writeWord(addr => 16#0103#, data => 16#8877#, bus_i => bus_i, clk => clk);



      wait for 300 us;

      -- Simulate data from iMotor to receiver
      for ii in 0 to rxd_testvector'length - 1 loop
         for jj in 0 to 9 loop
            wait until rising_edge(clk);
         end loop;  -- jj
         -- 50 MHz / 10  = 5 MHz = 1 MBit x 5 OS

         rx_in(0) <= rxd_testvector(ii);
      end loop;  -- ii


      wait until false;

   end process WaveGen_Proc;

end architecture behavourial;
