-------------------------------------------------------------------------------
-- Title      : Goertzel Algorithm pipelined with BRAM
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipelined_v2.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-24
-- Last update: 2012-04-24
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.signalprocessing_pkg.all;

entity goertzel_pipelined_v2 is
   
   generic (
      FREQUENCIES : positive := 5;
      CHANNELS    : positive := 12;
      SAMPLES     : positive := 250);

   port (
      start_p     : in  std_logic;
      bram_addr_p : out std_logic_vector(7 downto 0);
      bram_data_i : in  std_logic_vector(35 downto 0);
      bram_data_o : out std_logic_vector(35 downto 0);
      bram_we_p   : out std_logic;
      ready_p     : out std_logic;
      enable_p    : in  std_logic;
      coefs_p     : in  goertzel_coefs_type(FREQUENCIES-1 downto 0);
      inputs_p    : in  goertzel_inputs_type(CHANNELS-1 downto 0);
      clk         : in  std_logic);
   
end entity goertzel_pipelined_v2;

architecture structural of goertzel_pipelined_v2 is


begin  -- architecture structural



end architecture structural;
