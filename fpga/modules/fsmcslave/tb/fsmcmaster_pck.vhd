
library ieee;
use ieee.std_logic_1164.all;

library work;

package fsmcmaster_pkg is

   constant FSMC_ADDSET : natural := 3;
   constant FSMC_ADDHLD : natural := 3;
   constant FSMC_DATAST : natural := 3;
   constant FSMC_HCLK_PERIOD : time := 50 ns;  -- 20MHz

   procedure fsmcMasterWrite (
      signal addr  : in std_logic_vector(15 downto 0);
      signal data  : in std_logic_vector(15 downto 0);
      -- "STM32 Pins"
      signal adv_n : out std_logic;       -- address valid
      signal e1_n  : out std_logic;       -- chip select
      signal oe_n  : out std_logic;       -- output enable
      signal we_n  : out std_logic;       -- write enable
      signal ad    : out std_logic_vector(15 downto 0)   -- address and data
      );

   procedure fsmcMasterRead (
      signal addr  : in  std_logic_vector(15 downto 0);
      signal data  : out std_logic_vector(15 downto 0);
      -- "STM32 Pins"
      signal adv_n : out std_logic;       -- address valid
      signal e1_n  : out std_logic;       -- chip select
      signal oe_n  : out std_logic;       -- output enable
      signal we_n  : out std_logic;       -- write enable
      signal ad    : inout std_logic_vector(15 downto 0)   -- address and data
      );

end package fsmcmaster_pkg;

package body fsmcmaster_pkg is

   procedure fsmcMasterWrite(
      signal addr  : in std_logic_vector(15 downto 0);
      signal data  : in std_logic_vector(15 downto 0);
      -- "STM32 Pins"
      signal adv_n : out std_logic;       -- address valid
      signal e1_n  : out std_logic;       -- chip select
      signal oe_n  : out std_logic;       -- output enable
      signal we_n  : out std_logic;       -- write enable
      signal ad    : out std_logic_vector(15 downto 0)   -- address and data
      ) is
      begin
         -- Figure 417. Multiplexed write access
         adv_n <= '0';                  -- address valid
         e1_n  <= '0';                  -- chip selected
         oe_n  <= '1';
         we_n  <= '1';
         ad <= addr;
         wait for FSMC_HCLK_PERIOD * FSMC_ADDSET;
         adv_n <= '1';
         we_n  <= '0';
         wait for FSMC_HCLK_PERIOD * FSMC_ADDHLD;
         ad <= data;
         wait for FSMC_HCLK_PERIOD * FSMC_DATAST;
         we_n <= '1';
         wait for FSMC_HCLK_PERIOD;
         adv_n <= 'X';
         e1_n  <= '1';                  -- do no longer select chip
         oe_n  <= 'X';
         we_n  <= '1';
         ad    <= (others => 'X');
      end procedure;

   procedure fsmcMasterRead(
      signal addr  : in  std_logic_vector(15 downto 0);
      signal data  : out std_logic_vector(15 downto 0);
      -- "STM32 Pins"
      signal adv_n : out std_logic;       -- address valid
      signal e1_n  : out std_logic;       -- chip select
      signal oe_n  : out std_logic;       -- output enable
      signal we_n  : out std_logic;       -- write enable
      signal ad    : inout std_logic_vector(15 downto 0)   -- address and data
      )is
      begin
         -- Figure 417. Multiplexed write access
         adv_n <= '0';                  -- address valid
         e1_n  <= '0';                  -- chip selected
         oe_n  <= '1';
         we_n  <= '1';
         ad <= addr;
         wait for FSMC_HCLK_PERIOD * FSMC_ADDSET;
         adv_n <= '1';
         ad    <= (others => 'X');
         wait for FSMC_HCLK_PERIOD * FSMC_ADDHLD;
         ad    <= (others => 'Z');
         oe_n  <= '0';                  -- allow slave to write
         wait for FSMC_HCLK_PERIOD * FSMC_DATAST;
         data  <= ad;
         adv_n <= '1';
         e1_n  <= '1';                  -- do no longer select chip
         oe_n  <= '1';
         we_n  <= '1';
         -- wait for FSMC_HCLK_PERIOD;                -- TODO: find nicer way to do this
         ad    <= (others => 'X');
      end procedure;
end package body fsmcmaster_pkg;
