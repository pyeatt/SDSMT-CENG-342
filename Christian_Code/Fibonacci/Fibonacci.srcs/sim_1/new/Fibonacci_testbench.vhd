library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Fibonacci_testbench is
end Fibonacci_testbench;

architecture Behavioral of Fibonacci_testbench is
  signal i: std_logic_vector(4 downto 0);
  signal f: std_logic_vector(13 downto 0);
  signal clk, start, ready, done, reset: std_logic := '0';
begin
  -- The following line gives us a clock signal at 50 Mhz.
  clk <= not clk after 10 ns;

  -- Instantiate a fibonacci circuit, with a clock wizard.  Tell it to divide
  -- the 50 MHz clock with a 2-bit counter.  This is much better for
  -- simulation than using the default 25-bit counter.
  uut: entity work.Fib_top(Behavioral)
    generic map(clk_div_bits => 2) -- for simulation, we use 2
    port map( i => i, F=> f, reset => reset,
              clk => clk, start => start,
              ready => ready, done_tick => done);

  test: process
  begin
    start <= '0';
    reset <= '0';
    wait for 85 ns;  -- hold reset low long enough.
    reset <= '1';
    wait for 1 us;   -- give time for the clock wizart to stabilize clocks
    i <= "00111";    -- give a command to do fib(7)
    if ready = '0' then  -- wait until fib circuit is ready
      wait until ready = '1';
    end if;
    start <= '1';
    wait for 150 ns;  -- give a long enough start signal
    start <= '0';
    wait until done = '1';  
    wait;
  end process;
end Behavioral;
