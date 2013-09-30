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
   signal start_p    : std_logic                     := '0';
   signal adc_mode_p : std_logic                     := '0';
   signal channel_p  : std_logic_vector(2 downto 0)  := "000";
   signal value_a_p  : std_logic_vector(11 downto 0) := (others => '0');
   signal value_b_p  : std_logic_vector(11 downto 0) := (others => '0');
   signal done_p     : std_logic                     := '0';

   -- clock
   signal Clk : std_logic := '1';

   -- adc_stimulus parametres (vectors are mirrored)
   constant bitstream_a : std_logic_vector(11 downto 0) := "111000111001";  -- result 0x9C7 
   constant bitstream_b : std_logic_vector(11 downto 0) := "010111100110";  -- result 0x67A
   signal bitcounter    : integer range 0 to 16;

begin  -- tb

   -- component instantiation
   DUT : adc_ad7266_single_ended
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
   WaveGen_Proc : process
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

      wait until done_p = '1';
      wait until done_p = '0';
      wait for 1 us;

      start_p <= '1';
      wait until Clk = '1';
      start_p <= '0';
      wait until Clk = '1';

      wait for 1 ms;


   end process WaveGen_Proc;

-------------------------------------------------------------------------------
-- ADC stimulus
----------------------------------------------------------------------------
   -- change input Data
   Input_stimulus : process
   begin
      wait for 200 us;
      -- bitstream_a <= "111000111010";
      -- bitstream_b <= "111000111011";

      wait for 300 us;
      -- bitstream_a <= "111000111100";
      -- bitstream_b <= "111000111101";
   end process Input_stimulus;


   ADC_stimulus : process(adc_out.sck, adc_out.cs_n)
      -- bitstream with second leading and two trailing zeros
      -- DUT should set cs_n HIGH bevor trailing zeros are read in
      variable v_bitstream_a : std_logic_vector(14 downto 0) := '0' & bitstream_a(11 downto 0) & "00";
      variable v_bitstream_b : std_logic_vector(14 downto 0) := '0' & bitstream_b(11 downto 0) & "00";
      variable vbitcounter   : integer range 0 to 16         := bitcounter;
   begin

      if falling_edge(adc_out.cs_n) then
         -- first leading zero
         adc_in.d_a  <= '0';
         adc_in.d_b  <= '0';
         -- reset bitcounter
         vbitcounter := 0;
      elsif adc_out.cs_n = '0' then
         if vbitcounter < 15 then
            if falling_edge(adc_out.sck) then
               vbitcounter := vbitcounter + 1;
               adc_in.d_a  <= v_bitstream_a(vbitcounter);
               adc_in.d_b  <= v_bitstream_b(vbitcounter);
            end if;
         end if;
      else
         adc_in.d_a <= 'Z';
         adc_in.d_b <= 'Z';
      end if;
      bitcounter <= vbitcounter;
   end process ADC_stimulus;

end tb;

-------------------------------------------------------------------------------

configuration adc_ad7266_single_ended_tb_tb_cfg of adc_ad7266_single_ended_tb is
   for tb
   end for;
end adc_ad7266_single_ended_tb_tb_cfg;

-------------------------------------------------------------------------------
