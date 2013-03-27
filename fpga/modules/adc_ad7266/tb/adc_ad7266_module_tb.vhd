-------------------------------------------------------------------------------
-- Title      : Testbench for design "adc_ad7266_single_ended_module"
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Standard: VHDL '87
-- Copyright (c) 2013 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.adc_ad7266_pkg.all;
use work.bus_pkg.all;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------

entity adc_ad7266_module_tb is

end adc_ad7266_module_tb;


architecture tb of adc_ad7266_module_tb is
   
   component adc_ad7266_single_ended_module
      generic (
         BASE_ADDRESS : integer range 0 to 32767;
         CHANNELS     : positive);
      port (
           adc_out_p    : out adc_ad7266_spi_out_type;
           adc_in_p     : in  adc_ad7266_spi_in_type;
           bus_o        : out busdevice_out_type;
           bus_i        : in  busdevice_in_type;
           adc_values_o : out adc_ad7266_values_type(CHANNELS - 1 downto 0);
           clk          : in  std_logic);
   end component;

   -- component generics
   constant   BASE_ADDRESS : integer range 0 to 32767 := 0;
   constant CHANNELS     : positive := 12;

   -- component ports
   signal adc_out      : adc_ad7266_spi_out_type;
   signal adc_in       : adc_ad7266_spi_in_type;
   signal bus_o        : busdevice_out_type;
   signal bus_i        : busdevice_in_type := (addr     => (others => '0'),
                                            data => (others => '0'),
                                            we   => '0',
                                            re   => '0');
   signal adc_values_o : adc_ad7266_values_type(CHANNELS - 1 downto 0);
   signal clk          : std_logic := '1';

begin  -- tb

   
   -- component instantiation
   DUT: adc_ad7266_single_ended_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         CHANNELS     => CHANNELS)
      port map (
         adc_out_p    => adc_out,
         adc_in_p     => adc_in,
         bus_o        => bus_o,
         bus_i        => bus_i,
         adc_values_o => open,
         clk          => clk);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  bus_stimulus_proc: process
  begin
    -- insert signal assignments here
      bus_i.addr <= (others => '0');
      bus_i.data <= (others => '0');
      bus_i.re   <= '0';
      bus_i.we   <= '0';

      wait until Clk = '1';


      wait until Clk = '1';
      bus_i.addr <= (others => '0');
      bus_i.data <= "0000" & "0000" & "0000" & "0001";
      bus_i.re   <= '0';
      bus_i.we   <= '1';

      wait until Clk = '1';
      bus_i.we <= '0';

      wait until Clk = '1';
      wait until Clk = '1';


      wait until Clk = '1';
      bus_i.addr(0) <= '1';
      bus_i.data    <= "0000" & "0000" & "0000" & "0001";
      bus_i.re      <= '0';
      bus_i.we      <= '1';

      wait until Clk = '1';
      bus_i.data <= (others => '0');
      bus_i.we   <= '0';


      wait until Clk = '1';
      wait until Clk = '1';
      wait until Clk = '1';

      -- read the registers
      bus_i.addr(0) <= '0';
      bus_i.re      <= '1';
      wait until Clk = '1';
      bus_i.re      <= '0';
      wait until Clk = '1';


      bus_i.addr(0) <= '1';
      bus_i.re      <= '1';
      wait until Clk = '1';
      bus_i.re      <= '0';
      wait until Clk = '1';

      wait until Clk = '1';
      wait until Clk = '1';
      wait until Clk = '1';


      -- do the same reads, but the DUT shouldn't react
      bus_i.addr(0) <= '0';
      bus_i.addr(8) <= '0';             -- another address
      bus_i.re      <= '1';
      wait until Clk = '1';
      bus_i.re      <= '0';
      wait until Clk = '1';


      bus_i.addr(0) <= '1';
      bus_i.re      <= '1';
      wait until Clk = '1';
      bus_i.re      <= '0';
      wait until Clk = '1';


      wait for 10000 NS;

  end process bus_stimulus_proc;


     -----------------------------------------------------------------------------
   -- ADC side stimulus
   -----------------------------------------------------------------------------

  process
  begin
  --  adc_in.d_a <= 'Z';
  --  adc_in.d_b <= 'Z';

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
   -- adc_in.d_a <= 'Z';
   -- adc_in.d_b <= 'Z';
    
  end process;
   

end tb;

-------------------------------------------------------------------------------

configuration adc_ad7266_module_tb_cfg of adc_ad7266_module_tb is
   for tb
   end for;
end adc_ad7266_module_tb_cfg;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
