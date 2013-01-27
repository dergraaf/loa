-------------------------------------------------------------------------------
-- Title      : Event Hold Stage
-- Project    : Loa
-------------------------------------------------------------------------------
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Platform   : Xilinx Spartan 3
-------------------------------------------------------------------------------
-- Description:
-- 
-- Extends and stores an event.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity event_hold_stage is
   port(
      dout_p : out std_logic;           -- Data output
      din_p  : in  std_logic;           -- Data input

      period_p : in std_logic;            -- Next period
      clk    : in std_logic             -- Clock input
      );
end event_hold_stage;

-------------------------------------------------------------------------------
architecture behavioral of event_hold_stage is
   type event_hold_stage_type is record
      found  : std_logic;
      output : std_logic;
   end record;

   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal r, rin : event_hold_stage_type := (found  => '0',
                                             output => '0');
begin
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(r, din_p, period_p)
      variable v : event_hold_stage_type;
   begin
      v := r;

      if din_p = '1' then
         v.found := '1';
      end if;

      if period_p = '1' then
         v.output := v.found;
         v.found  := din_p;
      end if;

      rin <= v;
   end process comb_proc;

   dout_p <= r.output;
   
end behavioral;

