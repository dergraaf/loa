Documentation
=============

Microcontroller selection
-------------------------

For this controller board we wanted to use a Cortex-M3 chip. There are only two
families in wider use at the moment. The STM32F series from ST and the LPC1700
series from NXP.
One goal was that the microcontroller should be be able to control the drive
system of a robot without the FPGA. Therefore it needs to be able to read
four quadrature encoder and control two motors. This leaves only the STM32 series
as the LPC1700 features only one quadrature encoder.

Currently there are four different strains within the STM32 series available.

STM32F207
---------

Pin  | Alternate Functions      | Usage
---- | ------------------------ | --------------------------
PA0  | ADC0/Timer 2.1/Timer 5.1 | 
PA1  | ADC1/Timer 2.2/Timer 5.2 | 
PA2  | ADC2/Timer 9.1           | 
PA3  | ADC3/Timer 9.2           | 
PA4  | SPI1 Cs                  | -> FPGA
PA5  | SPI1 Sck                 | -> FPGA 
PA6  | SPI1 Miso                | <- FPGA
PA7  | SPI1 Mosi                | -> FPGA
PA8  |                          | <- FPGA
PA9  | USB Vbus                 | <- USB
PA10 | USB ID                   | <- USB 
PA11 | USB DM                   | <> USB
PA12 | USB DP                   | <> USB
PA13 | TMS                      | <- JTAG
PA14 | TCK                      | <- JTAG
PA15 | TDI                      | <- JTAG
---- | ------------------------ | --------------------------
PB0  | ADC8/Timer 3.3           | 
PB1  | ADC9/Timer 3.4           | 
PB2  |                          | 
PB3  | TDO                      | -> JTAG
PB4  | Timer 3.1/TRST           | 
PB5  | Timer 3.2                | 
PB6  | UART1 Tx                 | -> UART
PB7  | UART1 Rx                 | <- UART
PB8  | I2C1 Scl                 | 
PB9  | I2C1 Sda                 | 
PB10 | I2C2 Scl                 | 
PB11 | I2C2 Sda                 | 
PB12 | SPI2 Cs /CAN2 Rx         | -> Dataflash
PB13 | SPI2 Sck/CAN2 Tx         | -> SD Card/Dataflash/FPGA
PB14 | SPI2 Miso                | <- SD Card/Dataflash/FPGA
PB15 | SPI2 Mosi                | -> SD Card/Dataflash/FPGA
---- | ------------------------ | --------------------------
PC0  | ADC10                    | 
PC1  | ADC11                    | 
PC2  | ADC12                    | 
PC3  | ADC13                    | 
PC4  | ADC14                    | 
PC5  | ADC15                    | 
PC6  | Timer 3.1/Timer 8.1      | 
PC7  | Timer 3.2/Timer 8.2      | 
PC8  | Timer 3.3/Timer 8.3      | 
PC9  | Timer 3.4/Timer 8.4      | 
PC10 | UART4 Tx                 | 
PC11 | UART4 Rx                 | 
PC12 | UART5 Tx                 | -> Debug UART
PC13 | (nur als Eingang)        | 
PC14 | (nur als Eingang)        | 
PC15 | (nur als Eingang)        | 
---- | ------------------------ | --------------------------
PD0  | CAN1 Rx                  | <- CAN
PD1  | CAN1 Tx                  | -> CAN
PD2  | UART5 Rx                 | <- Debug UART
PD3  |                          | 
PD4  |                          | 
PD5  | UART2 Tx                 | 
PD6  | UART2 Rx                 | 
PD7  | UART2 Ck                 | 
PD8  | UART3 Tx                 | 
PD9  | UART3 Rx                 | 
PD10 | UART3 Ck                 | 
PD11 |                          | 
PD12 | Timer 4.1                | 
PD13 | Timer 4.2                | 
PD14 | Timer 4.3                | 
PD15 | Timer 4.4                | 
---- | ------------------------ | --------------------------
PE0  |                          | -> FPGA
PE1  |                          | -> FPGA
PE2  |                          | -> FPGA
PE3  |                          | -> FPGA
PE4  |                          | <- FPGA
PE5  | Timer 9.1                | 
PE6  | Timer 9.2                | 
PE7  |                          | 
PE8  | Timer 1.1N               | 
PE9  | Timer 1.1                | 
PE10 | Timer 1.2N               | 
PE11 | Timer 1.2                | 
PE12 | Timer 1.3N               | 
PE13 | Timer 1.3                | 
PE14 | Timer 1.4                | 
PE15 |                          | 

#### JTAG Connector

This is the official JTAG Connector proposed by ARM for the Cortex-M3. The only
difference is that we don't use a 1.27mm grid but a normal 2.54mm one. This
allows to use standard ribbon cable.

          ------
  3.3V --| 1  2 |-- TMS
   GND --| 3  4 |-- TCLK
   GND -[| 5  6 |-- TDO
  RTCK --| 7  8 |-- TDI
   GND --| 9 10 |-- Reset (SRST)
          ------

On this connector TRST (also called NJTRST) is not connected. This might
lead to the problem that the "reset halt" command from OpenOCD doesn't work.

RTCK is only used for ARM7 devices, so it is left open here.

FPGA Spartan-3
--------------

Unused pins are defined as inputs with pull-downs by default. Can be changed
by primitives or constraints in the bitstream generation.

All user-I/O pins, input-only pins, and dual-purpose pins that are not actively
involved in the currently-selected configuration mode are high impedance
(floating, three-stated, Hi-Z) during the configuration process.

### Configuration of the FPGA

DONE
:   Output with 2,5V supply. Driven low during configuration. Goes high after
    configuration has finished.

PROG_B
:   Input with 2,5 supply. Low pulse (>= 500ns) restarts the configuration
    process.

CCLK
:   Input with 2,5 supply in slave modes. Configuration clock.

DIN
:   Serial Mode input

DOUT
:   Serial Data Output. Not used in single FPGA designs.

INIT_B
:   Output with 3,3V suppy. Driven low during before configuration. After it
    goes high the M[2:0] pins are sampled and the configuration is started.
    Holding the pin low stalls the configuration start. During configuration
    During configuration, the FPGA indicates the occurrence of a configuration
    data error (i.e., CRC error) by asserting INIT_B Low.
    
    After configuration successfully completes, i.e., when the DONE pin goes
    High, the INIT_B pin is available as a full user-I/O pin.

HSWAP_EN 
:   When the pin is Low, each pin (not only the configuration pins) has an
    internal pull-up resistor that is active throughout configuration, starting
    immediately on power-up.

M[2:0]
:   Select the configuration mode.
    '111' Slave Serial Mode
    '101' JTAG Mode

### JTAG Connector

The JTAG connector is a stripped down version of the original connector from the
Xilinx Parallel Cable IV. Original it uses 14 pins, but we leave the last four
pins out to fit it to a standard 10 pin header. These pins are only used for
programming the FPGA via Slave Serial mode through the PC.

          ------
   GND --| 1  2 |-- Vref (connect to Vaux)
   GND --| 3  4 |-- TMS
   GND -[| 5  6 |-- TCK
   GND --| 7  8 |-- TDO
   GND --| 9 10 |-- TDI
          ------
