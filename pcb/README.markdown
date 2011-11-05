Documentation
=============

Microcontroller selection
-------------------------

For this controller board we wanted to use a Cortex-M3 chip. There are only two
families in wider use at the moment. The STM32F series from ST and the LPC1700
series from NXP.
One goal was that the microcontroller should be be able to control the drive
system of a robot without the FPGA. Therefore it needs to be able to read
four quadrature encoder and control two motors. This leaves only the STM32
series as the LPC1700 features only one quadrature encoder.

Currently there are four different strains within the STM32 series available.
The STM32F103 was the first one. A lot of development boards use controllers
from this series. But it has a quite long and annoying Errata Sheet, some
peripherals don't work with each other. Most important it is not possible to
use CAN and USB at the same time because they share an internal buffer.
After the 103er the 105/107er arrived. Their most important feature is that it
is possible to use CAN and USB at the same time. Some other stuff like the
ethernet interface are not important for us. The peripherals are improved,
leading to a shorter Errata Sheet. Their only drawback comparted to the 103er
series is that they are limited to 256kB Flash compared to a maximum of
1024kB for the 103er. The 256kB Flash might just be to few for the desired
application as a robot controller.

In the last time two new strains appeared. The STM32F200- and the
STM32F400-series. They are improvments of the 105/107er with a slightly
different pinout. Some of the power pins need to be connected differently, all
of the IO-Pins remain the same. Therefore it is possible to create a board
which supports STM32F1xx and STM32F2xx through some solder jumpers.
The STM32F207 are a bit faster (120MHz instead of 72MHz) and provide more Flash
memory (up to 1024kB). The STM32F407 uses an Cortex-M4 instead of the Cortex-M3
of all the other devices. With 150MHz and an integrated FPU it should be again
faster, especially for floating point calculations. The STM32F4xx are pin
compatible to the STM32F2xx.

As the STM32F4xx are to new and are not yet available from distributors like
Farnell we choose the STM32F207. This leaves the options of an upgrade to a
STM32F407 later.


STM32F207
---------

Pin  | Alternate Functions      | Usage on the Board         | Proposed Usage
---- | ------------------------ | -------------------------- | ----------------
PA0  | ADC0/Timer 2.1/Timer 5.1 |                            | Encoder 1
PA1  | ADC1/Timer 2.2/Timer 5.2 |                            | Encoder 1
PA2  | ADC2/Timer 9.1           |                            |     - 
PA3  | ADC3/Timer 9.2           |                            |     - 
PA4  | SPI1 Cs                  | -> FPGA (DIN)              | 
PA5  | SPI1 Sck                 | -> FPGA                    | 
PA6  | SPI1 Miso                | <- FPGA                    | 
PA7  | SPI1 Mosi                | -> FPGA                    | 
PA8  |                          | <- FPGA                    | 
PA9  | USB Vbus                 | <- USB                     | 
PA10 | USB ID                   | <- USB                     | 
PA11 | USB DM                   | <> USB                     | 
PA12 | USB DP                   | <> USB                     | 
PA13 | TMS                      | <- JTAG                    | 
PA14 | TCK                      | <- JTAG                    | 
PA15 | TDI                      | <- JTAG                    | 
---- | ------------------------ | -------------------------- | ----------------
PB0  | ADC8/Timer 3.3           |                            |     - 
PB1  | ADC9/Timer 3.4           |                            |     - 
PB2  | (BOOT1)                  | FPGA_CCLK                  | 
PB3  | TDO                      | -> JTAG                    | 
PB4  | Timer 3.1/TRST           |                            | Encoder 2
PB5  | Timer 3.2                |                            | Encoder 2
PB6  | UART1 Tx                 |                            | -> Upstream
PB7  | UART1 Rx                 |                            | <- Upstream
PB8  | I2C1 Scl                 |                            |     - 
PB9  | I2C1 Sda                 |                            |     - 
PB10 | I2C2 Scl                 |                            |     - 
PB11 | I2C2 Sda                 |                            |     - 
PB12 | SPI2 Cs /CAN2 Rx         |                            |     - 
PB13 | SPI2 Sck/CAN2 Tx         |                            |     - 
PB14 | SPI2 Miso                |                            |     - 
PB15 | SPI2 Mosi                |                            |     - 
---- | ------------------------ | -------------------------- | ----------------
PC0  | ADC10                    |                            |     - 
PC1  | ADC11                    |                            |     - 
PC2  | ADC12                    |                            |     - 
PC3  | ADC13                    |                            |     - 
PC4  | ADC14                    |                            |     - 
PC5  | ADC15                    |                            |     - 
PC6  | Timer 3.1/Timer 8.1      |                            | Encoder 3
PC7  | Timer 3.2/Timer 8.2      |                            | Encoder 3
PC8  | Timer 3.3/Timer 8.3      |                            |     - 
PC9  | Timer 3.4/Timer 8.4      |                            |     - 
PC10 | UART4 Tx                 |                            | APB
PC11 | UART4 Rx                 |                            | APB
PC12 | UART5 Tx                 |                            | -> Debug UART
PC13 | (nur als Eingang)        | <- Button 1                | 
PC14 | (nur als Eingang)        | <- FPGA (DONE)             | 
PC15 | (nur als Eingang)        | <- SD Card Detect          | 
---- | ------------------------ | -------------------------- | ----------------
PD0  | CAN1 Rx                  | <- CAN                     | 
PD1  | CAN1 Tx                  | -> CAN                     | 
PD2  | UART5 Rx                 |                            | <- Debug UART
PD3  |                          | -> SD Card (CS)            | 
PD4  |                          |                            |     - 
PD5  | UART2 Tx                 |                            | SPI 1
PD6  | UART2 Rx                 |                            | SPI 1
PD7  | UART2 Ck                 |                            | SPI 1
PD8  | UART3 Tx                 | -> SD Card/Dataflash       | 
PD9  | UART3 Rx                 | <- SD Card/Dataflash       | 
PD10 | UART3 Ck                 | -> SD Card/Dataflash       | 
PD11 |                          | -> Dataflash (CS)          | 
PD12 | Timer 4.1                |                            | Encoder 4
PD13 | Timer 4.2                |                            | Encoder 4
PD14 | Timer 4.3                |                            |     - 
PD15 | Timer 4.4                |                            |     - 
---- | ------------------------ | -------------------------- | ----------------
PE0  |                          | -> FPGA (CCLK)             | 
PE1  |                          | -> FPGA (PROG_B)           | 
PE2  |                          | -> FPGA                    | 
PE3  |                          | -> LED0                    | 
PE4  |                          | -> LED1                    | 
PE5  | Timer 9.1                | -> LED2                    | 
PE6  | Timer 9.2                | -> LED3                    | 
PE7  |                          | <- FPGA (INIT_B)           | 
PE8  | Timer 1.1N               |                            | Motor 1
PE9  | Timer 1.1                |                            | Motor 1
PE10 | Timer 1.2N               |                            | Motor 2
PE11 | Timer 1.2                |                            | Motor 2
PE12 | Timer 1.3N               |                            |     - 
PE13 | Timer 1.3                |                            |     - 
PE14 | Timer 1.4                |                            |     - 
PE15 |                          |                            |     - 

#### Peripherals

- 2x Motor (Timer 1)
- 4x Encoder (Timer 3+4+5+8)

- 1x Upstream (Uart 1)
- 1x Debug (Uart 5)
- 2x SPI (Uart2+SPI2)
- 1x Peripheral UART (Uart 4)

#### SPI vs. SDIO

We choose a SPI over the SDIO interface for the SD Card because SDIO would
have blocked UART4 and UART5.

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

The Spartan-3 was choosen because it was the only FPGA from all the Spartan-3
Series (3,3E,3A,3AN) that is available in TQFP144 package from Reichelt or
Farnell.

The XC3S50A and XC3S50AN are also available, but the bigger packages are not.

### Pins

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

### Power Supply

http://focus.ti.com/analog/docs/refdesignovw.tsp?familyId=64&contentType=2&genContentId=34823

For the XC3S250E:
- 1.2V at 1A
- 2.5V at 0.15A
- 3.3V at 3A

For the XC3S500E
- 1.2V at 1.5A
- 2.5V at 0.15A
- 3.3V at 3A

The XC3S200/400 should be somewhere in between, the XC3S50 significantly lower.

### JTAG Connector

The JTAG connector is a stripped down version of the original connector from
the Xilinx Parallel Cable IV. Original it uses 14 pins, but we leave the last
four pins out to fit it to a standard 10 pin header. These pins are only used
for programming the FPGA via Slave Serial mode through the PC so no
functionality is lost.

           ------
    GND --| 1  2 |-- Vref (connect to Vaux)
    GND --| 3  4 |-- TMS
    GND -[| 5  6 |-- TCK
    GND --| 7  8 |-- TDO
    GND --| 9 10 |-- TDI
           ------


