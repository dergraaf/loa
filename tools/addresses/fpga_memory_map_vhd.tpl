
-- WARNING: This file is generated automatically, do not edit!
-- Please modify fpga_base_addresses.py instead and/or
-- fpga_memory_map_vhd.tpl

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------

package memory_map_pkg is

   {%- for m in modules %}
   constant BASE_ADDRESS_{{ m.name | enumElement }}: natural := {{ m.baseAddress | hex }};
   {%- endfor %}

end memory_map_pkg;
