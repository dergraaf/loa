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
use work.fsmcmaster_pkg.all;

-------------------------------------------------------------------------------

entity fsmcslave_tb is

end fsmcslave_tb;

-------------------------------------------------------------------------------

architecture tb of fsmcslave_tb is


   signal clk : std_logic;

   signal data    : std_logic_vector(15 downto 0);
   signal addr    : std_logic_vector(15 downto 0);
   signal start   : std_logic;
   signal done    : std_logic;
   signal adv_n   : std_logic;
   signal e1_n    : std_logic;
   signal oe_n    : std_logic;
   signal we_n    : std_logic;
   signal ad      : std_logic_vector(15 downto 0);
   signal hclk    : std_logic := '0';

begin  -- tb


   -- Change the bus data to find out when exactly the bus is sampled
   process (clk) is
   begin  -- process
      if rising_edge(clk) then          -- rising clock edge
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

      wait for FSMC_HCLK_PERIOD * 2;

     -- write access
      fsmcMasterWrite(addr => addr, data => data, adv_n => adv_n , e1_n => e1_n, oe_n => oe_n, we_n => we_n, ad => ad);

      wait for FSMC_HCLK_PERIOD * 2;

      -- read access
      fsmcMasterRead(addr => addr, data => data, adv_n => adv_n , e1_n => e1_n, oe_n => oe_n, we_n => we_n, ad => ad);



      wait;

   end process;

end tb;
