#!/usr/bin/python

import os
import time
import codecs		# utf-8 file support
import sys
import jinja2		# template engine
import textwrap
import imp
from bitarray import bitarray
from optparse import OptionParser

def typeName(value):
	return value.title().replace(' ', '')

def variableName(value):
	value = value.title().replace(' ', '')
	value = value[0].lower() + value[1:]
	return value

def enumElement(value):
	return value.upper().replace(' ', '_')
	
def cppHex(value):
	return '0x%04x' % value
	
def vhdHex(value):
	return '16#%04x#' % value

class ModuleDescription():
	def __init__(self, name, baseAddress, bits, moduleType):
		self.name = name
		self.baseAddress = baseAddress
		self.bits = bits
		self.moduleType = moduleType
		self.writeTable = []
		self.readTable = []
		
	peripheral_register =        {'read' : ['value'],         'write' : ['value']}
	bldc_motor_module          = {'read' : [],                'write' : ['pwm']}
	encoder_module_extended    = {'read' : ['steps', 'time'], 'write' : []}
	encoder_hall_sensor_module = {'read' : ['steps'],         'write' : []}
	dc_motor_module            = {'read' : [],                'write' : ['pwm']}
	dc_motor_module_extended   = {'read' : [],                'write' : ['pwm0', 'pwm1']}
	servo_module               = {'read' : [],                'write' : ['servo2', 'servo3']}
	imotor_module = {
					'read' : [
							'encoder0', 'current0', 'status0',
							'encoder1', 'current1', 'status1',
							'encoder2', 'current2', 'status2',
							'encoder3', 'current3', 'status3',
							'encoder4', 'current4', 'status4',
							],
					'write' : [
							'pwm0', 'current0',
							'pwm1', 'current1',
							'pwm2', 'current2',
							'pwm3', 'current3',
							'pwm4', 'current4',
							]}
	comparator_module = {
						'read':[
							'upperLimit0',
							'lowerLimit0',
							'upperLimit1',
							'lowerLimit1',
							'upperLimit2',
							'lowerLimit2',
							'upperLimit3',
							'lowerLimit3',
							'upperLimit4',
							'lowerLimit4',
							], 
						'write':[
							'upperLimit0',
							'lowerLimit0',
							'upperLimit1',
							'lowerLimit1',
							'upperLimit2',
							'lowerLimit2',
							'upperLimit3',
							'lowerLimit3',
							'upperLimit4',
							'lowerLimit4',
							]}
	adc_ad7266_single_ended_module = {
									'read':[
											'channel0',
											'channel1',
											'channel2',
											'channel3',
											'channel4',
											'channel5',
											'channel6',
											'channel7',
											'channel8',
											'channel9',
											'channel10',
											'channel11',
											], 
									'write':[]}

class Register():
	def __init__(self, name, index, module):
		self.name = name
		self.index = index
		self.module = module

'''
Create files in cpp and vhdl to maintain same addresses in the FPGA Design and 
the software. 
'''
class FpgaBaseAddresses():
	
	def __init__(self, outpath, configFile):
		self.outputPath = outpath
		self.configFile = configFile
		self.globals = {
					'time': time.strftime("%d %b %Y, %H:%M:%S", time.localtime()),
		}
		
		'''
		Read in from config file 
		'''
		print configFile
		allModules = imp.load_source("irgendeinBlaBla", configFile)
		self.allModules = allModules.allModules 
	
	def run(self):
		self.generate()

	def generate(self):
		'''
		Check if address spaces collide
		'''
		self.checkColidingAddresses(self.allModules)
		
		writeElements = self.createWriteTable(self.allModules);
		readElements = self.createReadTable(self.allModules);
		
		cppFilter = {
			'enumElement': enumElement,
			'variableName': variableName,
			'typeName': typeName,
			'hex': cppHex,
		}

		vhdFilter = {
			'enumElement': enumElement,
			'variableName': variableName,
			'typeName': typeName,
			'hex': vhdHex,
		}
		
		templateHpp = self.template('fpga_memory_map_hpp.tpl', filter=cppFilter)
		templateVhd = self.template('fpga_memory_map_vhd.tpl', filter=vhdFilter)
		
		substitutions = {
			'modules': self.allModules,
			'writeElements' : writeElements,
			'readElements' : readElements,
			'countOfReadElements' : len(readElements),
			'countOfWriteElements' : len(writeElements),
		}
		
		file = os.path.join(self.outputPath, 'fpga_memory_map.hpp')
		self.write(file, templateHpp.render(substitutions) + "\n")
		file = os.path.join(self.outputPath, 'fpga_memory_map.vhd')
		self.write(file, templateVhd.render(substitutions) + "\n")
		
	def createWriteTable(self, allModules):
		table = []
		i = 0;
		for module in allModules:
			for register in module.moduleType['write']:
				r = Register(register, i, module)
				table.append(r)
				module.writeTable.append(r)
				i += 1
		return table
		
	def createReadTable(self, allModules):
		table = []
		i = 0;
		for module in allModules:
			for register in module.moduleType['read']:
				r = Register(register, i, module)
				table.append(r)
				module.readTable.append(r)
				i += 1
		return table
		
	def checkColidingAddresses(self, allModules):
		addrSpace = bitarray(2**16)
		addrSpace.setall(False)
		
		for modules in allModules:
			if addrSpace[modules.baseAddress : modules.baseAddress + 2**modules.bits].any():
				raise Exception('FPGA address check: Module "%s" collides' % (modules.name.upper()));
			addrSpace[modules.baseAddress : modules.baseAddress + 2**modules.bits] = True

	def write(self, filename, data):
		"""
		Write data utf-8 decoded to a file.
		
		Contents of the file will be overwritten.
		"""
		# create the path if it doesn't exists
		dir = os.path.dirname(filename)
		if not os.path.isdir(dir):
			os.mkdir(dir)
		
		# write data
		file = codecs.open(filename, 'w', 'utf8')
		file.write(data)
		file.close()
	

	def template(self, filename, filter=None):
		""" Open a template file
		
		Uses the jinja2 template engine. The following additional filters
		are included:
		xpcc.wordwrap(with)		--	like the original filter, but with correct
									handling of newlines
		xpcc.indent(level)		--	indent every line with \a level tabs
		
		Keyword arguments:
		filename	--	Template file
		filter		--	dict with additional filters (see the section 
						'Custom Filters' in the Jinja2 documentation for details)
		
		Example:
		template = builder.template(file)
		
		output = template.render(dict)
		builder.write(outputfile, output)
		
		"""
		def filter_wordwrap(value, width=79):
			return '\n\n'.join([textwrap.fill(str, width) for str in value.split('\n\n')])

		def filter_indent(value, level=0, prefix=""):
			return ('\n' + '\t' * level + prefix).join(value.split('\n'))
		
		path = os.path.dirname(filename)
		name = os.path.basename(filename)
		
		if not os.path.isabs(filename):
			relpath = os.path.dirname(os.path.abspath(__file__))
			path = os.path.join(relpath, path)
		
		environment = jinja2.Environment(
				loader=jinja2.FileSystemLoader(path),
				extensions=["jinja2.ext.loopcontrols"])
		environment.filters['xpcc.wordwrap'] = filter_wordwrap
		environment.filters['xpcc.indent'] = filter_indent
		if filter:
			environment.filters.update(filter)
		template = environment.get_template(name, globals=self.globals)
		
		return template
# -----------------------------------------------------------------------------
if __name__ == '__main__':
	optparser = OptionParser(
			usage   = "%prog [options]" )
	
	optparser.add_option(
			"-o", "--outpath",
			dest = "outpath",
			default = None,
			help = "Output path")
	
	optparser.add_option(
			"-c", "--config", 
			dest = "configFile", 
			default = None, 
			help = "Input python file with system configuration")
	
	(options, args) = optparser.parse_args()
	
	if not options.outpath:
		raise Exception("You need to provide an output path with '-o' !")
	
	if not options.configFile:
		raise Exception("You need to provide an configuration file with '-c' !")

	FpgaBaseAddresses(options.outpath, options.configFile).run()
