-------------------------------------------------------------------------------
-- Title      : Modulator
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

-------------------------------------------------------------------------------

entity serialiser is

   generic (
      BITPATTERN_WIDTH : positive := 32
      );
   port (
      pattern_in_p    : in  std_logic_vector(BITPATTERN_WIDTH - 1 downto 0);
      bitstream_out_p : out std_logic;
      clk_bit         : in  std_logic;

      clk : in std_logic
      );

end serialiser;

-------------------------------------------------------------------------------

architecture behavioural of serialiser is

   type serialiser_type is record
      counter : integer range 0 to BITPATTERN_WIDTH;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : serialiser_type := (counter => 0);

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------
   bitstream_out_p <= pattern_in_p(r.counter);

   ----------------------------------------------------------------------------
   -- Sequential part of finite state machine (FSM)
   ----------------------------------------------------------------------------
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   ----------------------------------------------------------------------------
   -- Combinatorial part of FSM
   ----------------------------------------------------------------------------
   comb_proc : process(clk_bit, r)
      variable v : serialiser_type;

   begin
      v := r;

      if clk_bit = '1' then
         v.counter := v.counter + 1;
         if v.counter = BITPATTERN_WIDTH then
            v.counter := 0;
         end if;
      end if;

      rin <= v;
   end process comb_proc;

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   -- None.

end behavioural;
