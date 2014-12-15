-------------------------------------------------------------------------------
-- Title      : WS2812 Controller Package
-------------------------------------------------------------------------------
-- Author     : cjt@users.sourceforge.net
-------------------------------------------------------------------------------
-- Created    : 2014-12-14
-------------------------------------------------------------------------------
-- Copyright (c) 2014, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package ws2812_pkg is

  -----------------------------------------------------------------------------
  -- Pixel Pusher
  -----------------------------------------------------------------------------
  type ws2812_out_type is record
    busy : std_logic;
  end record;

  type ws2812_in_type is record
    d          : std_logic_vector(23 downto 0);
    we         : std_logic;
    send_reset : std_logic;
  end record;

  type ws2812_chain_out_type is record
    d : std_logic;
  end record;

  component ws2812
    port (
      ws2812_in        : in  ws2812_in_type;
      ws2812_out       : out ws2812_out_type;
      ws2812_chain_out : out ws2812_chain_out_type;
      clk              : in  std_logic);
  end component;


  -----------------------------------------------------------------------------
  -- 8 Pixel Controller
  -----------------------------------------------------------------------------
  type pixel is array (natural range <>) of std_logic_vector(23 downto 0);

  type ws2812_8x1_in_type is record
    pixel   : pixel(7 downto 0);
    refresh : std_logic;
  end record;

  component ws2812_8x1
    port (
      pixels     : in  ws2812_8x1_in_type;
      ws2812_in  : out ws2812_in_type;
      ws2812_out : in  ws2812_out_type;
      clk        : in  std_logic);
  end component;
  
end ws2812_pkg;


