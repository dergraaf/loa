-------------------------------------------------------------------------------
-- Title      : Fixed point implementation of Goertzel's Algorithm
-- Project    : 
-------------------------------------------------------------------------------
-- File       : goertzel_pipeline.vhd
-- Author     : strongly-typed
-- Company    : 
-- Created    : 2012-04-15
-- Last update: 2012-05-04
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: Fixed point implementation of Goertzel's Algorithm to detect a
-- fixed frequency in an analog signal.
-- 
-- This is just the pipeline. The control unit in in entity
-- goertzel_control_unit and the muxes are in goertzel_muxes.
--
-- This does not implement the calculation
-- of the magnitude of the signal at the end of one block.
-- Mind overflows!
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library work;
use work.signalprocessing_pkg.all;

-------------------------------------------------------------------------------

entity goertzel_pipeline is
   generic (
      -- Width of ADC input
      -- Due to overflow prevention: Not as wide as the internal width of
      -- calculations. Set in the signalprocessing_pkg.vhd
      -- INPUT_WIDTH : natural := 14;

      -- Width of internal calculations
      -- Remember that internal multiplier are at most 18 bits wide (in Xilinx Spartan)
      -- CALC_WIDTH : natural := 18;

      -- Fixed point data format
      Q : natural := 13
      );
   port (
      -- Goertzel Coefficient calculated by
      coef_p : in goertzel_coef_type;

      -- One values from ADC
      input_p : in goertzel_input_type;

      -- The old result
      delay_p : in goertzel_result_type;

      -- Result 
      result_p : out goertzel_result_type;

      clk : in std_logic
      );

end goertzel_pipeline;

architecture rtl of goertzel_pipeline is

   signal delay_1_reg  : goertzel_data_type := (others => '0');
   signal delay_1_reg2 : goertzel_data_type := (others => '0');
   signal delay_2_reg  : goertzel_data_type := (others => '0');
   signal delay_2_reg2 : goertzel_data_type := (others => '0');
   signal coef_reg     : goertzel_coef_type := (others => '0');

   signal input_reg  : goertzel_input_type := (others => '0');
   signal input_reg2 : goertzel_input_type := (others => '0');

   signal prod_scaled_reg : goertzel_data_type := (others => '0');

   signal overflow : std_logic := '0';

begin  -- architecture rtl

   -- data path B
   B : process (clk) is
      variable prod_v : signed(35 downto 0) := (others => '0');
   begin  -- process B
      if rising_edge(clk) then          -- rising clock edge
         -- 1st RTL
         delay_1_reg <= delay_p(0);
         delay_2_reg <= delay_p(1);
         coef_reg    <= coef_p;
         input_reg   <= input_p;

         -- 2nd RTL
         delay_1_reg2    <= delay_1_reg;
         delay_2_reg2    <= delay_2_reg;
         prod_v          := delay_1_reg * coef_reg;
         prod_scaled_reg <= prod_v((Q + CALC_WIDTH - 1) downto Q);
         if (prod_v(35 downto Q + CALC_WIDTH) = (35 downto (Q + CALC_WIDTH) => '0')) or
            (prod_v(35 downto Q + CALC_WIDTH) = (35 downto (Q + CALC_WIDTH) => '1')) then
            overflow <= '0';
         else
            overflow <= '1';
         end if;
         input_reg2 <= input_reg;

         -- 3rd RTL
         result_p(0) <= delay_2_reg2 - prod_scaled_reg + input_reg2;
         result_p(1) <= delay_1_reg2;
         
      end if;
   end process B;

end architecture rtl;
