-------------------------------------------------------------------------------
-- Title      : Captain Drive
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
-- Main control board of the 2012 robot "captain".
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.fsmcslave_pkg.all;
--use work.peripheral_register_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
   port (
      -- Connections to the STM32F103
      data_p : in std_logic_vector(7 downto 0);
      -- TODO      

      -- Internal connections
      led_p : out std_logic_vector (5 downto 0);

      -- Connections on the Breadboard
      -- FSMC
      fsmc_data_p  : inout std_logic_vector(15 downto 0);
      fsmc_adv_np  : in    std_logic;
      fsmc_clk_p   : in    std_logic;
      fsmc_oe_np   : in    std_logic;
      fsmc_we_np   : in    std_logic;
      fsmc_cs_np   : in    std_logic;
      fsmc_bl_np   : in    std_logic_vector(1 downto 0);
      fsmc_wait_np : out   std_logic;

      clk : in std_logic
      );
end toplevel;

architecture structural of toplevel is
--   signal register_out : std_logic_vector(15 downto 0);
--   signal register_in  : std_logic_vector(15 downto 0);

--   signal reset : std_logic := '0';
   signal led_clock_en : std_logic                    := '0';
   signal led          : std_logic_vector(5 downto 0) := (others => '0');

   -- Connection to FSMC
   signal fsmc_o : fsmc_in_type;
   signal fsmc_i : fsmc_out_type;

   -- Connection to the Busmaster
   signal bus_o : busmaster_out_type;
   signal bus_i : busmaster_in_type;

   -- Outputs form the Bus devices
--   signal bus_register_out : busdevice_out_type;
begin
   ----------------------------------------------------------------------------
   -- FSMC connection to the STM32F4xx and Busmaster
   -- for the internal bus
   fsmc_i.data  <= fsmc_data_p;
   fsmc_i.cs_n  <= fsmc_cs_np;
   fsmc_i.wr_n  <= fsmc_we_np;
   fsmc_i.rd_n  <= fsmc_oe_np;
   fsmc_i.adv_n <= fsmc_adv_np;
   fsmc_i.bl_n  <= fsmc_bl_np;
   fsmc_i.clk   <= fsmc_clk_p;

   fsmc : entity work.fsmc_slave
      port map (
         fsmc_o => fsmc_o,
         fsmc_i => fsmc_i,
         bus_o  => bus_o,
         bus_i  => bus_i,
         clk    => clk);

   fsmc_data_p <= fsmc_o.data when (fsmc_o.oe = '1') else (others => 'Z');

   ----------------------------------------------------------------------------
   -- Register
--   preg : peripheral_register
--      generic map (
--         BASE_ADDRESS => 16#0000#)
--      port map (
--         dout_p => register_out,
--         din_p  => register_in,
--         bus_o  => bus_register_out,
--         bus_i  => bus_o,
--         reset  => reset,
--         clk    => clk);

--   register_in <= x"4600";

   ----------------------------------------------------------------------------
   led_clk : clock_divider
      generic map (
         DIV => 25000000)
      port map (
         clk_out_p => led_clock_en,
         clk       => clk);

   process (clk)
   begin
      if rising_edge(clk) then
         if led_clock_en = '1' then
            led(5) <= not led(5);
         end if;
      end if;
   end process;

   led(4 downto 0) <= "00000";          --not register_out(3 downto 0);
   led_p           <= led;
end structural;
