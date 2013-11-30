-------------------------------------------------------------------------------
-- Title      : Testbench for design "fsmcslave"
-------------------------------------------------------------------------------
-- Author     : kevin.laefer@rwth-aachen.de
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- Copyright (c) 2013
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fsmc_test_data_pkg.all;
use work.fsmcslave_pkg.all;
use work.fsmcmaster_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------

entity fsmcslave_tb is

end fsmcslave_tb;

-------------------------------------------------------------------------------

architecture tb of fsmcslave_tb is

   -- component ports
   signal fsmc_o  : fsmcslave_out_type;
   signal fsmc_i  : fsmcslave_in_type;
   signal fsmc_oe : std_logic;
   signal bus_o   : busmaster_out_type;
   signal bus_i   : busmaster_in_type;
   signal clk     : std_logic := '0';

   -- FSMC master output enable
   signal fsmcmaster_oe : std_logic := '0';

   signal bus_data_count  : unsigned(15 downto 0) := (others => '0');
   signal bus_data_in     : std_logic_vector(15 downto 0) := (others => '0');
   signal bus_data_out    : std_logic_vector(15 downto 0) := (others => '0');
   signal bus_data_connect_counter : std_logic := '0';

   signal debug_addr : std_logic_vector(14 downto 0);
   signal debug_data : std_logic_vector(15 downto 0);

   signal hclk : std_logic := '0';
   signal addr : std_logic_vector(15 downto 0);
   signal data : std_logic_vector(15 downto 0);

   -- Status Signals for debugging
   signal master_write_in_progress : std_logic := '0';
   signal master_read_in_progress : std_logic := '0';

begin  -- tb

   DUT : fsmcslave port map (
         fsmc_o  => fsmc_o,
         fsmc_i  => fsmc_i,
         fsmc_oe => fsmc_oe,
         --
         bus_o   => bus_o,
         bus_i   => bus_i,
         --
         clk     => clk);

     -- clock generation
   Clk <= not Clk after 10.0 ns;        -- 50MHz

   -- TODO: check if this happens for more than an instant
   -- Assert that there are no bus collisions
   --assert (fsmc_oe and fsmcmaster_oe) = '0'
   --   report "Boom Baem Au!!! Big fuckup! A bus collision has happend! 32 bits were killed!!!"
   --   severity warning;

   -- Change the bus data to find out when exactly the bus is sampled
   process (clk) is
   begin  -- process
      if rising_edge(clk) then          -- rising clock edge
          bus_data_count   <= bus_data_count + 1;
      end if;
   end process;

     -- read bus
    bus_counter : process (clk) is
    begin
       if clk'event and clk = '1' then
          if bus_o.we = '1' then
             bus_data_out <= bus_o.data;
          end if;
       end if;
    end process;

   bus_mux: process (bus_data_count, bus_data_in, bus_data_connect_counter) is
   begin  -- process bus_mux
      if bus_data_connect_counter = '1' then
         bus_i.data <= std_logic_vector(bus_data_count);
      else
         bus_i.data <= bus_data_in;
      end if;
   end process bus_mux;


   process
   begin
      bus_data_in <= (others => '0');
      addr <= "1111000011110000";

      wait for FSMC_HCLK_PERIOD * 20;

      -------------------------------------------------------------------------
      -- Test Write
      -------------------------------------------------------------------------

      for ii in 0 to N_TEST_DATA-1 loop
         data <= TEST_DATA(ii);
         master_write_in_progress <= '1';
         fsmcMasterWrite(addr => addr, data => data, hclk => hclk, fsmc_o => fsmc_i, fsmc_i => fsmc_o, fsmc_oe => fsmcmaster_oe);
         master_write_in_progress <= '0';
         wait until clk = '1';          -- wait for rising edge
         wait for 1 ps;                 -- ugly!!!
         assert bus_data_out = data report "Oh no! Failed to write data via FSMC." severity failure;
         -- clock shift
         wait for FSMC_HCLK_PERIOD / N_TEST_DATA;
      end loop;  -- ii

      -------------------------------------------------------------------------
      -- Test Read
      -------------------------------------------------------------------------
      data <= (others => 'X');          -- fsmc Master is going to write to data

      for ii in 0 to N_TEST_DATA-1 loop
         bus_data_in <= TEST_DATA(ii);
         master_read_in_progress <= '1';
         fsmcMasterRead(addr => addr, data => data, hclk => hclk, fsmc_o => fsmc_i, fsmc_i => fsmc_o, fsmc_oe => fsmcmaster_oe);
         master_read_in_progress <= '0';
         wait until clk = '1';          -- wait for rising edge
         wait for 1 ps;                 -- ugly!!!
         assert data = bus_data_in report "Oh no! Failed to read data via FSMC." severity failure;
         -- clock shift
         wait for FSMC_HCLK_PERIOD / N_TEST_DATA;
      end loop;  -- ii

      -------------------------------------------------------------------------
      -- Test Read Timing
      -------------------------------------------------------------------------
      bus_data_connect_counter <= '1';   -- connect counter to bus input

      for ii in 0 to N_TEST_DATA-1 loop
         master_read_in_progress <= '1';
         fsmcMasterRead(addr => addr, data => data, hclk => hclk, fsmc_o => fsmc_i, fsmc_i => fsmc_o, fsmc_oe => fsmcmaster_oe);
         master_read_in_progress <= '0';
         wait until clk = '1';          -- wait for rising edge
         -- clock shift
         wait for FSMC_HCLK_PERIOD / N_TEST_DATA;
      end loop;  -- ii

      bus_data_connect_counter <= '0';

      wait;
   end process;

end tb;
