
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity toplevel is
  port (
    cs_np   : in  std_logic;
	sck_p   : in  std_logic;
	miso_p  : out std_logic;
	mosi_p  : in  std_logic;
	
	load_p  : in  std_logic;	-- On the rising edge encoders etc are sampled
	
    led_np  : out std_logic_vector (3 downto 0);
    sw_np   : in  std_logic_vector (1 downto 0);
    
	reset_n : in  std_logic;
	clk     : in  std_logic
	);
end toplevel;

architecture behavioral of toplevel is
  signal reset_sync : std_logic_vector(1 downto 0) := (others => '0');
  signal reset      : std_logic;

  signal led : std_logic_vector(3 downto 0);
  signal cnt : integer;
begin
  -- synchronize reset
  process (clk)
  begin
    if rising_edge(clk) then
      reset_sync <= reset_sync(0) & reset_n;
    end if;
  end process;

  reset <= not reset_sync(1);
  
  -- blinking led
  process
  begin
    wait until rising_edge(clk);
    if reset = '1' then
      led <= "0010";
      cnt <= 0;
    else
      -- 0...24999999 = 25000000 Takte = 1/2 Sekunde bei 50MHz 
      if cnt < (24999999 - 1) then
        cnt <= cnt + 1;
      else
        cnt    <= 0;
        led(0) <= not led(0);
        led(1) <= not led(1);
      end if;
    end if;
  end process;

  led_np <= not led;
  miso_p <= 'Z';
  
end behavioral;
