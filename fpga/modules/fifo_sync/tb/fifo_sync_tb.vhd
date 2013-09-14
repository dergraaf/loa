-------------------------------------------------------------------------------
-- Title      : Synchronous FIFO Testbench
-------------------------------------------------------------------------------
-- Author     : Carl Treudler (cjt@users.sourceforge.net)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: A very plain FIFO, synchronous interfaces. 
-------------------------------------------------------------------------------
-- Copyright (c) 2013, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.fifo_sync_pkg.all;
-------------------------------------------------------------------------------

entity fifo_sync_tb is

end entity fifo_sync_tb;

-------------------------------------------------------------------------------

architecture tb of fifo_sync_tb is

  use work.fifo_sync_pkg.all;

  -- component ports
  constant data_width    : natural := 8;
  constant address_width : natural := 4;

  signal di    : std_logic_vector(data_width -1 downto 0);
  signal wr    : std_logic := '0';
  signal full  : std_logic;
  signal do    : std_logic_vector(data_width -1 downto 0);
  signal rd    : std_logic := '0';
  signal empty : std_logic;

  signal r : std_logic := '0';
  signal w : std_logic := '0';

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture behavourial

  -- component instantiation
  DUT : fifo_sync
    generic map (
      data_width    => data_width,
      address_width => address_width)
    port map (
      di    => di,
      wr    => wr,
      full  => full,
      do    => do,
      rd    => rd,
      empty => empty,
      valid => open,
      clk   => clk);

  -- clock generation
  clk <= not clk after 10 ns;

  -- waveform generation
  process
    variable n : integer := 0;
  begin
    wait until Clk = '1';
    if w = '1' and full = '0'  then
      wr <= '1';
      di <= std_logic_vector(to_unsigned(n, 8));
      n  := n+1;
    else
      wr <= '0';
    end if;
  end process;

  process
    variable n : integer := 0;
  begin
    wait until Clk = '1';
    if empty = '0' and r = '1' then
      rd <= '1';
    else
      rd <= '0';
    end if;
  end process;


  process
  begin
    w <= '1';
    wait for 300 ns;
    w <= '0';
    wait for 100 ns;

    r <= '1';
    wait for 50 ns;
    r <= '0';
    wait for 100 ns;
    
  end process;

end architecture tb;


configuration fifo_sync_tb_cfg of fifo_sync_tb is
  for tb
  end for;
end fifo_sync_tb_cfg;

