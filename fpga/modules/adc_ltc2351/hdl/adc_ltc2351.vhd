-------------------------------------------------------------------------------
-- Title      : 1.5Msps 6-channel synchronously sampling ADC LTC2351
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_ltc2351.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-10
-- Last update: 2012-04-12
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  : see git repro
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.adc_ltc2351_pkg.all;

-------------------------------------------------------------------------------

entity adc_ltc2351 is

  generic (
    APFEL      : natural := 5;          -- unused now
    RESOLUTION : natural := 14          -- resolution of the ADC
    );
  port (
    -- signal to and from real hardware
    adc_out : out adc_ltc2351_spi_out_type;
    adc_in  : in  adc_ltc2351_spi_in_type;

    -- signals to other logic in FPGA
    start_p : in  std_logic;
    value_p : out adc_values_type(0 to 5);
    done_p  : out std_logic;

    -- reset and clock
    reset : in std_logic;
    clk   : in std_logic
    );

end adc_ltc2351;

-------------------------------------------------------------------------------

architecture behavioral of adc_ltc2351 is

  type adc_ltc2351_state_type is (IDLE, SCK_LOW, SCK_HIGH);

  type adc_ltc2351_type is record
    state           : adc_ltc2351_state_type;
    sck             : std_logic;
    conv            : std_logic;
    done            : std_logic;
    -- 96 data bits and two bit times for CONV accordingly to datasheet
    din             : std_logic_vector(1 to 98);
    countdown_bit   : integer range 1 to 98;
    countdown_delay : integer range 0 to 1;
  end record;


  -- -----------------------------------------------------------------------------
  -- Internal signal declarations
  -- -----------------------------------------------------------------------------
  signal r, rin : adc_ltc2351_type;

  -- -----------------------------------------------------------------------------
  -- Component declarations
  -- -----------------------------------------------------------------------------

begin
  -- -----------------------------------------------------------------------------
  -- connect internal signals to out
  -- -----------------------------------------------------------------------------

  -- output to ADC
  adc_out.sck  <= r.sck;
  adc_out.conv <= r.conv;

  -- outputs of this entity
  done_p <= r.done;                     -- signals valid data on value_p

  -- values of the last conversion
  value_p(0) <= r.din(3 to 16);
  value_p(1) <= r.din(19 to 32);
  value_p(2) <= r.din(35 to 48);
  value_p(3) <= r.din(51 to 64);
  value_p(4) <= r.din(67 to 80);
  value_p(5) <= r.din(83 to 96);

  -- -----------------------------------------------------------------------------
  -- Sequential proc of FSM
  -- -----------------------------------------------------------------------------
  seq_proc : process(reset, clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        r.state           <= IDLE;
        r.sck             <= '0';
        r.conv            <= '0';
        r.countdown_bit   <= 98;
        r.countdown_delay <= 1;
      else
        r <= rin;
      end if;
    end if;
    
  end process seq_proc;

  -- -----------------------------------------------------------------------------
  -- Transitons and actions of FSM
  -- -----------------------------------------------------------------------------

  comb_proc : process(adc_in.sdo, r, start_p)
    variable v : adc_ltc2351_type;
    
  begin
    v := r;

    case v.state is
      -- -------------------------------------------------------------------------
      -- Idle State
      -- Wait until a start of conversion was requested by start_p
      -- -------------------------------------------------------------------------
      when IDLE =>
        v.done := '0';
        if start_p = '1' then
          v.state           := SCK_LOW;
          v.sck             := '0';
          v.conv            := '1';
          v.countdown_bit   := 98;
          v.countdown_delay := 1;
        else
          -- keep sck running
          v.sck := not r.sck;
        end if;  -- start_p

        -- -------------------------------------------------------------------------
        -- Low period of SCK
        -- -------------------------------------------------------------------------
      when SCK_LOW =>
        v.state := SCK_HIGH;
        v.sck   := '1';

        -- -------------------------------------------------------------------------
        -- High period of SCK
        -- -------------------------------------------------------------------------
      when SCK_HIGH =>
        v.state := SCK_LOW;
        v.sck   := '0';
        v.conv  := '0';

        -- sample v.din on the H->L transition of SCK
        v.din := r.din(2 to 98) & adc_in.sdo;
        if r.countdown_bit = 1 then
          -- 96th bit
          -- TODO count from 1 to 98
          v.state := IDLE;
          v.sck   := '0';
          v.done  := '1';
        else
          v.countdown_bit := r.countdown_bit - 1;
        end if;
    end case;

    rin <= v;
  end process comb_proc;

  -----------------------------------------------------------------------------
  -- Component instantiations
  -----------------------------------------------------------------------------

end behavioral;

