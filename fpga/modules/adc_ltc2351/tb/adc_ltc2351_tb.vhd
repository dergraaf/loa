-------------------------------------------------------------------------------
-- Title      : Testbench for design "adc" (not module)
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;

-------------------------------------------------------------------------------

entity adc_ltc2351_tb is

end adc_ltc2351_tb;

-------------------------------------------------------------------------------
architecture tb of adc_ltc2351_tb is

  use work.adc_ltc2351_pkg.all;

  -- Component generics
  constant BASE_ADDRESS : positive := 16#0100#;

  -- component ports
  signal sck_p : std_logic;
  signal sdo_p : std_logic;

  signal start_p : std_logic;
  signal conv_p  : std_logic;
  signal done_p  : std_logic;

  signal clk   : std_logic := '0';

  signal adc_i : adc_ltc2351_spi_in_type;
  signal adc_o : adc_ltc2351_spi_out_type;

begin
  -- component instantiation
  DUT : adc_ltc2351
    port map (
      -- connection between component's signals (left) and 
      -- testbench's signals (right)
      adc_out => adc_o,
      adc_in  => adc_i,
      start_p => start_p,
      done_p  => done_p,
      clk     => clk
      );

  -- connection between signals of DUT 
  -- and testbench signals
  adc_i.sdo <= sdo_p;
  sck_p     <= adc_o.sck;
  conv_p    <= adc_o.conv;


-----------------------------------------------------------------------------
  -- clock generation
  clk <= not clk after 10 ns;

-----------------------------------------------------------------------------
  -- stimuli generation
  waveform : process
  begin
    start_p <= '0';

    wait for 200 ns;

    start_p <= '1';
    wait for 100 ns;
    start_p <= '0';
    wait for 10 ms;

    for i in 1 to 3 loop
      wait until rising_edge(clk);
--         encoder.a <= '1';
      wait until rising_edge(clk);
--         encoder.b <= '1';
      wait until rising_edge(clk);
--         encoder.a <= '0';
      wait until rising_edge(clk);
--         encoder.b <= '0';
      wait until rising_edge(clk);
    end loop;  -- i

    -- repeat process
    wait for 50 ns;
  end process waveform;

-----------------------------------------------------------------------------
  -- ADC side stimulus
  -- simulate the behaviour of the ADC here and generate test data. 
  process
  begin
    sdo_p <= 'Z';

    -- wait for rising edge of conv
    wait until sck_p = '0';
    wait until conv_p = '1';
    wait until sck_p = '1';

    -- 6 words of 14 bit, separated by two Hi-Z's
    for i in 1 to 6 loop                -- two bits high-Z
      wait until sck_p = '1';
      wait until sck_p = '1';

      -- start output of data, 14 bits
      sdo_p <= '1';
      wait until sck_p = '1';
      sdo_p <= '0';
      wait until sck_p = '1';
      sdo_p <= '1';
      wait until sck_p = '1';
      sdo_p <= '0';
      wait until sck_p = '1';
      sdo_p <= '1';
      wait until sck_p = '1';
      sdo_p <= '0';
      wait until sck_p = '1';
      sdo_p <= '1';
      wait until sck_p = '1';
      sdo_p <= '0';
      wait until sck_p = '1';
      sdo_p <= '0';
      wait until sck_p = '1';
      sdo_p <= '0';
      wait until sck_p = '1';
      sdo_p <= '1';
      wait until sck_p = '1';
      sdo_p <= '1';
      wait until sck_p = '1';
      sdo_p <= '1';
      wait until sck_p = '1';
      sdo_p <= '0';
      wait until sck_p = '1';
      sdo_p <= 'Z';
    end loop;  -- i

    -- repeat everything
  end process;
  -----------------------------------------------------------------------------

end tb;

configuration adc_ltc2351_tb_tb_cfg of adc_ltc2351_tb is
  for tb
  end for;
end adc_ltc2351_tb_tb_cfg;


