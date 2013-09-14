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
use ieee.numeric_std.all;

library work;
use work.fifo_sync_pkg.all;

-------------------------------------------------------------------------------

entity fifo_sync is

  generic (
    DATA_WIDTH    : positive;
    ADDRESS_WIDTH : positive
    );
  port (
    -- write side
    di   : in  std_logic_vector(data_width -1 downto 0);
    wr   : in  std_logic;
    full : out std_logic;

    -- read side
    do    : out std_logic_vector(data_width -1 downto 0);
    rd    : in  std_logic;
    empty : out std_logic;
    valid : out std_logic;              -- strobed once per word read

    clk : in std_logic
    );

end fifo_sync;

-------------------------------------------------------------------------------

architecture behavioural of fifo_sync is
  -----------------------------------------------------------------------------
  -- Internal signal declarations
  -----------------------------------------------------------------------------
  constant ADD_TOP : positive := (2**address_width)-1;
  type     mem_type is array(0 to ADD_TOP) of std_logic_vector(DATA_WIDTH-1 downto 0);

  signal mem     : mem_type;
  signal head    : unsigned (address_width-1 downto 0)       := (others => '0');
  signal tail    : unsigned (address_width-1 downto 0)       := (others => '0');
  signal full_s  : std_logic                                 := '0';
  signal empty_s : std_logic                                 := '1';
  signal valid_s : std_logic                                 := '0';
  signal do_s    : std_logic_vector(DATA_WIDTH - 1 downto 0) := (others => '0');
  
begin  -- architecture behavourial

  ----------------------------------------------------------------------------
  -- Connections between ports and signals
  ----------------------------------------------------------------------------

  -- assign to ports
  full  <= full_s;
  empty <= empty_s;
  valid <= valid_s;
  do    <= do_s;

  -- determine flags
  full_s  <= '1' when tail = head+1 else '0';
  empty_s <= '1' when tail = head   else '0';

  -----------------------------------------------------------------------------
  -- one process FSM
  -----------------------------------------------------------------------------
  process (CLK, di, wr, rd)
  begin
    if rising_edge(CLK) then
      if (wr = '1' and full_s = '0') then
        mem(to_integer(head)) <= di;
        head                  <= head + 1;
      end if;

      if (rd = '1' and empty_s = '0') then
        do_s    <= std_logic_vector(mem(to_integer(tail)));
        valid_s <= '1';
        tail    <= tail + 1;
      else
        valid_s <= '0';
      end if;
    end if;
  end process;
  
end behavioural;
