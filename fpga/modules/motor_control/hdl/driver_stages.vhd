


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
