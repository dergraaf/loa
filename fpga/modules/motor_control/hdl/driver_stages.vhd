


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

begin
   bldc_driver_stage_st.a.high  <= bldc_driver_stage.a.high;
   bldc_driver_stage_st.a.low_n <= not bldc_driver_stage.a.low;
   bldc_driver_stage_st.b.high  <= bldc_driver_stage.b.high;
   bldc_driver_stage_st.b.low_n <= not bldc_driver_stage.b.low;
   bldc_driver_stage_st.c.high  <= bldc_driver_stage.c.high;
   bldc_driver_stage_st.c.low_n <= not bldc_driver_stage.c.low;
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
