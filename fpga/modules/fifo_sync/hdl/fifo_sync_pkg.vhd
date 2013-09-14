-------------------------------------------------------------------------------
-- Title      : Synchronous FIFO
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

-------------------------------------------------------------------------------

package fifo_sync_pkg is

  -----------------------------------------------------------------------------
  -- Component declarations
  -----------------------------------------------------------------------------
  component fifo_sync
    generic (
      data_width    : natural := 8;
      address_width : natural := 4);
    port (
      di    : in  std_logic_vector(data_width -1 downto 0);
      wr    : in  std_logic;
      full  : out std_logic;
      do    : out std_logic_vector(data_width -1 downto 0);
      rd    : in  std_logic;
      empty : out std_logic;
      valid : out std_logic;
      clk   : in  std_logic);
  end component;
  

end fifo_sync_pkg;

-------------------------------------------------------------------------------
