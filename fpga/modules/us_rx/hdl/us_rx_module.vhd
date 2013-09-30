-------------------------------------------------------------------------------
-- Title      : US Receiver
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.adc_ltc2351_pkg.all;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity us_rx_module is

   generic (
      BASE_ADDRESS : integer range 0 to 16#7FFF#
      );
   port (
      -- signals to and from the internal parallel bus
      bus_o_p : out busdevice_out_type;
      bus_i_p : in  busdevice_in_type;

      -- Sampling clock enable (expected to be 250 kHz or less)
      -- starts a new ADC conversion.
      clk_sample_en_i_p : in std_logic;

      -- Timestamp input from the timestamp module
      timestamp_i_p : in timestamp_type;

      clk : in std_logic
      );

end us_rx_module;

-------------------------------------------------------------------------------

architecture behavioural of us_rx_module is

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------

   ----------------------------------------------------------------------------
   -- Sequential part of finite state machine (FSM)
   ----------------------------------------------------------------------------
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then

      end if;
   end process seq_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.

end behavioural;
