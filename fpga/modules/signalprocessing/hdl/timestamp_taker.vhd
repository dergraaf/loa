-------------------------------------------------------------------------------
-- Title      : Timestamp Taker module
-- Project    : 
-------------------------------------------------------------------------------
-- File       : timestamp_taker.vhd
-- Author     : strongly-typed
-- Created    : 2012-08-24
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: A double buffered register that takes timestamps from the
--              global timestamp and is readable by the internal bus.
--
--              bank_x_i_p:     Bus Bank
--              bank_y_i_p:     Application Bank (timestamp)
--              
-------------------------------------------------------------------------------
-- Copyright (c) 2012 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.spislave_pkg.all;
use work.reg_file_pkg.all;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity timestamp_taker is
   generic (
      BASE_ADDRESS : integer range 0 to 32767  -- Base address of the timestamp registers
      );
   port (
      -- Timestamp in
      timestamp_i_p : in timestamp_type;

      -- Trigger and control signals
      trigger_i_p : in std_logic;       -- When this trigger is strobed the
                                        -- current timestamp is stored in the
                                        -- register.
      bank_x_i_p  : in std_logic;
      bank_y_i_p  : in std_logic;

      -- Bus interface
      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      -- Clock
      clk : in std_logic
      );

end timestamp_taker;

-------------------------------------------------------------------------------

architecture behavioural of timestamp_taker is

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   -- signal timestamp : timestamp_type := (others => '0');
   signal reg_timestamp_s : reg_file_type(7 downto 0) := (others => (others => '0'));
   signal bus_i_s         : busdevice_in_type;

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------

   -- Bit 2 of the register address is control by the bank switch 'bank_x_i_p'
   bus_i_s.addr <= bus_i.addr(14 downto 3) & bank_x_i_p & bus_i.addr(1 downto 0);
   bus_i_s.data <= bus_i.data;
   bus_i_s.re   <= bus_i.re;
   bus_i_s.we   <= bus_i.we;

   ----------------------------------------------------------------------------
   -- Sequential process
   ----------------------------------------------------------------------------
   -- When the goertzel is finished, the goertzel_done_s signal is strobed.
   -- Copy timestamp to the register at this moment.
   timestamp_taker : process (clk) is
   begin  -- process timestamp_taker
      if rising_edge(clk) then          -- rising clock edge
         if trigger_i_p = '1' then
            if bank_y_i_p = '0' then
               reg_timestamp_s(0) <= std_logic_vector(timestamp_i_p(15 downto 0));
               reg_timestamp_s(1) <= std_logic_vector(timestamp_i_p(31 downto 16));
               reg_timestamp_s(2) <= std_logic_vector(timestamp_i_p(47 downto 32));
            else
               reg_timestamp_s(4) <= std_logic_vector(timestamp_i_p(15 downto 0));
               reg_timestamp_s(5) <= std_logic_vector(timestamp_i_p(31 downto 16));
               reg_timestamp_s(6) <= std_logic_vector(timestamp_i_p(47 downto 32));
            end if;
         end if;
      end if;
   end process timestamp_taker;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------

   -- Register with 8 16 bit values for two timestamps
   reg_file_timestamp_1 : reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => 3)
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => open,                 -- read only register
         reg_i => reg_timestamp_s,
         clk   => clk);

end behavioural;
