-------------------------------------------------------------------------------
-- Title      : Bus Module for ADC MCP3008
-- Project    : Loa
-------------------------------------------------------------------------------
-- Copyright (c) 2012
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

      -- direct access to the read adc samples
      adc_values_o : out adc_mcp3008_values_type(7 downto 0);

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

   signal adc_mode_s : std_logic;
   signal channel_s  : std_logic_vector(2 downto 0);
   signal value_s    : std_logic_vector(9 downto 0);
   signal done_s     : std_logic;

   signal reg_o : reg_file_type(7 downto 0);
   signal reg_i : reg_file_type(7 downto 0);

   signal mask_s : std_logic_vector(7 downto 0);
begin

   -- mapping signals to adc i/f
   adc_mode_s <= '1';                   -- we don't use differential mode
   channel_s  <= std_logic_vector(to_unsigned(r.current_ch, 3));
   reg_i      <= r.reg;

   -- present last value of each channel on this modules ports
   copy_loop : for ii in 0 to 7 generate
      adc_values_o(ii) <= r.reg(ii)(9 downto 0);
   end generate copy_loop;

   -- register for channel mask
   mask_s <= reg_o(0)(7 downto 0);


   -----------------------------------------------------------------------------
   -- seq part of FSM
   -----------------------------------------------------------------------------
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


   -----------------------------------------------------------------------------
   -- transitions and actiosn of FSM
   -----------------------------------------------------------------------------
   comb_proc : process(done_s, mask_s, r, value_s)
      variable v : adc_mcp3008_module_type;
      
   begin
      v := r;

      case v.state is
         when IDLE =>
            -- in this state we iterate over the channels
            
            if v.current_ch = 7 then
               -- we wrap around (to 0)
               v.current_ch := 0;
            else
               -- or increment the currently selected channel
               v.current_ch := v.current_ch + 1;
            end if;

            -- if the channel isn't masked out, we take a sample
            if mask_s(v.current_ch) = '0' then
               v.start := '1';
               v.state := WAIT_FOR_ADC;
            end if;

         when WAIT_FOR_ADC =>
            -- adc i/f has already started conversion, we stay in this state until
            -- the conversion is over.
            v.start := '0';
            if done_s = '1' then
               -- if the conversion is done we put its result in the right register,
               -- and return to the "idle" state.
               v.reg(v.current_ch) := "000000" & value_s;
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
         REG_ADDR_BIT => 3)
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_o,
         reg_i => reg_i,
         clk   => clk);

   -- ADC interface module 
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
end behavioral;


