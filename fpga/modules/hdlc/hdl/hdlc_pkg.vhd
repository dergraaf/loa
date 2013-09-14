-------------------------------------------------------------------------------
-- Title      : HDLC async Encoder & Decoder
-------------------------------------------------------------------------------
-- Author     : Carl Treudler (cjt@users.sourceforge.net)
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-- * Encodes/decodes 8-Bit HDLC async framing int 8-bit data + frame delimiter.
-- * Includes loa busmaster controlled over hdlc channel.
--
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
use work.bus_pkg.all;

package hdlc_pkg is
  type hdlc_enc_in_type is record
    data   : std_logic_vector(8 downto 0);
    enable : std_logic;
  end record;

  type hdlc_enc_out_type is record
    data   : std_logic_vector(7 downto 0);
    enable : std_logic;
  end record;

  subtype hdlc_dec_in_type is hdlc_enc_out_type;
  subtype hdlc_dec_out_type is hdlc_enc_in_type;

  component hdlc_enc is
    port(
      din_p  : in  hdlc_enc_in_type;
      dout_p : out hdlc_enc_out_type;
      busy_p : out std_logic;
      clk    : in  std_logic
      );
  end component;

  component hdlc_dec is
    port(
      din_p  : in  hdlc_dec_in_type;
      dout_p : out hdlc_dec_out_type;
      clk    : in  std_logic
      );
  end component;

  component hdlc_busmaster
    port (
      din_p  : in  hdlc_dec_out_type;
      dout_p : out hdlc_enc_in_type;
      bus_o  : out busmaster_out_type;
      bus_i  : in  busmaster_in_type;
      clk    : in  std_logic);
  end component;

end package hdlc_pkg;





