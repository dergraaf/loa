-------------------------------------------------------------------------------
-- Title      : Register File
-- Project    : 
-------------------------------------------------------------------------------
-- File       : reg_file.vhd
-- Author     : Calle  <calle@Alukiste>
-- Created    : 2012-03-11
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
-- Multiple 16-bit registers at the internal parallel data bus with address
-- decoding. 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------

entity reg_file is

   generic (
      BASE_ADDRESS : integer range 0 to 16#7FFF#;  -- Base address of the registers
      REG_ADDR_BIT : natural := 0       -- number of bits not to compare in
                                        -- address. Gives 2**n registers
      );

   port (
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;
      reg_o : out reg_file_type(2**REG_ADDR_BIT-1 downto 0);
      reg_i : in  reg_file_type(2**REG_ADDR_BIT-1 downto 0);
      clk   : in  std_logic);

end reg_file;

-------------------------------------------------------------------------------

architecture str of reg_file is

   constant BASE_ADDRESS_VECTOR : std_logic_vector(14 downto 0) :=
      std_logic_vector(to_unsigned(BASE_ADDRESS, 15));

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal reg      : reg_file_type(2**REG_ADDR_BIT-1 downto 0) := (others => (others => '0'));
   signal data_out : std_logic_vector(15 downto 0)             := (others => '0');

begin  -- str

   -----------------------------------------------------------------------------
   -- Transfer data from bus to register
   -----------------------------------------------------------------------------

   reg_o <= reg;

   process (clk)
      variable index : integer := 0;
   begin  -- process
      if rising_edge(clk) then
         index := to_integer(unsigned(bus_i.addr(REG_ADDR_BIT-1 downto 0)));
         if bus_i.addr(14 downto REG_ADDR_BIT) = BASE_ADDRESS_VECTOR(14 downto REG_ADDR_BIT) then
            if bus_i.we = '1' then
               reg(index) <= bus_i.data;
            end if;
         end if;
      end if;
   end process;


   -----------------------------------------------------------------------------
   -- Output mux
   -- (output (others => '0') if we are not selected)
   -----------------------------------------------------------------------------

   bus_o.data <= data_out;

   process (clk)
      variable index : integer := 0;
   begin  -- process
      if rising_edge(clk) then
         index := to_integer(unsigned(bus_i.addr(REG_ADDR_BIT-1 downto 0)));
         if (bus_i.addr(14 downto REG_ADDR_BIT) = BASE_ADDRESS_VECTOR(14 downto REG_ADDR_BIT)) and bus_i.re = '1' then
            data_out <= reg_i(index);
         else
            data_out <= (others => '0');
         end if;
      end if;
      -- is there a problem with using a varibale in a assignment of a signal??
      --bus_o.data <= (others => '0') when bus_i.re = '0' else reg_i(index);
   end process;

   
end str;

-------------------------------------------------------------------------------
