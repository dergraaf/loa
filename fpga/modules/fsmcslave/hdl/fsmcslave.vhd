-------------------------------------------------------------------------------
-- Title      : FSMC Slave, synchronous
-------------------------------------------------------------------------------
-- Author : Carl Treudler (Carl.Treudler@DLR.de)
-------------------------------------------------------------------------------
-- Description: This is slave to the flexible static memory controller (FSMC)
--              of a STM32 device. The slave is a busmaster to the local bus.
--              Data can be transfered to and from the bus slaves on the bus.
--              
-------------------------------------------------------------------------------
-- Copyright (c) 2014, German Aerospace Center (DLR)
-- All Rights Reserved.
-- 
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fsmcslave_pkg.all;
use work.bus_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity fsmcslave is
  port (
    -- slave side of the STM32's FSMC port
    fsmcslave_o : out fsmc_in_type;
    fsmcslave_i : in  fsmc_out_type;

    -- master port of loa bus
    bus_o : out busmaster_out_type;
    bus_i : in  busmaster_in_type;

    clk : in std_logic
    );
end fsmcslave;

-------------------------------------------------------------------------------
architecture behavioral of fsmcslave is

  type fsmc_out_type_array is array(1 downto 0) of fsmc_out_type;
  
  type entity_name_state_type is (
    IDLE,                               -- Idle state: 
    READ1,
    READ2
    );

  type entity_name_type is record
    nadv_old        : std_logic;
    addr            : std_logic_vector(14 downto 0);
    data            : std_logic_vector(15 downto 0);
    state           : entity_name_state_type;
    bus_o           : busmaster_out_type;
    reg_fsmcslave_i : fsmc_out_type_array;
  end record;


  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  signal r, rin : entity_name_type :=
    (nadv_old        => '0',
     data            => (others => '0'),
     addr            => (others => '0'),
     state           => IDLE,
     bus_o           => (
       addr          => (others => '0'),
       data          => (others => '0'),
       re            => '0',
       we            => '0'),
     reg_fsmcslave_i => (               -- init synchronizer with idle state of
                                        -- fsmc, to aviod triggering the edge
                                        -- detection 
       1             => (
         data        => (others => '0'),
         adv_n       => '1',
         wr_n        => '1',
         oe_n        => '1',
         cs_n        => '1'),
       0             => (
         data        => (others => '0'),
         adv_n       => '1',
         wr_n        => '1',
         oe_n        => '1',
         cs_n        => '1'))
     );


begin  -- architecture behavourial

  ----------------------------------------------------------------------------
  -- Connections between ports and registered signals
  ----------------------------------------------------------------------------
  fsmcslave_o.data <= r.data;
  bus_o            <= r.bus_o;

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
  comb_proc : process(bus_i, fsmcslave_i, r)
    variable v : entity_name_type;
    
  begin
    v := r;

    -- default values
    v.bus_o.addr := (others => '0');
    v.bus_o.data := (others => '0');
    v.bus_o.we   := '0';
    v.bus_o.re   := '0';

    -- (0) is first stage of synchronizer, (1) is second
    v.reg_fsmcslave_i(1 downto 0) := r.reg_fsmcslave_i(0) & fsmcslave_i;

    case r.state is
      when IDLE =>
        -- if nadv is low, store addr
        if(r.reg_fsmcslave_i(0).adv_n = '0') then
          v.addr := r.reg_fsmcslave_i(0).data(14 downto 0);
        end if;

        -- Falling edge of WRn starts write access on loa bus
        if(r.reg_fsmcslave_i(1).wr_n = '0' and r.reg_fsmcslave_i(0).wr_n = '1') then
          v.bus_o.addr := r.addr;
          v.bus_o.data := r.reg_fsmcslave_i(1).data;
          v.bus_o.we   := '1';
        end if;

        -- Raising edge of OEn starts read access
        -- Note: Tristate driver should be in the toplevel
        if(r.reg_fsmcslave_i(1).oe_n = '1' and r.reg_fsmcslave_i(0).oe_n = '0') then
          v.bus_o.addr := r.addr;
          v.bus_o.re   := '1';
          v.state      := READ1;
        end if;
        

      when READ1 =>
        -----------------------------------------------------------------------
        -- wait for bus to react
        -----------------------------------------------------------------------
        v.state := READ2;
        
      when READ2 =>
        v.data  := bus_i.data;
        v.state := IDLE;
        
    end case;

    rin <= v;
  end process comb_proc;
  
end behavioral;

