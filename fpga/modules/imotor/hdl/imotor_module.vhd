-------------------------------------------------------------------------------
-- Title      : iMotor Module
-------------------------------------------------------------------------------
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: iMotor Module shares the same interface as a motor controller.
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
      BASE_ADDRESS   : integer range 0 to 32767;
      MOTORS         : positive := 8;
      CLOCK          : positive := 50E6;
      BAUD           : positive := 1E6;
      SEND_FREQUENCY : positive := 1E3
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
   constant WORDS_SEND : positive := 2;  -- Number of words transmitted to each iMotor
   constant WORDS_READ : positive := 2;  -- Number of words received from each iMotor

   constant WORDS : positive := MAX(WORDS_SEND, WORDS_READ);
   
   constant REG_ADDR_BIT : natural := required_bits(MOTORS * WORDS);


   -----------------------------------------------------------------------------
   -- Internal signal declarations
   -----------------------------------------------------------------------------
   signal clock_s : imotor_timer_type;

   -- Data to and from the internal data bus
   -- in = from the bus
   -- out = to the bus
   -- Each motor has WORDS_* registers
   signal reg_data_in  : reg_file_type(2**REG_ADDR_BIT - 1 downto 0) := (others => (others => '0'));
   signal reg_data_out : reg_file_type(2**REG_ADDR_BIT - 1 downto 0) := (others => (others => '0'));

   -- Data to and from each iMotor
   type imotor_inputs_type is array (MOTORS-1 downto 0) of imotor_input_type(WORDS_SEND-1 downto 0);
   type imotor_outputs_type is array (MOTORS-1 downto 0) of imotor_output_type(WORDS_READ-1 downto 0);
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
            DATA_WORDS => 2,
            DATA_WIDTH => 16)
         port map (
            data_in_p  => imotor_datas_in(imotor_idx),
            data_out_p => imotor_datas_out(imotor_idx),
            tx_out_p   => tx_out_p(imotor_idx),
            rx_in_p    => rx_in_p(imotor_idx),
            timer_in_p => clock_s,
            clk        => clk);
   end generate imotor_transceivers;

   -- Connect signals of transceivers to bus registers
   imotor_conn: for register_idx in (MOTORS * WORDS_SEND) - 1 downto 0 generate
      imotor_datas_in(register_idx / 2)(register_idx mod 2) <= reg_data_in(register_idx);
   end generate imotor_conn;

end behavioural;
