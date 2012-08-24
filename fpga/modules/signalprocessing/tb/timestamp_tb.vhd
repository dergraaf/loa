-------------------------------------------------------------------------------
-- Title      : Testbench for design "timestamp"
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Created    : 2011-12-16
-- Platform   : Spartan 3 
-------------------------------------------------------------------------------
-- Description: The timestamp generator creates a global timestamp. The
--              timestamp takers sample these timestamps when triggered. The
--              timestamp takers are readable by the bus and maintain
--              consistency by double buffering the timestamp. 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reg_file_pkg.all;
use work.bus_pkg.all;
use work.spislave_pkg.all;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------
entity timestamp_tb is
end timestamp_tb;

-------------------------------------------------------------------------------
architecture tb of timestamp_tb is

   -- component generics
   constant WIDTH                       : positive := 8;
   constant BASE_ADDR_TIMESTAMP_TAKER_1 : positive := 16#0100#;

   -- component ports
   signal timestamp : timestamp_type := (others => '0');

   signal bus_i : busdevice_in_type := (addr => (others => '0'),
                                        data => (others => '0'),
                                        we   => '0',
                                        re   => '0');

   signal bus_to_stm : busdevice_out_type;

   signal trigger_s : std_logic := '0';
   signal bank_x_s  : std_logic := '0';
   signal bank_y_s  : std_logic := '1';

   signal clk : std_logic := '0';

begin
   -- component instantiation
   timestamp_generator_1 : entity work.timestamp_generator
      port map (
         timestamp_o_p => timestamp,
         clk           => clk);

   timestamp_taker_1 : entity work.timestamp_taker
      generic map (
         BASE_ADDRESS => BASE_ADDR_TIMESTAMP_TAKER_1)
      port map (
         timestamp_i_p => timestamp,
         trigger_i_p   => trigger_s,
         bank_x_i_p    => bank_x_s,
         bank_y_i_p    => bank_y_s,
         bus_o         => bus_to_stm,
         bus_i         => bus_i,
         clk           => clk);

   -- clock generation
   clk <= not clk after 20 ns;

   waveform : process
   begin
      wait for 20 ns;

      wait for 200 ns;

      -- Trigger
      wait until rising_edge(clk);
      trigger_s <= '1';
      wait until rising_edge(clk);
      trigger_s <= '0';

      wait for 20 ns;
      bank_x_s <= '1';
      bank_y_s <= '0';

      wait for 200 ns;

      -- Trigger
      wait until rising_edge(clk);
      trigger_s <= '1';
      wait until rising_edge(clk);
      trigger_s <= '0';

      wait for 20 ns;
      bank_x_s <= '0';
      bank_y_s <= '1';


      -- do not repeat
      wait;
      
   end process waveform;

   -- purpose: Read access to the timestamp register from the bus
   -- type   : combinational
   -- inputs : 
   -- outputs: 
   bus_read : process
      variable timestamp : std_logic_vector(15 downto 0) := (others => '0');
   begin  -- process bus_read
      wait for 400 ns;
      readWord(addr => 16#0100#, bus_i => bus_i, clk => clk);
      timestamp := bus_to_stm.data;

      -- read again after next trigger
      wait for 400 ns;
      readWord(addr => 16#0100#, bus_i => bus_i, clk => clk);
      timestamp := bus_to_stm.data;
      

      wait;                             -- do not repeat
   end process bus_read;
end tb;
