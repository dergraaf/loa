-------------------------------------------------------------------------------
-- Description:
-- Behaviourial model of LTC2351 ADC converter.
-- Very simple, does not support standby and nap. 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.adc_ltc2351_pkg.all;

-------------------------------------------------------------------------------

entity adc_ltc2351_model is
  
  generic (
    -- TODO find how to init a 14-bit vector with a hexadecimal
    DATA_CH1 : std_logic_vector(13 downto 0) := "01" & x"f55";
    DATA_CH2 : std_logic_vector(13 downto 0) := "11" & x"7f3";
    DATA_CH3 : std_logic_vector(13 downto 0) := "10" & x"492";
    DATA_CH4 : std_logic_vector(13 downto 0) := "11" & x"af1";
    DATA_CH5 : std_logic_vector(13 downto 0) := "01" & x"b34";
    DATA_CH6 : std_logic_vector(13 downto 0) := "00" & x"59f");

  port (
    sck  : in  std_logic;
    conv : in  std_logic;
    sdo  : out std_logic := 'Z');

end adc_ltc2351_model;

architecture behavioral of adc_ltc2351_model is

  type adc_ltc2351_state_type is (IDLE, SAMPLING);

  type adc_ltc2351_model_type is record
    state     : adc_ltc2351_state_type;
    count_bit : integer range 1 to 98;
    adc_data  : std_logic_vector(1 to 98);
    sdo       : std_logic;
  end record;

  ----------------------------------------------------------------------------
  -- Internal signal declarations
  ----------------------------------------------------------------------------
  signal r, rin : adc_ltc2351_model_type;

begin  -- behavioral
--   rin.adc_data <= 
  ----------------------------------------------------------------------------
  -- Component declarations
  ----------------------------------------------------------------------------

  -- none

  -------------------------------------------------------------------------------
  -- Connect internal signals to out
  -------------------------------------------------------------------------------

  sdo <= r.sdo;

  ----------------------------------------------------------------------------
  -- Sequential process of FSM
  ----------------------------------------------------------------------------
-- purpose: sequential process of FSM
-- type   : sequential
-- inputs : sck, conv
-- outputs: sdo
  seq_proc : process (sck)
  begin  -- process seq_proc
    if rising_edge(sck) then            -- rising clock edge
      r <= rin;
    end if;
  end process seq_proc;

  -- purpose: transitions and actions of FSM
  -- type   : sequential
  -- inputs : sck, conv
  -- outputs: 
  comb_proc : process (conv, r)
    variable v : adc_ltc2351_model_type;
  begin  -- process comb_proc
    v := r;

    case v.state is
      when IDLE =>
        if conv = '1' then
          v.state     := SAMPLING;
          v.count_bit := 1;
          v.adc_data  := "Z" & DATA_CH1 & "ZZ" & DATA_CH2 & "ZZ" & DATA_CH3 & "ZZ" & DATA_CH4 & "ZZ" & DATA_CH5 & "ZZ" & DATA_CH6 & "ZZZ";
          v.sdo       := 'Z';           -- first bit
        end if;
      when SAMPLING =>
        v.adc_data := r.adc_data(2 to 98) & 'U';
        if r.count_bit = 98 then
          v.state := IDLE;
          v.sdo   := 'Z';
        else
          v.count_bit := r.count_bit + 1;
          v.sdo       := r.adc_data(1);
        end if;
    end case;

    rin <= v;
  end process comb_proc;

end behavioral;
