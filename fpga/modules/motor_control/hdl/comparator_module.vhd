-------------------------------------------------------------------------------
-- Title      : Window comparator
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Spartan 3-400
-------------------------------------------------------------------------------
-- Description:
--
-- Compares the input value to a lower and upper limit and generates an
-- overflow flag if the value is out of bounds. Uses an unsigned compare.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.utils_pkg.all;
use work.reg_file_pkg.all;
use work.motor_control_pkg.all;

-------------------------------------------------------------------------------
-- Register Map
--
-- | Offset | Description
-- +--------+---------------------------
-- |     +0 | Upper Limit Channel 0
-- |     +1 | Lower Limit Channel 0
-- |     +2 | Upper Limit Channel 1
-- |     +3 | Lower Limit Channel 1
--     ....
-- 
entity comparator_module is
   generic (
      BASE_ADDRESS : integer range 0 to 32767;  -- Base address of the module
      CHANNELS     : positive := 8      -- Number of Channels
      );
   port (
      value_p    : in  comparator_values_type(CHANNELS-1 downto 0);
      overflow_p : out std_logic_vector(CHANNELS-1 downto 0);
      
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk   : in std_logic
      );
end comparator_module;

-------------------------------------------------------------------------------
architecture behavioral of comparator_module is
   -- Number of bits needed to encode the comparator channels
   constant CHANNEL_BITS : positive := required_bits(CHANNELS * 2);

   -- Number of channels in the register file
   constant CHANNEL_COUNT : positive := 2 ** CHANNEL_BITS;

   type comparator_module_type is record
      result : std_logic_vector(CHANNELS-1 downto 0);
   end record;

   signal r, rin : comparator_module_type;

   signal reg_i : reg_file_type(CHANNEL_COUNT-1 downto 0) := (others => (others => '0'));
   signal reg_o : reg_file_type(CHANNEL_COUNT-1 downto 0);

   signal limit_upper : comparator_values_type(CHANNELS-1 downto 0);
   signal limit_lower : comparator_values_type(CHANNELS-1 downto 0);
begin
   limits: for n in CHANNELS-1 downto 0 generate
      limit_upper(n) <= reg_o(n * 2)(9 downto 0);
      limit_lower(n) <= reg_o(n * 2 + 1)(9 downto 0);
   end generate;
   
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(limit_lower, limit_upper, r, value_p)
      variable v : comparator_module_type;
   begin
      v := r;

      -- default values
      v.result := (others => '0');

      -- check all channels for boundary limits
      for n in CHANNELS-1 downto 0 loop
         if (value_p(n) > limit_upper(n)) or (value_p(n) < limit_lower(n)) then
            v.result(n) := '1';
         end if;
      end loop;
      
      rin <= v;
   end process comb_proc;

   overflow_p <= r.result;

   -----------------------------------------------------------------------------
   -- Register file to present limits
   -----------------------------------------------------------------------------
   reg_file_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => CHANNEL_BITS)
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_o,
         reg_i => reg_i,
         clk   => clk);

end behavioral;
