-------------------------------------------------------------------------------
-- Title      : Transmitter for ultrasonic beacons
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--
-- Register description
--
-- offset | Meaning
-- -------+---------
--   0x00 | Fractional Clock Divider MUL value
--   0x01 | Fractional Clock Divider DIV value
--   
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.motor_control_pkg.all;         -- for half_bridge_type
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------

entity uss_tx_module is
   
   generic (
      BASE_ADDRESS : integer range 0 to 32767  -- Base address at the internal data bus
      );
   port (
      -- Ports to the ultrasonic transmitters
      uss_tx0_out_p : out half_bridge_type;
      uss_tx1_out_p : out half_bridge_type;
      uss_tx2_out_p : out half_bridge_type;

      -- Modulation input for three ultrasonic transmitters
      modulation_p : in std_logic_vector(2 downto 0);

      -- Output of the clock enable signal
      clk_uss_enable_p : out std_logic;

      -- signals to and from the internal parallel bus
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk : in std_logic
      );

end uss_tx_module;

-------------------------------------------------------------------------------

architecture behavioral of uss_tx_module is


   -- types for states
   -- none

   -- record for internal states 
   -- none

   -----------------------------------------------------------------------------
   -- internal signals
   -----------------------------------------------------------------------------

   -- access to the internal register
   constant REG_ADDR_BIT : natural := 1;  -- 2**1 = 2 registers for mul and div value

   signal reg_o : reg_file_type(((2**REG_ADDR_BIT)-1) downto 0) := (others => (others => '0'));
   signal reg_i : reg_file_type(((2**REG_ADDR_BIT)-1) downto 0) := (others => (others => '0'));

   signal clk_mul : std_logic_vector(15 downto 0);
   signal clk_div : std_logic_vector(15 downto 0);

   signal clk_uss_enable : std_logic := '0';
   signal clk_uss        : std_logic := '0';  -- Clock signal with 50% duty cycle
   signal clk_uss_n      : std_logic;

   signal uss_tx_high : std_logic;
   signal uss_tx_low  : std_logic;

begin  -- behavioral

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------

   -- register for access to and from STM
   reg_file_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => REG_ADDR_BIT
         )
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_o,
         reg_i => reg_i,
         clk   => clk
         );

   -- clock generation of clk_uss_tx
   fractional_clock_divider_variable_1 : fractional_clock_divider_variable
      generic map (
         WIDTH => 16)
      port map (
         div       => clk_div,
         mul       => clk_mul,
         clk_out_p => clk_uss_enable,
         clk       => clk);

   -- generate a signal with a 50% duty-cycle from the enable signal
   process (clk, clk_uss_enable)
   begin
      if rising_edge(clk) then
         if clk_uss_enable = '1' then
            clk_uss <= not clk_uss;
         end if;
      end if;
   end process;

   -- generate clocks with deadtime
   clk_uss_n <= not clk_uss;

   deadtime_on : deadtime
      generic map (
         T_DEAD => 250)                 -- 5000ns
      port map (
         in_p  => clk_uss_n,
         out_p => uss_tx_low,
         clk   => clk);

   deadtime_off : deadtime
      generic map (
         T_DEAD => 250)                 -- 5000ns
      port map (
         in_p  => clk_uss,
         out_p => uss_tx_high,
         clk   => clk);




   -----------------------------------------------------------------------------
   -- Mapping of signals between components and module ports
   -----------------------------------------------------------------------------

   clk_mul <= reg_o(0);
   clk_div <= reg_o(1);

   clk_uss_enable_p <= clk_uss_enable;


   -----------------------------------------------------------------------------
   -- Drive Ultrasonic transmitters
   -----------------------------------------------------------------------------
   uss_tx0_out_p.high <= uss_tx_high and modulation_p(0);
   uss_tx1_out_p.high <= uss_tx_high and modulation_p(1);
   uss_tx2_out_p.high <= uss_tx_high and modulation_p(2);

   uss_tx0_out_p.low <= uss_tx_low and modulation_p(0);
   uss_tx1_out_p.low <= uss_tx_low and modulation_p(1);
   uss_tx2_out_p.low <= uss_tx_low and modulation_p(2);
   
end behavioral;
