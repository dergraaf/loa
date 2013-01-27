-------------------------------------------------------------------------------
-- Title      : Testbench for Ultrasonic Transmitters
-------------------------------------------------------------------------------
-- Author     : strongly-typed
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2012 
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.motor_control_pkg.all;

-------------------------------------------------------------------------------

entity uss_tx_module_tb is

end uss_tx_module_tb;

-------------------------------------------------------------------------------

architecture tb of uss_tx_module_tb is

  use work.uss_tx_pkg.all;
  use work.reg_file_pkg.all;
  use work.bus_pkg.all;

  -- Component generics
  constant BASE_ADDRESS : integer := 16#0000#;

  -- Signals for component ports
  signal uss_tx0_out_s : half_bridge_type;
  signal uss_tx1_out_s : half_bridge_type;
  signal uss_tx2_out_s : half_bridge_type;

  signal clk_uss_enable_p : std_logic;
  signal modulation_p     : std_logic_vector(2 downto 0) := "111";

  signal bus_o : busdevice_out_type;
  signal bus_i : busdevice_in_type;

  signal clk : std_logic := '0';

begin  -- tb


  ---------------------------------------------------------------------------
  -- component instatiation
  ---------------------------------------------------------------------------

  uss_tx_module_1 : uss_tx_module
    generic map (
      BASE_ADDRESS => BASE_ADDRESS)
    port map (
      uss_tx0_out_p => uss_tx0_out_s,
      uss_tx1_out_p => uss_tx1_out_s,
      uss_tx2_out_p => uss_tx2_out_s,

      modulation_p     => modulation_p,
      clk_uss_enable_p => clk_uss_enable_p,

      bus_o => bus_o,
      bus_i => bus_i,

      clk => clk);

  -------------------------------------------------------------------------------
  -- Stimuli
  -------------------------------------------------------------------------------

  -- clock generation, 50 MHz
  clk <= not clk after 10 ns;

  -- bus stimulus
  bus_stimulus_proc : process
  begin
    bus_i.addr <= (others => '0');
    bus_i.data <= (others => '0');
    bus_i.re   <= '0';
    bus_i.we   <= '0';

    wait until clk = '1';

    -- write 0x0000 (MUL) to 0x00
    wait until clk = '1';
    bus_i.addr <= (others => '0');
    bus_i.data <= x"0001";
    bus_i.re   <= '0';
    bus_i.we   <= '1';

    wait until clk = '1';
    bus_i.we <= '0';

    wait until clk = '1';
    wait until clk = '1';

    -- write 0x05f4 (DIV) to 0x01
    wait until clk = '1';
    bus_i.addr(0) <= '1';
    bus_i.data    <= x"0400";
    bus_i.re      <= '0';
    bus_i.we      <= '1';

    wait until clk = '1';
    bus_i.data <= (others => '0');
    bus_i.we   <= '0';

    wait for 200 us;

    -- decrease frequency by writing 0x0500 to 0x01
    wait until clk = '1';
    bus_i.addr(0) <= '1';
    bus_i.data    <= x"0500";
    bus_i.re      <= '0';
    bus_i.we      <= '1';

    wait until clk = '1';
    bus_i.data <= (others => '0');
    bus_i.we   <= '0';

    wait for 10 ms;

  end process bus_stimulus_proc;
  
end tb;
