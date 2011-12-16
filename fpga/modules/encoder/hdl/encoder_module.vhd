-------------------------------------------------------------------------------
-- PWM Module
--
-- Connects the pwm entity to the internal bus system.
-- 
-- @author    Fabian Greif
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.bus_pkg.all;
use work.quadrature_decoder_pkg.all;
use work.up_down_counter_pkg.all;

-------------------------------------------------------------------------------
entity encoder_module is
  generic (
    BASE_ADDRESS : integer range 0 to 32767
    );
  port (
    a_p     : in std_logic;
    b_p     : in std_logic;
    index_p : in std_logic;             -- index can be used to reset the
                                        -- counter, set to '0' if not used
    load_p  : in std_logic;             -- Save the current encoder value in a
                                        -- buffer register

    bus_o : out busdevice_out_type;
    bus_i : in  busdevice_in_type;

    reset : in std_logic;
    clk   : in std_logic
    );
end encoder_module;

-------------------------------------------------------------------------------
architecture behavioral of encoder_module is

  type encoder_module_state_type is (IDLE);

  type encoder_module_type is record
    state    : encoder_module_state_type;
--    pwm   : std_logic_vector (WIDTH - 1 downto 0);
    counter  : std_logic_vector(15 downto 0);
    data_out : std_logic_vector(15 downto 0);
  end record;

  signal r, rin : encoder_module_type;

  signal step         : std_logic := '0';
  signal up_down      : std_logic := '0';  -- Direction for the counter ('1' = up, '0' = down)
  signal decode_error : std_logic;  -- Decoding Error (A and B lines changes at the same time), current not used
  signal counter      : std_logic_vector(15 downto 0);
begin

  seq_proc : process(reset, clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        r.state    <= IDLE;
        r.data_out <= (others => '0');
        r.counter  <= (others => '0');
      else
        r <= rin;
      end if;
    end if;
  end process seq_proc;

  comb_proc : process(bus_i, counter, load_p, r)
    variable v : encoder_module_type;
  begin
    v := r;

    v.data_out := (others => '0');

    case v.state is
      when IDLE =>
        -- Load counter into own buffer
        if load_p = '1' then
          v.counter := counter;
        end if;

        -- Check Bus Address
        if bus_i.addr = std_logic_vector(to_unsigned(BASE_ADDRESS, 15)) then
          if bus_i.we = '1' then
            -- TODO
          elsif bus_i.re = '1' then
            v.data_out := r.counter;
          end if;
        end if;
        
    end case;

    rin <= v;
  end process comb_proc;

  bus_o.data <= r.data_out;

  decoder : quadrature_decoder
    port map (
      a_p     => a_p,
      b_p     => b_p,
      step_p  => step,
      dir_p   => up_down,
      error_p => decode_error,
      clk     => clk);

  up_down_counter_1 : up_down_counter
    generic map (
      WIDTH => 16)
    port map (
      clk_en_p  => step,
      up_down_p => up_down,
      value_p   => counter,
      reset     => reset,
      clk       => clk);
end behavioral;
