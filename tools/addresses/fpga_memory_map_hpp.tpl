
/*
 * WARNING: This file is generated automatically, do not edit!
 * Please modify fpga_base_addresses.py and/or 
 * fpga_memory_map_hpp.tpl instead.
 */
// ----------------------------------------------------------------------------

#ifndef FPGA_MEMORY_MAP_HPP_
#define FPGA_MEMORY_MAP_HPP_

#include <stdint.h>

namespace fpga {
	enum class BaseAddress : uint16_t
	{
	{%- for m in modules %}
		{{ m.name | typeName }} = {{ m.baseAddress | hex }},
	{%- endfor %}
	};
	
	struct ReadAddreses { // read from fpga
		{%- for m in modules %}
		struct {{ m.name | typeName }} {
			static const uint16_t base = (uint16_t)BaseAddress::{{ m.name | typeName }};
			{%- for register in m.moduleType.read %}
			static const uint16_t {{ register }} = base {%- if (loop.index > 1) %} + {{ loop.index - 1 }}{% endif %};
			{%- endfor %}
		};
		{%- endfor %}
	};
	
	struct WriteAddreses { // write to fpga
		{%- for m in modules %}
		struct {{ m.name | typeName }} {
			static const uint16_t base = (uint16_t)BaseAddress::{{ m.name | typeName }} | 0x8000;
			{%- for register in m.moduleType.write %}
			static const uint16_t {{ register }} = base {%- if (loop.index > 1) %} + {{ loop.index - 1 }}{% endif %};
			{%- endfor %}
		};
		{%- endfor %}
	};
	
	struct WriteIndices {
		{%- for m in modules %}
		struct {{ m.name | typeName }} {
			{%- for register in m.writeTable %}
			static const uint16_t {{ register.name }} = {{ register.index }};
			{%- endfor %}
		};
		{%- endfor %}
	};
	
	struct ReadIndices {
		{%- for m in modules %}
		struct {{ m.name | typeName }} {
			{%- for register in m.readTable %}
			static const uint16_t {{ register.name }} = {{ register.index }};
			{%- endfor %}
		};
		{%- endfor %}
	};
	
	const uint16_t fromFpgaAddress[] = {
			{%- for r in readElements %}
			ReadAddreses::{{ r.module.name | typeName }}::{{ r.name }},
			{%- endfor %}
	};
	
	const uint16_t toFpgaAddress[] = {
			{%- for r in writeElements %}
			WriteAddreses::{{ r.module.name | typeName }}::{{ r.name }},
			{%- endfor %}
	};
	
	static const uint16_t countOfReadElements = XPCC__ARRAY_SIZE(fromFpgaAddress);
	static const uint16_t countOfWriteElements = XPCC__ARRAY_SIZE(toFpgaAddress);
};

#endif /* FPGA_MEMORY_MAP_HPP_ */
