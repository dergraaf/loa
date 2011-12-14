-------------------------------------------------------------------------------
-- Title      : Motortestboard
-------------------------------------------------------------------------------
-- File       : toplevel.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-14
-- Last update: 2011-12-14
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
-- This board is used to develop the FPGA and STM32F4xx Peripherals and
-- test if the system is suitable as main controller for the RCA robots.
-- 
-- The FPGA is able to control the following peripherals:
-- 2x Brushless Motor (with Hall-Sensors and Encoders)
-- 2x DC Motor (with Encoders)
-- 1x RGB LED
-- ...
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.spislave_pkg.all;
use work.pwm_module_pkg.all;

-------------------------------------------------------------------------------
entity toplevel is
  port (
    -- Motortestboard
    led_red_p   : out std_logic;
    led_green_p : out std_logic;
    led_blue_p  : out std_logic;

    -- Connections to the STM32F407
    cs_np  : in  std_logic;
    sck_p  : in  std_logic;
    miso_p : out std_logic;
    mosi_p : in  std_logic;

    load_p  : in std_logic;  -- On the rising edge encoders etc are sampled
    reset_n : in std_logic;

    -- Internal connections
    led_np : out std_logic_vector (3 downto 0);
    sw_np  : in  std_logic_vector (1 downto 0);

    clk : in std_logic
    );
end toplevel;

architecture behavioral of toplevel is
  signal reset_sync : std_logic_vector(1 downto 0) := (others => '0');
  signal reset      : std_logic;

  signal led : std_logic_vector(3 downto 0);

  -- Connection to the Busmaster
  signal bus_o   : busmaster_out_type;
  signal bus_i   : busmaster_in_type;

  -- Outputs form the Bus devices
  signal bus_pwm1_out : busdevice_out_type;
  signal bus_pwm2_out : busdevice_out_type;
  signal bus_pwm3_out : busdevice_out_type;
begin
  -- synchronize reset
  process (clk)
  begin
    if rising_edge(clk) then
      reset_sync <= reset_sync(0) & reset_n;
    end if;
  end process;

  reset <= not reset_sync(1);

  -- blinking led
  process
    variable cnt : integer range 0 to 24999999;
  begin
    wait until rising_edge(clk);
    if reset = '1' then
      led <= "0000";
      cnt := 24999999;
    else
      -- 0...24999999 = 25000000 Takte = 1/2 Sekunde bei 50MHz 
      if cnt < (24999999 - 1) then
        cnt := cnt + 1;
      else
        cnt    := 0;
        led(0) <= not led(0);
      end if;
    end if;
  end process;

  led_np <= not led;

  -----------------------------------------------------------------------------
  -- SPI connection to the STM32F4xx and Busmaster
  -- for the internal bus
  spi : spi_slave
    port map (
      miso_p => miso_p,
      mosi_p => mosi_p,
      sck_p  => sck_p,
      csn_p  => cs_np,

      bus_o   => bus_o,
      bus_i   => bus_i,
      
      reset => reset,
      clk   => clk
      );

  bus_i.data <= bus_pwm1_out.data or bus_pwm2_out.data or bus_pwm3_out.data;
  
  -----------------------------------------------------------------------------
  -- Bus devices
  pwm_module_1: pwm_module
    generic map (
      BASE_ADDRESS => 0,
      WIDTH        => 16,
      PRESCALER    => 2)
    port map (
      pwm_p => led_red_p,
      bus_o => bus_pwm1_out,
      bus_i => bus_o,
      reset => reset,
      clk   => clk);
  
  pwm_module_2: pwm_module
    generic map (
      BASE_ADDRESS => 1,
      WIDTH        => 16,
      PRESCALER    => 2)
    port map (
      pwm_p => led_green_p,
      bus_o => bus_pwm2_out,
      bus_i => bus_o,
      reset => reset,
      clk   => clk);
  
  pwm_module_3: pwm_module
    generic map (
      BASE_ADDRESS => 2,
      WIDTH        => 16,
      PRESCALER    => 2)
    port map (
      pwm_p => led_blue_p,
      bus_o => bus_pwm3_out,
      bus_i => bus_o,
      reset => reset,
      clk   => clk);
  
  -----------------------------------------------------------------------------
end behavioral;
