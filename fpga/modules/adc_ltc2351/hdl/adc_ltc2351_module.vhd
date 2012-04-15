-------------------------------------------------------------------------------
-- ADC LTC2351 module
--
-- Operates the LTC2351 in free running mode and connects it to
-- the internal parallel bus of the beacon board. 
-- Provides a 'done' signal to the bus which can be used as an interrupt 
-- source
--
-- Connects the adc_ltc2351 entity to the internal bus system.
-- 
-- @author    strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.adc_ltc2351_pkg.all;

-------------------------------------------------------------------------------
entity adc_ltc2351_module is
   generic (
      BASE_ADDRESS : integer range 0 to 32767
      );
   port (
      -- signals to and from real hardware
      adc_out_p : out adc_ltc2351_spi_out_type;
      adc_in_p  : in  adc_ltc2351_spi_in_type;

      -- signals to and from the internal parallel bus
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      -- interrupt for signalling that new samples are available
      done_p : out std_logic;

      -- direct access to the read adc samples
      adc_values_o : out adc_ltc2351_values_type(5 downto 0);

      reset : in std_logic;
      clk   : in std_logic
      );
end adc_ltc2351_module;

-------------------------------------------------------------------------------

architecture behavioral of adc_ltc2351_module is

   -- The ADC operates in free running mode
   type adc_ltc2351_module_state_type is (
      IDLE,                             -- a new result is available
      CONVERTING                        -- a conversion is in progress
      );

   type adc_ltc2351_module_type is record
      state : adc_ltc2351_module_state_type;
      start : std_logic;
   end record;


   -----------------------------------------------------------------------------
   -- Internal signal declarations  
   -----------------------------------------------------------------------------
   signal r, rin : adc_ltc2351_module_type;

   signal value_s : adc_ltc2351_values_type(0 to 5);  -- TODO use generic for channel number
   signal done_s : std_logic := '0';

   signal reg_o : reg_file_type(7 downto 0);
   signal reg_i : reg_file_type(7 downto 0);












   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------

begin
   ----------------------------------------------------------------------------
   -- mapping of signals to ADC interface
   ----------------------------------------------------------------------------

   done_p <= done_s;
   copy_reg : for ii in 0 to 5 generate
      reg_i(ii) <= "00" & value_s(ii);
   end generate copy_reg;  -- ii

   -----------------------------------------------------------------------------
   -- Register file to present ADC values to bus
   -----------------------------------------------------------------------------
   reg_file_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => 3              -- 2**3 = 8 registers for 6 ADC values
         )
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_o,
         reg_i => reg_i,
         reset => reset,
         clk   => clk
         );

   -----------------------------------------------------------------------------
   -- ADC interface module 
   -----------------------------------------------------------------------------
   adc_ltc2351_1 : adc_ltc2351
      port map (
         -- connection between component's signals (left) and 
         -- modules's signals (right)
         adc_out  => adc_out_p,
         adc_in   => adc_in_p,
         values_p => value_s,
         start_p  => r.start,
         done_p   => done_s,
         reset    => reset,
         clk      => clk
         );

   -----------------------------------------------------------------------------
   -- seq part of FSM
   -----------------------------------------------------------------------------
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         if reset = '1' then
            r.state <= IDLE;
            r.start <= '0';
         else
            r <= rin;
         end if;
      end if;
   end process seq_proc;

   -----------------------------------------------------------------------------
   -- transitions and actions of FSM
   -----------------------------------------------------------------------------
   comb_proc : process(done_s, r, value_s)
      variable v : adc_ltc2351_module_type;

   begin
      v := r;

      case v.state is
         when IDLE =>
            -- free running mode: always start a new conversion if done;
            -- if (done_s = '1') then
            v.start := '1';
            v.state := CONVERTING;
            -- end if;
            
         when CONVERTING =>
            -- conversion is in progress
            v.start := '0';
            if done_s = '1' then
               v.state := IDLE;
            end if;
      end case;

      rin <= v;
   end process comb_proc;

   
end behavioral;  -- adc_ltc2351_module

