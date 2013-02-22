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
   signal tx_out : std_logic_vector(MOTORS-1 downto 0);
   signal rx_in  : std_logic_vector(MOTORS-1 downto 0) := (others => '0');

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

   imotor_module_1 : entity work.imotor_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         MOTORS       => 2)
      port map (
         tx_out_p => tx_out,
         rx_in_p  => rx_in,
         bus_o    => bus_o,
         bus_i    => bus_i,
         clk      => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- insert signal assignments here

      wait until clk = '1';

      -- Fill registers

      -- iMotor #0, PWM
      writeWord(addr => 16#0100#, data => 16#2211#, bus_i => bus_i, clk => clk);

      -- iMotor #0, CUR
      writeWord(addr => 16#0101#, data => 16#4433#, bus_i => bus_i, clk => clk);

      -- iMotor #1, PWM
      writeWord(addr => 16#0102#, data => 16#6655#, bus_i => bus_i, clk => clk);

      -- iMotor #1, CUR
      writeWord(addr => 16#0103#, data => 16#8877#, bus_i => bus_i, clk => clk);


      wait until false;

   end process WaveGen_Proc;

end architecture behavourial;
