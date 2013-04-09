-------------------------------------------------------------------------------
-- Title      : iMotor Module
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: The iMotor Module communicates to a number of iMotor modules by
--              multiple high speed UART links. 
--
-- Beginning with the base address this module provides read and write access
-- to the iMotors. The address space is linearily filled. The chunk size is
-- defined by WORDS_SEND and WORDS_READ. 
-- 
-- For write access:
--      iMotor module shares the same interface as a motor controller.
--
-- For read access:
--      TBD
--
-- Offset | R/W | Description
--    +0  | W   | iMotor 0 PWM
--    +1  | W   | iMotor 0 Current Limit
--    +2  | W   | iMotor 1 PWM
--    +3  | W   | iMotor 1 Current Limit
--    +4  | W   | iMotor 2 PWM
--    +5  | W   | iMotor 2 Current Limit
--     .
--     .
-- 
--    +0  | R   | iMotor 0 Encoder
--    +1  | R   | iMotor 0 Current
--    +2  | R   | iMotor 0 Status
--    +3  | R   | iMotor 1 Encoder
--    +4  | R   | iMotor 1 Current
--    +5  | R   | iMotor 1 Status
--     .
--     .
-- 
-------------------------------------------------------------------------------
-- Copyright (c) 2013 strongly-typed
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.utils_pkg.all;
use work.bus_pkg.all;
use work.reg_file_pkg.all;
use work.imotor_module_pkg.all;

-------------------------------------------------------------------------------

entity imotor_module is

   generic (
      BASE_ADDRESS    : integer range 0 to 32767;
      MOTORS          : positive := 8;  -- Number of motors controlled by this
      -- module
      DATA_WORDS_SEND : positive;       -- Number of words transmitted to each
                                        -- iMotor
      DATA_WORDS_READ : positive;  -- Number of words received from each iMotor
      CLOCK           : positive := 50E6;  -- Clock frequency of clk, for baud
      -- rate calculation
      BAUD            : positive := 1E6;   -- Baud rate of the communication
      SEND_FREQUENCY  : positive := 1E3  -- Frequency of update cycle to iMotors
      );
   port (
      tx_out_p : out std_logic_vector(MOTORS - 1 downto 0);
      rx_in_p  : in  std_logic_vector(MOTORS - 1 downto 0);

      bus_o : out busdevice_out_type;
      bus_i : in  busdevice_in_type;

      clk : in std_logic
      );

end imotor_module;

-------------------------------------------------------------------------------

architecture behavioural of imotor_module is

   ----------------------------------------------------------------------------
   -- Module constants
   -----------------------------------------------------------------------------

   -- Each word is 16 bit wide. Corresponds to the data bus width. 
   constant DATA_WORDS : positive := MAX(DATA_WORDS_SEND, DATA_WORDS_READ);

   constant REG_ADDR_BIT : natural := required_bits(MOTORS * DATA_WORDS);


   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal clock_s : imotor_timer_type;

   -- Data to and from the internal data bus
   -- in = from the bus
   -- out = to the bus
   -- Each motor has DATA_WORDS_* registers
   signal reg_data_in  : reg_file_type(2**REG_ADDR_BIT - 1 downto 0) := (others => (others => '0'));
   signal reg_data_out : reg_file_type(2**REG_ADDR_BIT - 1 downto 0) := (others => (others => '0'));

   -- Data to and from each iMotor
   type imotor_inputs_type is array (MOTORS-1 downto 0) of imotor_input_type(DATA_WORDS_SEND-1 downto 0);
   type imotor_outputs_type is array (MOTORS-1 downto 0) of imotor_output_type(DATA_WORDS_READ-1 downto 0);
   signal imotor_datas_in  : imotor_inputs_type;
   signal imotor_datas_out : imotor_outputs_type;

   -----------------------------------------------------------------------------
   -- Component declarations
   -----------------------------------------------------------------------------
   -- None here. If any: in package

begin  -- architecture behavourial

   ----------------------------------------------------------------------------
   -- Connections between ports and signals
   ----------------------------------------------------------------------------

   -----------------------------------------------------------------------------
   -- Component instantiations
   -----------------------------------------------------------------------------
   reg_file_1 : entity work.reg_file
      generic map (
         BASE_ADDRESS => BASE_ADDRESS,
         REG_ADDR_BIT => REG_ADDR_BIT)
      port map (
         bus_o => bus_o,
         bus_i => bus_i,
         reg_o => reg_data_in,
         reg_i => reg_data_out,
         clk   => clk);

   imotor_timer_1 : entity work.imotor_timer
      generic map (
         CLOCK          => CLOCK,
         BAUD           => BAUD,
         SEND_FREQUENCY => SEND_FREQUENCY)
      port map (
         clock_out_p => clock_s,
         clk         => clk);

   -- Instantiate all transceivers
   imotor_transceivers : for imotor_idx in MOTORS-1 downto 0 generate
      imotor_transceiver : entity work.imotor_transceiver
         generic map (
            DATA_WORDS_SEND => DATA_WORDS_SEND,
            DATA_WORDS_READ => DATA_WORDS_READ,
            DATA_WIDTH      => 16)
         port map (
            data_in_p  => imotor_datas_in(imotor_idx),
            data_out_p => imotor_datas_out(imotor_idx),
            tx_out_p   => tx_out_p(imotor_idx),
            rx_in_p    => rx_in_p(imotor_idx),
            timer_in_p => clock_s,
            clk        => clk);
   end generate imotor_transceivers;

   -- Connect signals of transceivers to bus registers
   -- From bus to iMotors
   imotor_conn_1 : for register_idx in (MOTORS * DATA_WORDS_SEND) - 1 downto 0 generate
      imotor_datas_in(register_idx / DATA_WORDS_SEND)(register_idx mod DATA_WORDS_SEND) <= reg_data_in(register_idx);
   end generate imotor_conn_1;

   imotor_conn_2 : for register_idx in (MOTORS * DATA_WORDS_READ) - 1 downto 0 generate
      reg_data_out(register_idx) <= imotor_datas_out(register_idx / DATA_WORDS_READ)(register_idx mod DATA_WORDS_READ);
   end generate imotor_conn_2;
end behavioural;
