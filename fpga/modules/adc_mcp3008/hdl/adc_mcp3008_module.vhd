-------------------------------------------------------------------------------
-- Title      : Title String
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_mcp3008_module.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2011-09-27
-- Last update: 2012-03-15
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-09-27  1.0      calle   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.adc_mcp3008_pkg.all;

-------------------------------------------------------------------------------

entity adc_mcp3008_module is
  generic (
    BASE_ADDRESS : integer range 0 to 32767);
  port (
    adc_out_p : out adc_mcp3008_spi_out_type;
    adc_in_p  : in  adc_mcp3008_spi_in_type;

    bus_o : out busdevice_out_type;
    bus_i : in  busdevice_in_type;

    adc_values_o : out adc_values_type(7 downto 0);

    reset : in std_logic;
    clk   : in std_logic
    );

end adc_mcp3008_module;

-------------------------------------------------------------------------------

architecture behavioral of adc_mcp3008_module is

  type adc_mcp3008_module_state_type is (IDLE, WAIT_FOR_ADC);

  type adc_mcp3008_module_type is record
    state      : adc_mcp3008_module_state_type;
    start      : std_logic;
    current_ch : integer range 0 to 7;
    reg        : reg_file_type(7 downto 0);
  end record;


  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : adc_mcp3008_module_type;

  --signal adc_out    : adc_mcp3008_spi_out_type;
  --signal adc_in     : adc_mcp3008_spi_in_type;
  signal start_s    : std_logic;
  signal adc_mode_s : std_logic;
  signal channel_s  : std_logic_vector(2 downto 0);
  signal value_s    : std_logic_vector(9 downto 0);
  signal done_s     : std_logic;

  --signal bus_o : busdevice_out_type;
  --signal bus_i : busdevice_in_type;
  signal reg_o : reg_file_type(7 downto 0);
  signal reg_i : reg_file_type(7 downto 0);


  signal mask_s : std_logic_vector(7 downto 0);
  --signal values_s: adc_values_type(7 downto 0);

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

begin

  adc_mode_s   <= '1';                  -- we don't use differential mode
  channel_s    <= std_logic_vector(to_unsigned(r.current_ch, 3));
  reg_i        <= r.reg;
  adc_values_o(0) <= r.reg(0)(9 downto 0);
  adc_values_o(1) <= r.reg(1)(9 downto 0);
  adc_values_o(2) <= r.reg(2)(9 downto 0);
  adc_values_o(3) <= r.reg(3)(9 downto 0);
  adc_values_o(4) <= r.reg(4)(9 downto 0);
  adc_values_o(5) <= r.reg(5)(9 downto 0);
  adc_values_o(6) <= r.reg(6)(9 downto 0);
  adc_values_o(7) <= r.reg(7)(9 downto 0);
  mask_s       <= reg_o(0)(7 downto 0);

  reg_file_1 : reg_file
    generic map (
      BASE_ADDRESS => BASE_ADDRESS,
      REG_ADDR_BIT => 3)
    port map (
      bus_o => bus_o,
      bus_i => bus_i,
      reg_o => reg_o,
      reg_i => reg_i,
      reset => reset,
      clk   => clk);


  adc_mcp3008_1 : adc_mcp3008
    generic map (
      DELAY => 39)
    port map (
      adc_out    => adc_out_p,
      adc_in     => adc_in_p,
      start_p    => r.start,
      adc_mode_p => adc_mode_s,
      channel_p  => channel_s,
      value_p    => value_s,
      done_p     => done_s,
      reset      => reset,
      clk        => clk);

  seq_proc : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        r.state      <= IDLE;
        r.current_ch <= 7;
        r.start      <= '0';
        r.reg        <= (others => (others => '0'));
      else
        r <= rin;
      end if;
    end if;
  end process seq_proc;


  comb_proc : process(done_s, mask_s, r, value_s)
    variable v : adc_mcp3008_module_type;
    
  begin
    v := r;

    case v.state is
      when IDLE =>
        if v.current_ch = 7 then
          v.current_ch := 0;
        else
          v.current_ch := v.current_ch + 1;
        end if;

        if mask_s(v.current_ch) = '0' then
          v.start := '1';
          v.state := WAIT_FOR_ADC;
        end if;

      when WAIT_FOR_ADC =>
        v.start := '0';
        if done_s = '1' then
          v.reg(v.current_ch) := "000000" & value_s;
          v.state             := IDLE;
        end if;
        
      when others =>
        null;
    end case;

    rin <= v;
  end process comb_proc;

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

end behavioral;


