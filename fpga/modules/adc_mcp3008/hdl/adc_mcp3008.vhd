-------------------------------------------------------------------------------
-- Title      : Title String
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_mcp3008.vhd
-- Author     : Calle  <calle@Alukiste>
-- Company    : 
-- Created    : 2011-09-27
-- Last update: 2012-02-12
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

use work.adc_mcp3008_pkg.all;

-------------------------------------------------------------------------------

entity adc_mcp3008 is

  generic (
    DELAY : natural := 39               -- waitstates between toggling the
                                        -- SCK line (MCP3008 max: about 1.3 MHz)
    );
  port (
    --adc_in.miso : in  std_logic;
    --adc_out.mosi : out std_logic;
    --adc_out.cs_n  : out std_logic;
    --adc_out.sck  : out std_logic;

    adc_out : out adc_mcp3008_spi_out_type;
    adc_in  : in  adc_mcp3008_spi_in_type;

    start_p    : in  std_logic;
    adc_mode_p : in  std_logic;
    channel_p  : in  std_logic_vector(2 downto 0);
    value_p    : out std_logic_vector(9 downto 0);
    done_p     : out std_logic;

    reset : in std_logic;
    clk   : in std_logic
    );

end adc_mcp3008;

-------------------------------------------------------------------------------

architecture behavioral of adc_mcp3008 is

  type adc_mcp3008_state_type is (IDLE, SCK_LOW, SCK_HIGH);

  type adc_mcp3008_type is record
    state           : adc_mcp3008_state_type;
    csn             : std_logic;
    sck             : std_logic;
    din             : std_logic_vector(9 downto 0);
    done            : std_logic;
    countdown_delay : integer range 0 to DELAY;
    countdown_bit   : integer range 0 to 16;
    dout            : std_logic_vector(4 downto 0);
  end record;


  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : adc_mcp3008_type;

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------

begin
  
  seq_proc : process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        r.state           <= IDLE;
        r.csn             <= '1';
        r.sck             <= '0';
        r.dout            <= "11111";
        r.din             <= (others => '0');
        r.done            <= '0';
        r.countdown_bit   <= 0;
        r.countdown_delay <= DELAY;
      else
        r <= rin;
      end if;
    end if;
  end process seq_proc;

  adc_out.cs_n <= r.csn;
  adc_out.sck  <= r.sck;
  adc_out.mosi <= r.dout(4);

  done_p  <= r.done;
  value_p <= r.din;

  comb_proc : process(adc_mode_p, channel_p, adc_in.miso, r, start_p)
    variable v : adc_mcp3008_type;
  begin
    v := r;

    case v.state is
      when IDLE =>
        v.csn  := '1';
        v.done := '0';
        if start_p = '1' then
          v.state := SCK_LOW;
          v.sck   := '0';

          v.countdown_delay := DELAY;
          v.countdown_bit   := 16;
          v.dout            := '1' & adc_mode_p & channel_p;
        end if;

      when SCK_LOW =>
        v.csn := '0';
        if r.countdown_delay = 0 then
          v.state           := SCK_HIGH;
          v.sck             := '1';
          v.countdown_delay := DELAY;
          v.din             := r.din(8 downto 0) & adc_in.miso;  --    no need to synchronize
                                        --    this signal, as it is
                                        --    already in sync with
                                        --    adc_out.sck and clk.
        else
          v.countdown_delay := v.countdown_delay -1;
        end if;

      when SCK_HIGH =>
        if r.countdown_delay = 0 then
          v.state := SCK_LOW;
          v.sck   := '0';

          v.countdown_delay := DELAY;
          v.dout            := r.dout(3 downto 0) & '0';

          if r.countdown_bit = 0 then
            v.state := IDLE;
            v.sck   := '0';
            v.done  := '1';
          else
            v.countdown_bit := v.countdown_bit - 1;
            
          end if;
          
        else
          v.countdown_delay := v.countdown_delay -1;
        end if;
        
    end case;

    rin <= v;
  end process comb_proc;

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

end behavioral;
