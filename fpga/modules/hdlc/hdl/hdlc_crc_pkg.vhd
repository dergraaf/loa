-------------------------------------------------------------------------------
-- Title      : HDLC async Encoder & Decoder
-------------------------------------------------------------------------------
-- Author     : Carl Treudler (cjt@users.sourceforge.net)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-- CRC-8 for HDLC, x^8 + x^2 + x^1 + 1
-------------------------------------------------------------------------------
-- Package:
-- Copyright (c) 2013, Carl Treudler
-- All Rights Reserved.
--
-- The file is part for the Loa project and is released under the
-- 3-clause BSD license. See the file `LICENSE` for the full license
-- governing this code.
-------------------------------------------------------------------------------
-- CRC function:
-- Copyright (C) 1999-2008 Easics NV. (see disclaimer over function)
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package hdlc_crc_pkg is
  function calc_crc_8210(Data : std_logic_vector(7 downto 0);
                         crc  : std_logic_vector(7 downto 0)) return std_logic_vector;

end package hdlc_crc_pkg;

package body hdlc_crc_pkg is

  --------------------------------------------------------------------------------
  -- Copyright (C) 1999-2008 Easics NV.
  -- This source file may be used and distributed without restriction
  -- provided that this copyright statement is not removed from the file
  -- and that any derivative work contains the original copyright notice
  -- and the associated disclaimer.
  --
  -- THIS SOURCE FILE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS
  -- OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
  -- WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
  --
  -- Info : tools@easics.be / http://www.easics.com
  --------------------------------------------------------------------------------
  -- polynomial: (0 1 2 8)
  -- data width: 8
  -- convention: the first serial bit is D[7]
  function calc_crc_8210(Data : std_logic_vector(7 downto 0);
                         crc  : std_logic_vector(7 downto 0)) return std_logic_vector is
    variable d      : std_logic_vector(7 downto 0);
    variable c      : std_logic_vector(7 downto 0);
    variable newcrc : std_logic_vector(7 downto 0);

  begin
    d := Data;
    c := crc;

    newcrc(0) := d(7) xor d(6) xor d(0) xor c(0) xor c(6) xor c(7);
    newcrc(1) := d(6) xor d(1) xor d(0) xor c(0) xor c(1) xor c(6);
    newcrc(2) := d(6) xor d(2) xor d(1) xor d(0) xor c(0) xor c(1) xor c(2) xor c(6);
    newcrc(3) := d(7) xor d(3) xor d(2) xor d(1) xor c(1) xor c(2) xor c(3) xor c(7);
    newcrc(4) := d(4) xor d(3) xor d(2) xor c(2) xor c(3) xor c(4);
    newcrc(5) := d(5) xor d(4) xor d(3) xor c(3) xor c(4) xor c(5);
    newcrc(6) := d(6) xor d(5) xor d(4) xor c(4) xor c(5) xor c(6);
    newcrc(7) := d(7) xor d(6) xor d(5) xor c(5) xor c(6) xor c(7);
    return newcrc;
  end calc_crc_8210;

end hdlc_crc_pkg;



