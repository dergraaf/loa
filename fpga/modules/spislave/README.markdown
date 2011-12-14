
The SPI Slave module has two responsibilities:
- Decoding the SPI protocol
- Busmaster for the internal bus


Protocol
--------

All transfers (address and data) are 16-bit. First the address is written.
The MSB determines wether the folowing transfer is a read (MSB = '0') or write (MSB = '1')
transfer.