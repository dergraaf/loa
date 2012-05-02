-------------------------------------------------------------------------------
-- Title      : Transmitter for infrared beacons
-- Project    : 
-------------------------------------------------------------------------------
-- File       : uss_tx_module.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-13
-- Last update: 2012-05-02
-- Platform   : 
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
use work.reg_file_pkg.all;
use work.motor_control_pkg.all;

-------------------------------------------------------------------------------

entity ir_tx_module is
   
   generic (
      BASE_ADDRESS : integer range 0 to 32767  -- Base address at the internal data bus
      );
   port (
      -- Ports to the ultrasonic transmitters
      ir_tx_p : out std_logic;

      -- Modulation input for one infrared  transmitter
      modulation_p : in std_logic;

      -- Output of the clock enable signal
      clk_ir_enable_p : out std_logic;

      -- signals to and from the internal parallel bus
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk : in std_logic
      );

end ir_tx_module;

-------------------------------------------------------------------------------

architecture behavioral of ir_tx_module is


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

   signal clk_ir_enable : std_logic := '0';
   signal clk_ir        : std_logic := '0';  -- Clock signal with 50% duty cycle

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
         clk_out_p => clk_ir_enable,
         clk       => clk);

   -- generate a signal with a 50% duty-cycle from the enable signal
   process (clk, clk_ir_enable)
   begin
      if rising_edge(clk) then
         if clk_ir_enable = '1' then
            clk_ir <= not clk_ir;
         end if;
      end if;
   end process;

   -----------------------------------------------------------------------------
   -- Mapping of signals between components and module ports
   -----------------------------------------------------------------------------

   clk_mul <= reg_o(0);
   clk_div <= reg_o(1);

   clk_ir_enable_p <= clk_ir_enable;


   -----------------------------------------------------------------------------
   -- Drive Ultrasonic transmitters
   -----------------------------------------------------------------------------
   ir_tx_p <= clk_ir and modulation_p;
   
end behavioral;
