-------------------------------------------------------------------------------
-- Title      : Testbench for design "adc_mcp3008_module"
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity adc_mcp3008_module_tb is

end adc_mcp3008_module_tb;

-------------------------------------------------------------------------------

architecture tb of adc_mcp3008_module_tb is

   use work.adc_mcp3008_pkg.all;
   use work.reg_file_pkg.all;
   use work.bus_pkg.all;

   -- component generics
   constant BASE_ADDRESS : integer range 0 to 16#7FFF# := 0;

   -- component ports
   signal adc_out_p : adc_mcp3008_spi_out_type;
   signal adc_in_p  : adc_mcp3008_spi_in_type;
   signal bus_o     : busdevice_out_type;
   signal bus_i     : busdevice_in_type := (addr     => (others => '0'),
                                            data => (others => '0'),
                                            we   => '0',
                                            re   => '0');
   signal miso_p : std_logic;
   signal mosi_p : std_logic;
   signal cs_np  : std_logic;
   signal sck_p  : std_logic;

   -- clock
   signal clk : std_logic := '1';

begin  -- tb

   -- component instantiation
   DUT : adc_mcp3008_module
      generic map (
         BASE_ADDRESS => BASE_ADDRESS)
      port map (
         adc_out_p    => adc_out_p,
         adc_in_p     => adc_in_p,
         bus_o        => bus_o,
         bus_i        => bus_i,
         adc_values_o => open,
         clk          => clk);


   -- clock generation
   Clk <= not Clk after 10 NS;

   adc_in_p.miso <= miso_p;
   mosi_p        <= adc_out_p.mosi;
   cs_np         <= adc_out_p.cs_n;
   sck_p         <= adc_out_P.sck;

   -- waveform generation
   bus_stimulus_proc : process
   begin
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
      miso_p <= 'Z';

      wait until cs_np = '0';

      wait until sck_p = '1';
      wait until sck_p = '0';
      wait until sck_p = '0';
      wait until sck_p = '0';
      wait until sck_p = '0';
      wait until sck_p = '0';
      wait until sck_p = '0';

      -- leading zero of mcp3008
      miso_p <= '0';
      wait until sck_p = '0';

      -- actual MSB of conversion
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '0';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '0';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '0';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';

      wait until sck_p = '0';
      miso_p <= 'Z';





      miso_p <= 'Z';

      wait until cs_np = '0';

      wait until sck_p = '1';
      wait until sck_p = '0';
      wait until sck_p = '0';
      wait until sck_p = '0';
      wait until sck_p = '0';
      wait until sck_p = '0';
      wait until sck_p = '0';

      -- leading zero of mcp3008
      miso_p <= '0';
      wait until sck_p = '0';

      -- actual MSB of conversion
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';
      wait until sck_p = '0';
      miso_p <= '1';

      wait until sck_p = '0';
      miso_p <= 'Z';


   end process;

   

end tb;

-------------------------------------------------------------------------------

configuration adc_mcp3008_module_tb_tb_cfg of adc_mcp3008_module_tb is
   for tb
   end for;
end adc_mcp3008_module_tb_tb_cfg;

-------------------------------------------------------------------------------
