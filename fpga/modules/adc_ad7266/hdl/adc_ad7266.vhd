-------------------------------------------------------------------------------
-- Title      : Interface for Microchip AD7266 (ADC)
-- Project    : Loa
-------------------------------------------------------------------------------
-- Description: Interface to Microchip's 12 channel 12-bit ADC (AD7266).
--
--              Converversion started by logical 1 on start_p. '1' on done_p
--              signals completetd conversion. 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.adc_ad7266_pkg.all;

-------------------------------------------------------------------------------

entity adc_ad7266_single_ended is

   generic (
      DELAY : natural := 1             -- waitstates between toggling the
                                        -- SCK line (AD7266 max: about 32
                                        -- MHz) 
      );
   port (
      adc_out : out adc_ad7266_spi_out_type;
      adc_in  : in  adc_ad7266_spi_in_type;

      start_p    : in  std_logic;       -- starts the acquisition cycle
      adc_mode_p : in  std_logic;  -- single-ended or differential mode of ADC
      channel_p  : in  std_logic_vector(2 downto 0);   -- select channel of ADC
      value_a_p  : out std_logic_vector(11 downto 0);  -- last value from  ADC
      value_b_p  : out std_logic_vector(11 downto 0);
      done_p     : out std_logic;                      -- conversion reads

      clk : in std_logic
      );

end adc_ad7266_single_ended;

-------------------------------------------------------------------------------

architecture behavioral of adc_ad7266_single_ended is

   -----------------------------------------------------------------------------
   -- FSM Type declaration
   -----------------------------------------------------------------------------

   type adc_ad7266_state_type is (IDLE, SCK_LOW, SCK_HIGH, HOLD_OFF);

   type adc_ad7266_type is record
      state           : adc_ad7266_state_type;
      csn             : std_logic;
      sck             : std_logic;
      din_a           : std_logic_vector(11 downto 0);
      din_b           : std_logic_vector(11 downto 0);
      done            : std_logic;
      countdown_delay : integer range 0 to (DELAY * 16);
      countdown_bit   : integer range 0 to 16;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : adc_ad7266_type := (state           => IDLE,
                                       csn             => '1',
                                       sck             => '1',
                                       din_a           => (others => '0'),
                                       din_b           => (others => '0'),
                                       done            => '0',
                                       countdown_bit   => 0,
                                       countdown_delay => DELAY);

begin

   -----------------------------------------------------------------------------
   -- patch signals to outside of module 
   -----------------------------------------------------------------------------

   -- outputs to adc
   adc_out.cs_n <= r.csn;
   adc_out.sck  <= r.sck;
   adc_out.a    <= channel_p;

   -- outputs
   done_p    <= r.done;                 -- signals valid data on value_p
   value_a_p <= r.din_a;                -- value of the last conversion fetched
   value_b_p <= r.din_b;                 -- from the ADC


   -----------------------------------------------------------------------------
   -- Sequential proc of FSM
   -----------------------------------------------------------------------------
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   -----------------------------------------------------------------------------
   -- Transitons and actions of FSM
   -----------------------------------------------------------------------------
   comb_proc : process(adc_in, r, start_p)
      variable v : adc_ad7266_type;
   begin
      v := r;

      case r.state is
         -------------------------------------------------------------------------
         -- Idle State
         -------------------------------------------------------------------------
         when IDLE =>
            v.csn  := '1';
            v.done := '0';
            if start_p = '1' then
               v.csn             := '0';
               v.state           := SCK_HIGH;
               v.sck             := '1';
               v.countdown_delay := DELAY;
               v.countdown_bit   := 13;
            end if;

         -------------------------------------------------------------------------
         -- Low period of SCK cycle
         -------------------------------------------------------------------------
         when SCK_LOW =>
            v.csn := '0';
            if r.countdown_delay = 0 then
               v.state           := SCK_HIGH;
               v.sck             := '1';
               v.countdown_delay := DELAY;
               -- shift in data from ADC
               -- miso is an external signal but is assumed to be in sync with SCK
               -- so no synchronization needed here.
               v.din_a           := r.din_a(10 downto 0) & adc_in.d_a;
               v.din_b           := r.din_b(10 downto 0) & adc_in.d_b;
            else
               v.countdown_delay := v.countdown_delay -1;
            end if;


         -------------------------------------------------------------------------
         -- High period of SCK cycle
         -------------------------------------------------------------------------
         when SCK_HIGH =>
            if r.countdown_delay = 0 then
               v.state           := SCK_LOW;
               v.sck             := '0';
               v.countdown_delay := DELAY;
               if r.countdown_bit = 0 then
                  v.state           := HOLD_OFF;
                  v.sck             := '0';
                  v.countdown_delay := DELAY * 4;
               else
                  v.countdown_bit := v.countdown_bit - 1;
               end if;
            else
               v.countdown_delay := v.countdown_delay -1;
            end if;


         -----------------------------------------------------------------------
         -- Hold Off State
         -----------------------------------------------------------------------
         when HOLD_OFF =>
            -- this state is required as the ADC can't handle a 20ns pulse on chipselect
            v.csn := '1';
            if r.countdown_delay = 0 then
               v.state := IDLE;
               v.done  := '1';
            else
               v.countdown_delay := v.countdown_delay -1;
            end if;
      end case;

      rin <= v;
   end process comb_proc;

end behavioral;
