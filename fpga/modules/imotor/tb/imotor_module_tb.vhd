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

   signal tx_busy_s  : std_logic;
   signal tx_data_s  : std_logic_vector(7 downto 0) := (others => '0');
   signal tx_empty_s : std_logic                    := '1';
   signal tx_re_s    : std_logic;

   signal clk_tx_s : std_logic := '0';

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
         DATA_WORDS_READ => 3,
         DATA_WORDS_SEND => 2,
         MOTORS       => MOTORS)
      port map (
         tx_out_p => tx_out,
         rx_in_p  => rx_in_can,
         bus_o    => bus_o,
         bus_i    => bus_i,
         clk      => clk);

   -- Simulates the answer of an iMotor
   uart_tx_1 : entity work.uart_tx
      port map (
         txd_p     => rx_in(0),
         busy_p    => tx_busy_s,
         data_p    => tx_data_s,
         empty_p   => tx_empty_s,
         re_p      => tx_re_s,
         clk_tx_en => clk_tx_s,
         clk       => clk);

   -- clock generation 50 MHz
   clk <= not clk after 10 ns;

   -- Generate a Tx bit clock
   bitclock : process
   begin
      wait until rising_edge(clk);
      clk_tx_s <= '1';
      wait until rising_edge(clk);
      clk_tx_s <= '0';
      wait for 970 ns;
   end process bitclock;

   -- CAN simulation
   can_sim : for ii in 0 to MOTORS-1 generate
      rx_in_can(ii) <= '0' when rx_in(ii) = '0' or tx_out(ii) = '0' else '1';
   end generate can_sim;

   -- waveform generation
   WaveGen_Proc : process

   begin
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

      tx_data_s  <= x"51";
      tx_empty_s <= '0';
      wait until falling_edge(tx_re_s);
      tx_empty_s <= '1';

      tx_data_s  <= x"aa";
      tx_empty_s <= '0';
      wait until falling_edge(tx_re_s);
      tx_empty_s <= '1';

      tx_data_s  <= x"bb";
      tx_empty_s <= '0';
      wait until falling_edge(tx_re_s);
      tx_empty_s <= '1';

      tx_data_s  <= x"cc";
      tx_empty_s <= '0';
      wait until falling_edge(tx_re_s);
      tx_empty_s <= '1';

      tx_data_s  <= x"dd";
      tx_empty_s <= '0';
      wait until falling_edge(tx_re_s);
      tx_empty_s <= '1';

      tx_data_s  <= x"a1";
      tx_empty_s <= '0';
      wait until falling_edge(tx_re_s);
      tx_empty_s <= '1';

      

      wait;

   end process WaveGen_Proc;

end architecture behavourial;
