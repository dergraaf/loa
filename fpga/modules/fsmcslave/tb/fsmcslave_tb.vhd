-------------------------------------------------------------------------------
-- Title      : Testbench for design "fsmcslave"
-------------------------------------------------------------------------------
-- Author : Carl Treudler (Carl.Treudler@DLR.de)
-------------------------------------------------------------------------------
-- Description: Testbench for fsmcslave ipcore.
-------------------------------------------------------------------------------
-- Created    : 2014-07-21
-- Last update: 2014-07-23
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
use ieee.numeric_std.all;

use work.fsmcslave_pkg.all;
use work.bus_pkg.all;
use work.reg_file_pkg.all;

-------------------------------------------------------------------------------

entity fsmcslave_tb is

end fsmcslave_tb;


architecture behavioral of fsmcslave_tb is

  -- component ports
  signal fsmcslave_o : fsmc_in_type;
  signal fsmcslave_i : fsmc_out_type :=
    (data  => (others => '0'),
     adv_n => '1',
     wr_n  => '1',
     oe_n  => '1',
     cs_n  => '1');

  -----------------------------------------------------------------------------
  -- Loa Bus
  -----------------------------------------------------------------------------
  signal bus_o : busmaster_out_type;
  signal bus_i : busmaster_in_type;

  ----------------------------------------------------------------------------
  -- register file Signals to have some peripheral to access
  -----------------------------------------------------------------------------
  signal reg_o : std_logic_vector(15 downto 0);
  signal reg_i : std_logic_vector(15 downto 0) := (others => '0');

  -- clock
  signal Clk : std_logic := '1';

begin  -- tb

  -----------------------------------------------------------------------------
  --
  --  FSMC Slave and some Loa Bus Slave (with loopback)
  --
  -----------------------------------------------------------------------------

  -- component instantiation
  DUT : fsmcslave
    port map (
      fsmcslave_o => fsmcslave_o,
      fsmcslave_i => fsmcslave_i,
      bus_o       => bus_o,
      bus_i       => bus_i,
      clk         => clk);

  reg_1 : peripheral_register
    generic map (
      BASE_ADDRESS => 16#000A#)
    port map (
      bus_o  => bus_i,
      bus_i  => bus_o,
      dout_p => reg_o,
      din_p  => reg_i,
      clk    => clk);


  reg_i <= reg_o xor std_logic_vector(to_unsigned(16#5555#, 16));

  -- clock generation
  Clk <= not Clk after 10 ns;

  -----------------------------------------------------------------------------
  --
  -- waveform generation
  --
  -----------------------------------------------------------------------------

  WaveGen_Proc : process
  begin

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Write Test
    -- (See  DM00031020.pdf)
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Bus Idle
    fsmcslave_i.adv_n <= '1';
    fsmcslave_i.wr_n  <= '1';
    fsmcslave_i.cs_n  <= '1';
    fsmcslave_i.oe_n  <= '1';
    fsmcslave_i.data  <= "0000" & "0000" & "0000" & "0000";

    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';

    -- Begin Multiplexed Write 
    fsmcslave_i.adv_n <= '0';
    fsmcslave_i.cs_n  <= '0';
    fsmcslave_i.data  <= "0000" & "0000" & "0000" & "1010";  -- Addr

    wait until Clk = '1';
    wait until Clk = '1';

    -- Address Phase is over
    fsmcslave_i.adv_n <= '1';
    fsmcslave_i.wr_n  <= '0';

    -- today no ADDHLD FSMC Waitstates
    --wait until Clk = '1';

    -- set Data to be written
    fsmcslave_i.data <= "1000" & "0000" & "1111" & "1111";  -- Data

    -- DATAST -2
    wait until Clk = '1';
    wait until Clk = '1';


    -- remove WE 1 cycle before Data gets invalid.
    fsmcslave_i.wr_n <= '1';


    wait until Clk = '1';

    -- We are done.
    fsmcslave_i.adv_n <= '1';
    fsmcslave_i.wr_n  <= '1';
    fsmcslave_i.cs_n  <= '1';
    fsmcslave_i.data  <= "0000" & "0000" & "0000" & "0000";


    wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1';
    wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1';

    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------
    -- Read Test
    ---------------------------------------------------------------------------
    ---------------------------------------------------------------------------

    -- Bus Idle
    fsmcslave_i.adv_n <= '1';
    fsmcslave_i.wr_n  <= '1';
    fsmcslave_i.cs_n  <= '1';
    fsmcslave_i.data  <= "0000" & "0000" & "0000" & "0000";

    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';

    -- Begin Multiplexed Write 
    fsmcslave_i.adv_n <= '0';
    fsmcslave_i.cs_n  <= '0';
    fsmcslave_i.data  <= "0000" & "0000" & "0000" & "1010";  -- Addr

    wait until Clk = '1';
    wait until Clk = '1';

    -- Address Phase is over
    fsmcslave_i.adv_n <= '1';
    fsmcslave_i.wr_n  <= '1';


    wait until Clk = '1';
    fsmcslave_i.oe_n <= '0';
    -- hand bus to "Memory" (tri-state drivers)

    -- DATAST -2
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';
    wait until Clk = '1';


    -- FSMC will sample Data no riasing edge os CS

    wait until Clk = '1';

    -- We are done.
    fsmcslave_i.adv_n <= '1';
    fsmcslave_i.wr_n  <= '1';
    fsmcslave_i.cs_n  <= '1';
    fsmcslave_i.oe_n  <= '1';
    fsmcslave_i.data  <= "0000" & "0000" & "0000" & "0000";

    -- add some horizontal space in gtkwave
    wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1';
    wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1';
    wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1';
    wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1'; wait until Clk = '1';

    -- and repeat
  end process WaveGen_Proc;
  

  

end behavioral;

-------------------------------------------------------------------------------

configuration fsmcslave_tb_cfg of fsmcslave_tb is
  for behavioral
  end for;
end fsmcslave_tb_cfg;

-------------------------------------------------------------------------------
