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

   signal bus_data : unsigned(15 downto 0) := (others => '0');

   signal debug_addr : std_logic_vector(14 downto 0);
   signal debug_data : std_logic_vector(15 downto 0);

   signal hclk : std_logic := '0';
   signal addr : std_logic_vector(15 downto 0);
   signal data : std_logic_vector(15 downto 0);

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
   Clk <= not Clk after 20.0 ns;        -- 50MHz

   -- TODO: check if this happens for more than an instant
   -- Assert that there are no bus collisions
   --assert (fsmc_oe and fsmcmaster_oe) = '0'
   --   report "Boom Baem Au!!! Big fuckup! A bus collision has happend! 32 bits were killed!!!"
   --   severity warning;

   -- Change the bus data to find out when exactly the bus is sampled
   process (clk) is
   begin  -- process
      if rising_edge(clk) then          -- rising clock edge
         bus_i.data <= std_logic_vector(bus_data);
         bus_data   <= bus_data + 1;
      end if;
   end process;

   hclk_gen : process (hclk) is
   begin
      if hclk = '0' then
         hclk <= '1' after FSMC_HCLK_PERIOD/2, '0' after FSMC_HCLK_PERIOD;
      end if;
    end process;


   process
      variable d : std_logic_vector(31 downto 0);

   begin
      -- debug_addr <= std_logic_vector(to_unsigned(16#0ff#, 15));
      -- debug_data <= x"fe35";
      addr <= "1111000011110000";
      data <= "0000111100001111";

      wait for FSMC_HCLK_PERIOD * 20;

     -- write access
      fsmcMasterWrite(addr => addr, data => data, fsmc_o => fsmc_i, fsmc_i => fsmc_o, fsmc_oe => fsmcmaster_oe);

      wait for FSMC_HCLK_PERIOD * 20;

      -- read access
      fsmcMasterRead(addr => addr, data => data, fsmc_o => fsmc_i, fsmc_i => fsmc_o, fsmc_oe => fsmcmaster_oe);

      wait;

   end process;

end tb;
