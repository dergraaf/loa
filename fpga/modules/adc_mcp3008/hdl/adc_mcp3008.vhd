-------------------------------------------------------------------------------
-- Title      : Interface for Microchip MCP3008 ADC
-- Project    : Loa
-------------------------------------------------------------------------------
-- Description: Interface to Microchip's 8 channel 10-bit ADC (MCP3008).
--              Converversion started by logical 1 on start_p. '1' on done_p
--              signals completetd conversion. 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.adc_mcp3008_pkg.all;

-------------------------------------------------------------------------------

entity adc_mcp3008 is

   generic (
      DELAY : natural := 39             -- waitstates between toggling the
                                        -- SCK line (MCP3008 max: about 1.3
                                        -- MHz) 
      );
   port (
      adc_out : out adc_mcp3008_spi_out_type;
      adc_in  : in  adc_mcp3008_spi_in_type;

      start_p    : in  std_logic;       -- starts the acquisition cycle
      adc_mode_p : in  std_logic;  -- single-ended or differential mode of ADC
      channel_p  : in  std_logic_vector(2 downto 0);  -- select channel of ADC
      value_p    : out std_logic_vector(9 downto 0);  -- last value from  ADC
      done_p     : out std_logic;       -- conversion reads

      reset : in std_logic;
      clk   : in std_logic
      );

end adc_mcp3008;

-------------------------------------------------------------------------------

architecture behavioral of adc_mcp3008 is

   -----------------------------------------------------------------------------
   -- FSM Type declaration
   -----------------------------------------------------------------------------
   
   type adc_mcp3008_state_type is (IDLE, SCK_LOW, SCK_HIGH, HOLD_OFF);

   type adc_mcp3008_type is record
      state           : adc_mcp3008_state_type;
      csn             : std_logic;
      sck             : std_logic;
      din             : std_logic_vector(9 downto 0);
      done            : std_logic;
      countdown_delay : integer range 0 to (DELAY * 16);
      countdown_bit   : integer range 0 to 16;
      dout            : std_logic_vector(4 downto 0);
   end record;


   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : adc_mcp3008_type;

begin

   -----------------------------------------------------------------------------
   -- patch signals to outside of module 
   -----------------------------------------------------------------------------

   -- outputs to adc
   adc_out.cs_n <= r.csn;
   adc_out.sck  <= r.sck;
   adc_out.mosi <= r.dout(4);

   -- outputs
   done_p  <= r.done;                   -- signals valid data on value_p
   value_p <= r.din;                    -- value of the last conversion fetched
                                        -- from the ADC


   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Sequential proc of FSM
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
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

   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   -- Transitons and actions of FSM
   -----------------------------------------------------------------------------
   -----------------------------------------------------------------------------
   comb_proc : process(adc_in.miso, adc_mode_p, channel_p, r, r.countdown_bit,
                       r.countdown_delay, r.din(8 downto 0),
                       r.dout(3 downto 0), r.state, start_p)
      variable v : adc_mcp3008_type;
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
               v.state           := SCK_LOW;
               v.sck             := '0';
               v.countdown_delay := DELAY;
               v.countdown_bit   := 16;
               v.dout            := '1' & adc_mode_p & channel_p;
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
               v.din             := r.din(8 downto 0) & adc_in.miso;
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
               v.dout            := r.dout(3 downto 0) & '0';
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
