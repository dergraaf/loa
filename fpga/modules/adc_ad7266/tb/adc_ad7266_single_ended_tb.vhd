-------------------------------------------------------------------------------
-- Title      : Testbench for design "adc_ad7266_single_ended"
-- Project    : 
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.adc_ad7266_pkg.all;
-------------------------------------------------------------------------------

entity adc_ad7266_single_ended_tb is

end adc_ad7266_single_ended_tb;

-------------------------------------------------------------------------------

architecture tb of adc_ad7266_single_ended_tb is

   component adc_ad7266_single_ended
      generic (
         DELAY : natural);
      port (
         adc_out    : out adc_ad7266_spi_out_type;
         adc_in     : in  adc_ad7266_spi_in_type;
         start_p    : in  std_logic;
         adc_mode_p : in  std_logic;
         channel_p  : in  std_logic_vector(2 downto 0);
         value_a_p  : out std_logic_vector(11 downto 0);
         value_b_p  : out std_logic_vector(11 downto 0);
         done_p     : out std_logic;
         clk        : in  std_logic);
   end component;

   -- component generics
   constant DELAY : natural := 1;

   -- component ports
   signal adc_out    : adc_ad7266_spi_out_type;
   signal adc_in     : adc_ad7266_spi_in_type;
   signal start_p    : std_logic:= '0';
   signal adc_mode_p : std_logic:= '0';
   signal channel_p  : std_logic_vector(2 downto 0):= "000";
   signal value_a_p  : std_logic_vector(11 downto 0):= (others => '0');
   signal value_b_p  : std_logic_vector(11 downto 0):= (others => '0');
   signal done_p     : std_logic:='0';

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

   -- component instantiation
   DUT: adc_ad7266_single_ended
      generic map (
         DELAY => DELAY)
      port map (
         adc_out    => adc_out,
         adc_in     => adc_in,
         start_p    => start_p,
         adc_mode_p => adc_mode_p,
         channel_p  => channel_p,
         value_a_p  => value_a_p,
         value_b_p  => value_b_p,
         done_p     => done_p,
         clk        => clk);
   
----------------------------------------------------------------------------
----------------------------------------------------------------------------

  -- clock generation
  Clk <= not Clk after 20 ns;

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    start_p    <= '0';
    adc_mode_p <= '1';
    channel_p  <= "011";
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    start_p    <= '1';
    wait until Clk = '1';
    start_p    <= '0';
    wait until Clk = '1';

    wait for 1 ms;
 
  end process WaveGen_Proc;

  -----------------------------------------------------------------------------
  -- ADC side stimulus
  -----------------------------------------------------------------------------
  
  process
  begin
    adc_in.d_a <= 'Z';
    adc_in.d_b <= 'Z';

    wait until adc_out.cs_n = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '0';

   -- wait until sck_p = '1';
   -- wait until sck_p = '0';
   -- wait until sck_p = '0';
   -- wait until sck_p = '0';
   -- wait until sck_p = '0';
   -- wait until sck_p = '0';
   -- wait until sck_p = '0';

    -- leading zero of AD7266
    wait until adc_out.sck = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '0';
    
    -- actual MSB of conversion
    wait until adc_out.sck = '0';
    adc_in.d_a <= '1';
    adc_in.d_b <= '1';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '1';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '1';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '1';
    adc_in.d_b <= '0';
    
    wait until adc_out.sck = '0';
    adc_in.d_a <= '1';
    adc_in.d_b <= '0';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '1';
    adc_in.d_b <= '1';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '1';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '1';
    
    wait until adc_out.sck = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '1';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '1';
    adc_in.d_b <= '0';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '1';
    adc_in.d_b <= '1';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '1';
    adc_in.d_b <= '0';

--trailing TWO zeros
    wait until adc_out.sck = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '0';
    wait until adc_out.sck = '0';
    adc_in.d_a <= '0';
    adc_in.d_b <= '0';

 ------------------------------------------------------------------------------
    wait until adc_out.sck = '0';
    adc_in.d_a <= 'Z';
    adc_in.d_b <= 'Z';

    wait for 1 ms;
  end process;
   

end tb;

-------------------------------------------------------------------------------

configuration adc_ad7266_single_ended_tb_tb_cfg of adc_ad7266_single_ended_tb is
   for tb
   end for;
end adc_ad7266_single_ended_tb_tb_cfg;

-------------------------------------------------------------------------------
