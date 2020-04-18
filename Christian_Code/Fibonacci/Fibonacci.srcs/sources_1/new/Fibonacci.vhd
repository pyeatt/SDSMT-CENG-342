-- The Fibonnaci circuit.  Make sure the ready line is high, then
-- input the index of the Fibonacci number you want on the i bus and
-- pull the start line high for one clock cycle, then wait for it to
-- calculate the corresponding Fibonacci number. The done_tick signal
-- will go high for one clock cycle when the computation is done.
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fib is
  port(
    clk, reset : in std_logic;
    start      : in std_logic;
    i          : in std_logic_vector(4 downto 0);
    ready, done_tick : out std_logic;
    F                : out std_logic_vector(13 downto 0)
    );
end fib;

-- It is implemented as an FSMD.
architecture arch of fib is
  type state_t is (IDLE, OP, DONE);
  signal state, state_next : state_t;
  signal t0, t0_next, t1, t1_next: unsigned(13 downto 0);
  signal n, n_next: unsigned(4 downto 0);
begin
  -- FSMD state and data registers.  Everything is clocked together.
  process(clk,reset)
  begin
    if reset = '1' then
      state <= idle;
      t0    <= (others => '0');
      t1    <= (others => '0');
      n     <= (others => '0');
    elsif rising_edge(clk) then
      state <= state_next;
      t0    <= t0_next;
      t1    <= t1_next;
      n     <= n_next;
    end if;
  end process;
  
  -- Next state and datapath logic.  All mushed together.
  process(state,n,t0,t1,start,i,n_next)
  begin
    state_next <= state;    -- provide defaults
    t0_next <= t0;
    t1_next <= t1;
    n_next <= n;
    case state is
      when IDLE =>
        if start = '1' then
          t0_next <= (others => '0');
          t1_next <= (0=>'1', others => '0');
          n_next <= unsigned(i);
          state_next <= OP;
        end if;
      when OP =>
        if n = 0 then
          t1_next <= (others => '0');
          state_next <= DONE;
        elsif n = 1 then
          state_next <= DONE;
        else
          t1_next <= t1 + t0;
          t0_next <= t1;
          n_next <= n - 1;
        end if;
      when DONE => state_next <= IDLE;
    end case;
  end process;

  -- Output logic
  F <= std_logic_vector(t1);
  done_tick <= '1' when state = DONE else '0';
  ready <= '1' when state = IDLE else '0';

end architecture arch;
  
  -- Alternate next state and datapath logic. Easier to read and debug.
  
  -- state_next <= OP when state = IDLE and start = '1' else
  --               DONE when state = OP and n < 2 else
  --               IDLE when state = DONE else
  --               state;

  -- t0_next <= (others => '0') when state = IDLE and start = '1' else
  --            t1 when state = OP and n > 1 else
  --            t0;

  -- t1_next <= (0=>'1', others => '0') when state = IDLE and start = '1' else
  --            (others => '0') when state = OP and n = 0 else
  --            t1 + t0 when state = OP and n > 1 else
  --            t1;

  -- n_next <= unsigned(i) when state = IDLE and start = '1' else
  --           n - 1 when state = OP and n > 1 else
  --           n;

  
 
