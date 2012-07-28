-------------------------------------------------------------------------------
-- Title      : Commutation control via Hall sensors
-- Project    : 
-------------------------------------------------------------------------------
-- File       : commutation.vhd
-- Author     : Fabian Greif  <fabian.greif@rwth-aachen.de>
-- Company    : Roboterclub Aachen e.V.
-- Created    : 2011-12-17
-- Last update: 2012-07-28
-- Platform   : Spartan 3
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.motor_control_pkg.all;

package commutation_pkg is

   component commutation is
      port (
         driver_stage_p : out bldc_driver_stage_type;
         hall_p         : in  hall_sensor_type;
         pwm_p          : in  half_bridge_type;
         dir_p          : in  std_logic;
         sd_p           : in  std_logic;
         clk            : in  std_logic);
   end component commutation;
   
end commutation_pkg;

-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library work;
use work.commutation_pkg.all;
use work.motor_control_pkg.all;

entity commutation is
   port (
      driver_stage_p : out bldc_driver_stage_type;  -- Driver Stage of 3 half bridges

      hall_p : in hall_sensor_type;     -- Hall Sensors
      pwm_p  : in half_bridge_type;
      dir_p  : in std_logic;            -- Direction
      sd_p   : in std_logic;            -- Shutdown

      clk : in std_logic
      );
end commutation;

architecture behavioral of commutation is
   type commutation_type is record
      hall_1r : std_logic_vector(2 downto 0);
      hall_2r : std_logic_vector(2 downto 0);

      driver : bldc_driver_stage_type;
   end record;

   signal r, rin : commutation_type;
begin
   seq_proc : process(clk)
   begin
      if rising_edge(clk) then
         r <= rin;
      end if;
   end process seq_proc;

   comb_proc : process(dir_p, hall_p.a, hall_p.b, hall_p.c,
                       pwm_p.high, pwm_p.low, r, r.hall_1r, r.hall_2r, sd_p)
      variable v     : commutation_type;
      variable index : integer range 0 to 6;
   begin
      v := r;

      -- synchronise Hall sensors inputs
      v.hall_1r := hall_p.a & hall_p.b & hall_p.c;
      v.hall_2r := r.hall_1r;

      if dir_p = '0' then
         case r.hall_2r is
            when "101"  => index := 1;
            when "100"  => index := 2;
            when "110"  => index := 3;
            when "010"  => index := 4;
            when "011"  => index := 5;
            when "001"  => index := 6;
            when others => index := 0;
         end case;
      else
         case r.hall_2r is
            when "101"  => index := 4;
            when "100"  => index := 5;
            when "110"  => index := 6;
            when "010"  => index := 1;
            when "011"  => index := 2;
            when "001"  => index := 3;
            when others => index := 0;
         end case;
      end if;

      case index is
         when 1 =>
            v.driver := (a => (pwm_p.high, pwm_p.low),
                         b => ('0', '1'),
                         c => ('0', '0'));
         when 2 =>
            v.driver := (a => (pwm_p.high, pwm_p.low),
                         b => ('0', '0'),
                         c => ('0', '1'));
         when 3 =>
            v.driver := (a => ('0', '0'),
                         b => (pwm_p.high, pwm_p.low),
                         c => ('0', '1'));
         when 4 =>
            v.driver := (a => ('0', '1'),
                         b => (pwm_p.high, pwm_p.low),
                         c => ('0', '0'));
         when 5 =>
            v.driver := (a => ('0', '1'),
                         b => ('0', '0'),
                         c => (pwm_p.high, pwm_p.low));
         when 6 =>
            v.driver := (a => ('0', '0'),
                         b => ('0', '1'),
                         c => (pwm_p.high, pwm_p.low));
         when others =>
            -- Error in the readings of the Hall-Sensors => Disable PWM
            v.driver := (a => ('0', '0'),
                         b => ('0', '0'),
                         c => ('0', '0'));
      end case;


      if sd_p = '1' then
         v.driver :=
            (a => ('0', '0'),
             b => ('0', '0'),
             c => ('0', '0'));
      end if;

      rin <= v;
   end process comb_proc;

   driver_stage_p <= r.driver;

end behavioral;
