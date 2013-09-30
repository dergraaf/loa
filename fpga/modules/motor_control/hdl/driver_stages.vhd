-------------------------------------------------------------------------------
-- Title      : Driver Stage Converters
-- Project    : 
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Convert the interface for DC and BLDC motors to driver stages
--              with halfbridges from ST. 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.motor_control_pkg.all;

entity bldc_driver_stage_converter is
   port (
      bldc_driver_stage    : in  bldc_driver_stage_type;
      bldc_driver_stage_st : out bldc_driver_stage_st_type
      );

end bldc_driver_stage_converter;

architecture structural of bldc_driver_stage_converter is
   signal shoot_through_a : std_logic := '0';  -- The bridge is requested to do
                                               -- a shoot through. This should never happen.
   signal shoot_through_b : std_logic := '0';
   signal shoot_through_c : std_logic := '0';
   signal shoot_through   : std_logic;

begin
   shoot_through_a <= '1' when ((bldc_driver_stage.a.high = '1') and (bldc_driver_stage.a.low = '1')) else '0';
   shoot_through_b <= '1' when ((bldc_driver_stage.b.high = '1') and (bldc_driver_stage.b.low = '1')) else '0';
   shoot_through_c <= '1' when ((bldc_driver_stage.c.high = '1') and (bldc_driver_stage.c.low = '1')) else '0';

   shoot_through <= shoot_through_a or shoot_through_b or shoot_through_c;

   bldc_driver_stage_st.a.high  <= '1' when ((bldc_driver_stage.a.high = '1') and (shoot_through = '0')) else '0';
   bldc_driver_stage_st.a.low_n <= '0' when ((bldc_driver_stage.a.low = '1') and (shoot_through = '0'))  else '1';
   bldc_driver_stage_st.b.high  <= '1' when ((bldc_driver_stage.b.high = '1') and (shoot_through = '0')) else '0';
   bldc_driver_stage_st.b.low_n <= '0' when ((bldc_driver_stage.b.low = '1') and (shoot_through = '0'))  else '1';
   bldc_driver_stage_st.c.high  <= '1' when ((bldc_driver_stage.c.high = '1') and (shoot_through = '0')) else '0';
   bldc_driver_stage_st.c.low_n <= '0' when ((bldc_driver_stage.c.low = '1') and (shoot_through = '0'))  else '1';
end structural;

---------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.motor_control_pkg.all;

-- Convert from PWM1/2 + shutdown interface to ST halfbridge
entity dc_driver_stage_converter is
   port (
      pwm1_in_p                : in  std_logic;
      pwm2_in_p                : in  std_logic;
      sd_in_p                  : in  std_logic;
      dc_driver_stage_st_out_p : out dc_driver_stage_st_type
      );

end dc_driver_stage_converter;

architecture structural of dc_driver_stage_converter is

begin
   process (pwm1_in_p, pwm2_in_p, sd_in_p)
   begin
      if sd_in_p = '1' then
                                        -- disable both
         dc_driver_stage_st_out_p.a.high  <= '0';
         dc_driver_stage_st_out_p.a.low_n <= '1';
         dc_driver_stage_st_out_p.b.high  <= '0';
         dc_driver_stage_st_out_p.b.low_n <= '1';
      else
         if pwm1_in_p = '0' then
            dc_driver_stage_st_out_p.a.high  <= '0';
            dc_driver_stage_st_out_p.a.low_n <= '0';
         else
            dc_driver_stage_st_out_p.a.high  <= '1';
            dc_driver_stage_st_out_p.a.low_n <= '1';
         end if;

         if pwm2_in_p = '0' then
            dc_driver_stage_st_out_p.b.high  <= '0';
            dc_driver_stage_st_out_p.b.low_n <= '0';
         else
            dc_driver_stage_st_out_p.b.high  <= '1';
            dc_driver_stage_st_out_p.b.low_n <= '1';
         end if;

      end if;
   end process;
end structural;
