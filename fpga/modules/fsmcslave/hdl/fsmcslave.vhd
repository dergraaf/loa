-------------------------------------------------------------------------------
-- Title      : FSMC Slave, synchronous
-------------------------------------------------------------------------------
-- Author     :
-------------------------------------------------------------------------------
-- Description: This is slave to the flexible static memory controller (FSMC)
--              of a STM32 device. The slave is a busmaster to the local bus.
--              Data can be transferred to and from the bus slaves on the bus.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2013
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library work;
use work.fsmcslave_pkg.all;
use work.bus_pkg.all;

-------------------------------------------------------------------------------
entity fsmcslave is
   port (
      fsmc_o  : out fsmcslave_out_type;
      fsmc_i  : in  fsmcslave_in_type;
      fsmc_oe : out std_logic;
      --
      bus_o   : out busmaster_out_type;
      bus_i   : in  busmaster_in_type;
      --
      clk : in std_logic
      );
end fsmcslave;

-------------------------------------------------------------------------------
architecture behavioral of fsmcslave is

   type fsmcslave_state is (
      ST_IDLE, ST_SAVE_ADDRESS1, ST_SAVE_ADDRESS2, ST_WAIT_FOR_DATA,
      ST_SAVE_DATA1, ST_SAVE_DATA2, ST_READ_BUS, ST_WRITE_DATA);

   type fsmcslave_state_type is record
      adv_n : std_logic_vector(1 downto 0);
      cs_n  : std_logic_vector(1 downto 0);
      oe_n  : std_logic_vector(1 downto 0);
      we_n  : std_logic_vector(1 downto 0);
      state : fsmcslave_state;
   end record;

   signal r, rin : fsmcslave_state_type := (
      adv_n     => (others => '0'),
      cs_n      => (others => '0'),
      oe_n      => (others => '0'),
      we_n      => (others => '0'),
      state     => ST_IDLE);

   -- internal signals that are used for fsm transitions
   signal ReadAddressxS : std_logic;
   signal ReadDataxS    : std_logic;
   signal WriteDataxS   : std_logic;

   -- signal controlled by fsm that indicates that data should be written to
   -- the bus
   signal WriteNotReadDataxS : std_logic;

   -- Address Register with Write Enable
   signal AddressxDP  : std_logic_vector(15 downto 0) := (others => '0');
   signal AddressxDN  : std_logic_vector(15 downto 0) := (others => '0');
   signal AddressWexS : std_logic := '0';
   -- Data Input (from FSMC) Register with Write Enable
   signal DataInpxDP  : std_logic_vector(15 downto 0) := (others => '0');
   signal DataInpxDN  : std_logic_vector(15 downto 0) := (others => '0');
   signal DataInpWexS : std_logic := '0';
   -- Data Output (to FSMC) Register with Write Enable
   signal DataOutxDP  : std_logic_vector(15 downto 0) := (others => '0');
   signal DataOutxDN  : std_logic_vector(15 downto 0) := (others => '0');
   signal DataOutWexS : std_logic := '0';

begin

   ----------------------------------------------------------------------------
   -- Internal Signals
   ----------------------------------------------------------------------------

   -- if an address is put onto the ad lines by the master, n_adv and n_cs
   -- are low, n_oe and n_we are high (see STM32F4 Reference Manual page 1340)
   ReadAddressxS <= not r.adv_n(1) and
                    not r.cs_n(1)  and
                    r.oe_n(1)      and
                    r.we_n(1);

   -- if an data is put onto the ad lines by the master, n_cs and n_we
   -- are low, n_adv and n_oe are high (see STM32F4 Reference Manual page 1341)
   -- TODO: should ADDHLD be 0 for this to work??
   ReadDataxS    <=     r.adv_n(1) and
                    not r.cs_n(1)  and
                        r.oe_n(1)  and
                    not r.we_n(1);

   -- if an data is expected from the client on the ad lines, n_cs and n_oe
   -- are low, n_adv and n_we are high (see STM32F4 Reference Manual page 1341)
   WriteDataxS   <=     r.adv_n(1) and
                    not r.cs_n(1)  and
                    not r.oe_n(1)  and
                        r.we_n(1);


   ----------------------------------------------------------------------------
   -- FSM
   ----------------------------------------------------------------------------
   p_comb: process (fsmc_i.adv_n, fsmc_i.cs_n, fsmc_i.oe_n, fsmc_i.we_n, r,
                    ReadAddressxS, ReadDataxS, WriteDataxS) is
      variable v : fsmcslave_state_type;
      variable save_address     : std_logic;
      variable save_data_from_fsmc : std_logic;
      variable save_data_from_bus  : std_logic;
      variable output_data      : std_logic;
      variable read_internal_bus  : std_logic;
      variable write_internal_bus : std_logic;
   begin  -- process p_comb
      v := r;
      save_address        := '0';
      save_data_from_fsmc := '0';
      save_data_from_bus  := '0';
      output_data         := '0';
      read_internal_bus   := '0';
      write_internal_bus  := '0';
      --
      -------------------------------------------------------------------------
      -- Input Shift Registers for Synchronization
      -------------------------------------------------------------------------
      v.adv_n := v.adv_n(0) & fsmc_i.adv_n;
      v.cs_n  := v.cs_n(0)  & fsmc_i.cs_n;
      v.oe_n  := v.oe_n(0)  & fsmc_i.oe_n;
      v.we_n  := v.we_n(0)  & fsmc_i.we_n;

      -------------------------------------------------------------------------
      -- FSM Transitions and Outputs
      -------------------------------------------------------------------------
      case r.state is
         -- In IDLE state we wait for n_adv and n_cs to go low which indicates
         -- a valid address and the beginning of a transaction
         when  ST_IDLE =>
            if ReadAddressxS = '1' then
               save_address := '1';
               v.state := ST_SAVE_ADDRESS1;
            end if;
         -- while the address is sampled immediately, the scalar signals are
         -- subject to a delay of 1-2 clock cycles. Therefore we check if the
         -- write_address pin configuration is valid for at least another two
         -- cycles
         when ST_SAVE_ADDRESS1 =>
            if ReadAddressxS = '1' then  -- check if still read address
               v.state := ST_SAVE_ADDRESS2;
            else                        -- else discard address
               v.state := ST_IDLE;
            end if;
         when ST_SAVE_ADDRESS2 =>
            if ReadAddressxS = '1' then  -- check if still read address
               v.state := ST_WAIT_FOR_DATA;
            else                        -- else discard address
               v.state := ST_IDLE;
            end if;
         -- now that we have successfully sampled the address we wait to see if
         -- a read or write transaction was requested. If we have problems with
         -- undefined behavior of the fsmc master or run into deadlocks, we
         -- could add a timeout here.
         when ST_WAIT_FOR_DATA =>
            v.state := ST_IDLE;         -- escape if invalid pin configuration
            if ReadAddressxS = '1' then
               v.state := ST_WAIT_FOR_DATA;  -- stay in state waiting
            end if;
            if ReadDataxS = '1' then
               -- we got the correct address and apparently the master wants to
               -- send us data. So let's saple that data.
               save_data_from_fsmc := '1';          -- sample data
               v.state := ST_SAVE_DATA1;  -- check if data still valid
            end if;
            if WriteDataxS = '1' then
               -- we got the correct address and apparently the master requests
               -- data from that location, so let's start a read operation.
               read_internal_bus := '1';
               v.state := ST_READ_BUS;
            end if;
         ----------------------------------------------------------------------
         -- FSMC Master Write Transaction => Slave needs to "SAVE_DATA"
         ----------------------------------------------------------------------
         -- check if the data was valid when it was samples
         -- this is to counter the effect of the two syncronization registers
         -- (see above)
         when ST_SAVE_DATA1 =>
            if ReadDataxS = '1' then    -- check if still read data
               v.state := ST_SAVE_DATA2;
            else                        -- else discard data and address
               v.state := ST_IDLE;
            end if;
         when ST_SAVE_DATA2 =>
            if ReadDataxS = '1' then    -- check if still read data
               -- now that we have a valid address and data, let's put it on
               -- the internal bus
               write_internal_bus := '1';
            end if;
            v.state := ST_IDLE;
         ----------------------------------------------------------------------
         -- FSMC Master Read Transaction => Slave needs to "WRITE_DATA"
         ----------------------------------------------------------------------
         -- save data from bus to output register
         when ST_READ_BUS =>
            save_data_from_bus := '1';
            v.state := ST_WRITE_DATA;
         -- now correct data from internal bus should be on the ad output line
         -- thus we can enable the output
         when ST_WRITE_DATA =>
            if WriteDataxS = '1' then   -- if we are still supposed to write data
               output_data := '1';
            else
               v.state := ST_IDLE;
            end if;
         when others => null;
      end case;
      --
      rin <= v;
      AddressWexS <= save_address;
      DataInpWexS <= save_data_from_fsmc;
      DataOutWexS <= save_data_from_bus;
      WriteNotReadDataxS <= output_data;
      bus_o.re <= read_internal_bus;
      bus_o.we <= write_internal_bus;
   end process p_comb;

   ----------------------------------------------------------------------------
   -- Registers
   ----------------------------------------------------------------------------
   p_sync_address_data_reg: process (clk) is
   begin  -- process p_sync_address_data_reg
      if clk'event and clk = '1' then  -- rising clock edge
         r <= rin;
         if AddressWexS = '1' then
            AddressxDP <= AddressxDN;
         end if;
         if DataInpWexS = '1' then
            DataInpxDP <= DataInpxDN;
         end if;
         if DataOutWexS = '1' then
            DataOutxDP <= DataOutxDN;
         end if;
      end if;
   end process p_sync_address_data_reg;

   ----------------------------------------------------------------------------
   -- Outputs/Inputs
   ----------------------------------------------------------------------------
   -- TODO: fsmc_i.oe_n is NOT synchronized! Is this a problem?
   --       Using the synchronized signal would result in up to
   --       2 clock cycles delay which would limit the usefullness
   --       of this safety mechanism
   fsmc_oe <= not fsmc_i.oe_n and not fsmc_i.cs_n and WriteNotReadDataxS;

   -- Connect Address, DataInp/DataOut Registers between FSMC and internal bus
   AddressxDN <= fsmc_i.ad;
   bus_o.addr <= AddressxDP(14 downto 0);            -- address from FSMC bus
   DataInpxDN <= fsmc_i.ad;
   bus_o.data <= DataInpxDP;            -- data from FSMC bus
   DataOutxDN <= bus_i.data;
   fsmc_o.ad <= DataOutxDP;


end behavioral;
