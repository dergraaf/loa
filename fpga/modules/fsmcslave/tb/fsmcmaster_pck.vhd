
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fsmcslave_pkg.all;

package fsmcmaster_pkg is

   constant FSMC_ADDSET : natural := 25;
   constant FSMC_ADDHLD : natural := 0;
   constant FSMC_DATAST : natural := 25;
   constant FSMC_HCLK_PERIOD : time := 5952 ps;  -- ~168MHz

   procedure fsmcMasterWrite (
      signal addr  : in std_logic_vector(15 downto 0);
      signal data  : in std_logic_vector(15 downto 0);
      -- "STM32 Pins"
      signal fsmc_o : out fsmcmaster_out_type;
      signal fsmc_i : in  fsmcmaster_in_type;
      signal fsmc_oe : out std_logic
      );

   procedure fsmcMasterRead (
      signal addr  : in  std_logic_vector(15 downto 0);
      signal data  : out std_logic_vector(15 downto 0);
      -- "STM32 Pins"
      signal fsmc_o : out fsmcmaster_out_type;
      signal fsmc_i : in  fsmcmaster_in_type;
      signal fsmc_oe : out std_logic
      );

end package fsmcmaster_pkg;

package body fsmcmaster_pkg is

   procedure fsmcMasterWrite(
      signal addr  : in std_logic_vector(15 downto 0);
      signal data  : in std_logic_vector(15 downto 0);
      -- "STM32 Pins"
      signal fsmc_o : out fsmcmaster_out_type;
      signal fsmc_i : in fsmcmaster_in_type;
      signal fsmc_oe : out std_logic
      ) is
      begin
         -- we will just output data
         fsmc_oe <= '1';
         -- Figure 417. Multiplexed write access
         fsmc_o.adv_n <= '0';           -- address valid
         fsmc_o.cs_n  <= '0';                  -- chip selected
         fsmc_o.oe_n  <= '1';
         fsmc_o.we_n  <= '1';
         fsmc_o.ad <= addr;
         wait for FSMC_HCLK_PERIOD * FSMC_ADDSET;
         fsmc_o.adv_n <= '1';
         fsmc_o.we_n  <= '0';
         wait for FSMC_HCLK_PERIOD * FSMC_ADDHLD;
         fsmc_o.ad <= data;
         wait for FSMC_HCLK_PERIOD * FSMC_DATAST;
         fsmc_o.we_n <= '1';
         wait for FSMC_HCLK_PERIOD;
         fsmc_o.adv_n <= 'X';
         fsmc_o.cs_n  <= '1';                  -- do no longer select chip
         fsmc_o.oe_n  <= 'X';
         fsmc_o.we_n  <= '1';
         fsmc_o.ad    <= (others => 'X');
      end procedure;

   procedure fsmcMasterRead(
      signal addr  : in  std_logic_vector(15 downto 0);
      signal data  : out std_logic_vector(15 downto 0);
      -- "STM32 Pins"
      signal fsmc_o : out fsmcmaster_out_type;
      signal fsmc_i : in  fsmcmaster_in_type;
      signal fsmc_oe : out std_logic
      )is
      begin
         fsmc_oe <= '1';
         -- Figure 417. Multiplexed write access
         fsmc_o.adv_n <= '0';                  -- address valid
         fsmc_o.cs_n  <= '0';                  -- chip selected
         fsmc_o.oe_n  <= '1';
         fsmc_o.we_n  <= '1';
         fsmc_o.ad <= addr;
         wait for FSMC_HCLK_PERIOD * FSMC_ADDSET;
         fsmc_o.adv_n <= '1';
         fsmc_o.ad    <= (others => 'X');
         wait for FSMC_HCLK_PERIOD * FSMC_ADDHLD;
         fsmc_oe      <= '0';
         fsmc_o.oe_n  <= '0';                  -- allow slave to write
         wait for FSMC_HCLK_PERIOD * FSMC_DATAST;
         data  <= fsmc_i.ad;
         fsmc_o.adv_n <= '1';
         fsmc_o.cs_n  <= '1';                  -- do no longer select chip
         fsmc_o.oe_n  <= '1';
         fsmc_o.we_n  <= '1';
         fsmc_oe <= '1';
         -- wait for FSMC_HCLK_PERIOD;                -- TODO: find nicer way to do this
         fsmc_o.ad    <= (others => 'X');
      end procedure;
end package body fsmcmaster_pkg;
