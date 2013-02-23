-------------------------------------------------------------------------------
-- Title      : Testbench for design "imotor_receiver"
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
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_receiver_tb is
end entity imotor_receiver_tb;

-------------------------------------------------------------------------------

architecture behavourial of imotor_receiver_tb is

   -- component generics
   constant DATA_WORDS : positive := 2;
   constant DATA_WIDTH : positive := 16;

   -- Component ports

   -- clock
   signal clk : std_logic := '1';

   signal clock_s : imotor_timer_type;

   signal data_rx_in_s    : std_logic_vector(7 downto 0) := (others => '0');
   signal imotor_output_s : imotor_output_type(1 downto 0);

   signal ready_rx_s : std_logic := '0';

begin  -- architecture behavourial

   -- component instantiation
   imotor_receiver_1 : entity work.imotor_receiver
      generic map (
         DATA_WORDS => DATA_WORDS,
         DATA_WIDTH => DATA_WIDTH)
      port map (
         data_out_p        => imotor_output_s,
         data_in_p         => data_rx_in_s,
         parity_error_in_p => '0',     -- parity_error_in_p,
         ready_in_p        => ready_rx_s,
         clk               => clk);

   imotor_timer_1 : imotor_timer
      generic map (
         CLOCK          => 50E6,
         BAUD           => 1E6,
         SEND_FREQUENCY => 1E5)
      port map (
         clock_out_p => clock_s,
         clk         => clk);

   -- clock generation
   clk <= not clk after 10 ns;

   -- waveform generation
   WaveGen_Proc : process
   begin
      -- Start byte of slave
      wait until clock_s.rx = '1';
      data_rx_in_s <= x"51";
      
      ready_rx_s <= '1';
      wait until clk = '1';
      ready_rx_s <= '0';

      -- First data byte
      wait until clock_s.rx = '1';
      data_rx_in_s <= x"12";
      
      ready_rx_s <= '1';
      wait until clk = '1';
      ready_rx_s <= '0';

      --
      wait until clock_s.rx = '1';
      data_rx_in_s <= x"34";
      
      ready_rx_s <= '1';
      wait until clk = '1';
      ready_rx_s <= '0';

      --
      wait until clock_s.rx = '1';
      data_rx_in_s <= x"56";
      
      ready_rx_s <= '1';
      wait until clk = '1';
      ready_rx_s <= '0';

      -- 
      wait until clock_s.rx = '1';
      data_rx_in_s <= x"78";
      
      ready_rx_s <= '1';
      wait until clk = '1';
      ready_rx_s <= '0';

      -- End Byte
      wait until clock_s.rx = '1';
      data_rx_in_s <= x"A1";
      
      ready_rx_s <= '1';
      wait until clk = '1';
      ready_rx_s <= '0';

      
      wait until false;

   end process WaveGen_Proc;

end architecture behavourial;
