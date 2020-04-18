-- This file is used for testing the Fib entity.  It introduces a clk_wiz
-- device and a counter to slow down the clock so that you can see what is
-- happening on the board.  The testbench overrides the number of bits in the
-- counter so that you can run a simulation without waiting forever.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;


entity Fib_top is
  -- by default divide clock by 2^25 to give a slow clock so that you
  -- can see what the board is doing.  The testbench will override
  -- this value so that it does not take a long time to do a
  -- simulation, but implementation will not override it, so you can
  -- see what is happening on the board.
  generic(clk_div_bits: integer := 25);
  port(
    clk, reset : in std_logic;
    start      : in std_logic;
    i          : in std_logic_vector(4 downto 0);
    ready, done_tick : out std_logic;
    F                : out std_logic_vector(13 downto 0)
    );
end Fib_top;

architecture Behavioral of Fib_top is

  -- The clk_wiz is written in Verilog.  Creating a component allows
  -- the compiler to plug it in to our VHDL code.
  component clk_wiz_0 is
    port(
      clk_100 : out std_logic;
      clk_50  : out std_logic;
      resetn  : in std_logic;
      locked  : out std_logic;
      clk_in1 : in std_logic
      );
  end component;
  
  signal clk_100, clk_50, locked, ireset : std_logic;

  signal clk_div, clk_div_next: unsigned(clk_div_bits-1 downto 0);
  signal slow_clk : std_logic;
begin

  -- We use the clock wizard from the IP catalog to get a 50Mhz clock.
  clk_wiz : clk_wiz_0
    port map(
      clk_100 => clk_100,
      clk_50 => clk_50,
      resetn => reset,
      locked => locked,
      clk_in1 => clk
      );

  -- While the 50 MHz clock from the clock wizard is not locked, hold
  -- the rest of the system in reset.
  ireset <= not locked;

  -- This process will slow down the clock signal going to the fib
  -- entity. It is just a counter.  The number of bits in the counter
  -- is a generic, so the testbench can set it low, and the
  -- implementation will use the default value.
  process (clk_50,reset) 
  begin
    if reset = '0' then
      clk_div <= (others => '0');
    elsif rising_edge(clk_50) then
      clk_div <= clk_div_next;
    end if;
  end process;
  -- Next state logic for the counter
  clk_div_next <= clk_div + 1;

  -- The top bit of the clk_div counter is used as the clock to the
  -- fib entity.
  slow_clk <= clk_div(clk_div_bits - 1);  

  -- Instantiate a fibonacci circuit and give it a slow clock.
  fibnacci: entity work.fib (arch)
    port map(
      clk => slow_clk,
      reset => ireset,
      start => start,
      i => i,
      ready => ready,
      done_tick => done_tick,
      F => F
      );

end Behavioral;
