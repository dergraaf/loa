-------------------------------------------------------------------------------
-- Title      : Double Buffering Control
-- Project    : 
-------------------------------------------------------------------------------
-- File       : double_buffering.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-23
-- Last update: 2012-08-03
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.reg_file_pkg.all;
use work.utils_pkg.all;

entity double_buffering is
   
   port (
      ready_p  : in  std_logic;
      enable_p : out std_logic;
      irq_p    : out std_logic;
      ack_p    : in  std_logic;
      bank_p   : out std_logic;
      clk      : in  std_logic);

end double_buffering;

architecture behavourial of double_buffering is

   signal enable_s : std_logic := '0';
   signal irq_s    : std_logic := '0';
   signal bank_s   : std_logic := '0';

   signal ack_rise_s : std_logic := '0';
   
   
begin  -- behavourial

   -- does synchronisation, can be connected directly to port pin.
   edge_detect_1 : entity work.edge_detect
      port map (
         async_sig => ack_p,
         clk       => clk,
         rise      => ack_rise_s,
         fall      => open);

   enable_p <= enable_s;
   irq_p    <= irq_s;
   bank_p   <= bank_s;

   irq_proc : process (clk) is
   begin  -- process
      if rising_edge(clk) then          -- rising clock edge
         if (ready_p = '1') then
            irq_s <= '1';
         elsif (ack_rise_s = '1') then
            irq_s <= '0';
         else
            -- keep
            irq_s <= irq_s;
         end if;
      end if;
   end process irq_proc;

   -- 
   bank_proc : process (clk) is
   begin  -- process bank_proc
      if rising_edge(clk) then          -- rising clock edge
         if (ready_p = '1') and (irq_s = '0') then
            -- the other bank was read and is empty now (= irq_s low)
            bank_s <= not bank_s;
         end if;
      end if;
   end process bank_proc;

   -- types

   -- signals

end behavourial;
