-------------------------------------------------------------------------------
-- Title      : Bus Module for ADC AD7266
-- Project    : Loa
-------------------------------------------------------------------------------
-- Copyright (c) 2013
-------------------------------------------------------------------------------
-- TODO mask does not work here


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.utils_pkg.all;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.adc_ad7266_pkg.all;

-------------------------------------------------------------------------------

entity adc_ad7266_single_ended_module is
   generic (
      BASE_ADDRESS : integer range 0 to 32767;
      CHANNELS     : positive := 12);  -- AD7266 has 12 single ended channels
   port (
      adc_out_p : out adc_ad7266_spi_out_type;
      adc_in_p  : in  adc_ad7266_spi_in_type;

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      -- direct access to the read adc samples
      adc_values_o : out adc_ad7266_values_type(CHANNELS - 1 downto 0);

      clk : in std_logic
      );

end adc_ad7266_single_ended_module;

-------------------------------------------------------------------------------

architecture behavioral of adc_ad7266_single_ended_module is

   constant REG_ADDR_BIT : positive := required_bits(CHANNELS);

   type adc_ad7266_module_state_type is (IDLE, WAIT_FOR_ADC);

   type adc_ad7266_module_type is record
      state      : adc_ad7266_module_state_type;
      start      : std_logic;
      current_ch : integer range 0 to (CHANNELS / 2) - 1;
      reg        : reg_file_type(2**REG_ADDR_BIT-1 downto 0);
   end record;


   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : adc_ad7266_module_type := (state      => IDLE,
                                              current_ch => (CHANNELS / 2) - 1,
                                              start      => '0',
                                              reg        => (others => (others => '0')));

   signal adc_mode_s : std_logic;
   signal channel_s  : std_logic_vector(2 downto 0);
   signal value_a_s  : std_logic_vector(11 downto 0);  --AD7266 converts two
                                                         --channels a,b at one
                                                         --address (12 channels
                                                         --vs 6 addresses)
   signal value_b_s : std_logic_vector(11 downto 0);
   signal done_s    : std_logic;

   signal reg_o : reg_file_type(2**REG_ADDR_BIT-1 downto 0);
   signal reg_i : reg_file_type(2**REG_ADDR_BIT-1 downto 0);

   signal mask_s : std_logic_vector(((CHANNELS / 2) - 1) downto 0);
begin

   -- mapping signals to adc i/f
   adc_mode_s <= '1';                   -- we don't use differential mode
   channel_s  <= std_logic_vector(to_unsigned(r.current_ch, 3));
   reg_i      <= r.reg;

   -- present last value of each channel on this modules ports
   copy_loop : for ii in 0 to 11 generate  -- (2**REG_ADDR_BIT-1)
      adc_values_o(ii) <= r.reg(ii)(11 downto 0);  --12bit ADC (AD7266)
   end generate copy_loop;

   -- register for channel mask
   -- you will always mask out two channels at once
   mask_s <= reg_o(0)((CHANNELS / 2) - 1 downto 0);


   -------------------------------------------------------------------------------
   ---- seq part of FSM
   -------------------------------------------------------------------------------
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;


   -----------------------------------------------------------------------------
   -- transitions and actions of FSM
   -----------------------------------------------------------------------------
   comb_proc : process(done_s, mask_s, r, value_a_s, value_b_s)
      variable v : adc_ad7266_module_type;

   begin
      v := r;

      case v.state is
         when IDLE =>
            -- in this state we iterate over the channels

            if v.current_ch = ((CHANNELS / 2)-1)  then
               -- we wrap around (to 0)
               v.current_ch := 0;
            else
               -- or increment the currently selected channel
               v.current_ch := v.current_ch + 1;
            end if;

            -- if the channel isn't masked out, we take a sample
            -- if mask_s(v.current_ch) = '0' then
               v.start := '1';
               v.state := WAIT_FOR_ADC;
            -- end if;

         when WAIT_FOR_ADC =>
            -- adc i/f has already started conversion, we stay in this state until
            -- the conversion is over.
            v.start := '0';
            if done_s = '1' then
               -- if the conversion is done we put its result in the right register,
               -- for each value a,b
               -- and return to the "idle" state.
               v.reg(v.current_ch) := ("0000") & value_a_s;
               v.reg(v.current_ch + (CHANNELS / 2)) := ("0000") & value_b_s;
               
               v.state             := IDLE;
            end if;

      end case;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------

   -- Register file to present ADC values to bus
   -- and configuration
   reg_file_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => REG_ADDR_BIT)
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_o,
         reg_i => reg_i,
         clk   => clk);

-- ADC interface module 
adc_ad7266_1 : adc_ad7266_single_ended
   port map (
      adc_out    => adc_out_p,
      adc_in     => adc_in_p,
      start_p    => r.start,
      adc_mode_p => adc_mode_s,
      channel_p  => channel_s,
      value_a_p  => value_a_s,
      value_b_p  => value_b_s,
      done_p     => done_s,
      clk        => clk);
end behavioral;


