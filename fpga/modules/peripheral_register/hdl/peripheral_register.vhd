-------------------------------------------------------------------------------
-- Title      : Peripheral Register
-------------------------------------------------------------------------------
-- Author     : Calle  <calle@Alukiste>
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: A single 16-bit register that can be read and written to and
--              from the internal parallel bus. 
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;

entity peripheral_register is
   generic (
      BASE_ADDRESS : integer range 0 to 32767
      );
   port (
      dout_p : out std_logic_vector(15 downto 0);
      din_p  : in  std_logic_vector(15 downto 0);

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk : in std_logic
      );

end peripheral_register;

-------------------------------------------------------------------------------
architecture behavioral of peripheral_register is
   type peripheral_register_type is record
      dout : std_logic_vector(15 downto 0);
      oreg : std_logic_vector(15 downto 0);
   end record;

   signal r, rin : peripheral_register_type := (dout => (others => '0'),
                                                oreg => (others => '0'));
begin
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(bus_i.addr, bus_i.data, bus_i.re, bus_i.we, din_p, r)
      variable v : peripheral_register_type;
   begin
      v := r;

      -- Default value
      v.dout := (others => '0');

      -- Check Bus Address
      if bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS, 15)) then
         if bus_i.we = '1' then
            v.oreg := bus_i.data;
         elsif bus_i.re = '1' then
            v.dout := din_p;
         end if;
      end if;

      rin <= v;
   end process comb_proc;

   bus_o.data <= r.dout;
   dout_p     <= r.oreg;
   
end behavioral;
