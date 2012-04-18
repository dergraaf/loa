-------------------------------------------------------------------------------
-- Title      : 1.5Msps 6-channel synchronously sampling ADC LTC2351
-- Project    : 
-------------------------------------------------------------------------------
-- File       : adc_ltc2351.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-10
-- Last update: 2012-04-18
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
      RESOLUTION : natural := 14        -- resolution of the ADC
      );
   port (
      -- signal to and from real hardware
      adc_out : out adc_ltc2351_spi_out_type;
      adc_in  : in  adc_ltc2351_spi_in_type;

      -- signals to other logic in FPGA
      start_p  : in  std_logic;
      values_p : out adc_ltc2351_values_type(5 downto 0);
      done_p   : out std_logic;

      -- reset and clock
      reset : in std_logic;
      clk   : in std_logic
      );

end adc_ltc2351;

-------------------------------------------------------------------------------

architecture behavioral of adc_ltc2351 is

   constant BITCOUNT      : natural := 98;  -- Number of bits in one response of ADC
   constant CHANNEL_COUNT : natural := 6;   -- Number of channels in ADC

   type adc_ltc2351_state_type is (IDLE, SCK_LOW, SCK_HIGH);

   type adc_ltc2351_type is record
      state           : adc_ltc2351_state_type;
      sck             : std_logic;
      conv            : std_logic;
      done            : std_logic;
      -- 96 data bits and two bit times for CONV accordingly to datasheet
      din             : std_logic_vector(1 to BITCOUNT);
      count_bit       : integer range 1 to BITCOUNT + 1;
      countdown_delay : integer range 0 to 1;
      -- register results of last conversion
      values          : adc_ltc2351_values_type(CHANNEL_COUNT-1 downto 0);
   end record;


   -- -----------------------------------------------------------------------------
   -- Internal signal declarations
   -- -----------------------------------------------------------------------------
   signal r, rin : adc_ltc2351_type := (state           => IDLE,
                                        sck             => '0',
                                        conv            => '0',
                                        done            => '0',
                                        din             => (others => '0'),
                                        count_bit       => 1,
                                        countdown_delay => 0,
                                        values          => (others => (others => '0')));

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
   done_p <= r.done;                    -- signals valid data on value_p

   -- values of the last conversion
   values_p <= r.values;

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
            r.count_bit       <= 1;
            r.countdown_delay <= 1;
            r.values          <= (others => (others => '0'));
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
               v.count_bit       := 1;
               v.countdown_delay := 1;
               -- v.din := r.din(2 to BITCOUNT) & adc_in.sdo;
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
            v.din := r.din(2 to BITCOUNT) & adc_in.sdo;
            if r.count_bit = (BITCOUNT + 1) then
               -- last bit received
               v.state     := IDLE;
               v.sck       := '0';
               v.done      := '1';
               v.values(0) := r.din(3 to 16);
               v.values(1) := r.din(19 to 32);
               v.values(2) := r.din(35 to 48);
               v.values(3) := r.din(51 to 64);
               v.values(4) := r.din(67 to 80);
               v.values(5) := r.din(83 to 96);
            else
               v.count_bit := r.count_bit + 1;
            end if;
      end case;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------

end behavioral;

