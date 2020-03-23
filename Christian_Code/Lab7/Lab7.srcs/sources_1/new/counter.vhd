library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_counter is
    generic(bits:integer:=4);
    port( clk: in std_logic;
          rst: in std_logic; -- asynch reset (active low)
          q: out std_logic_vector(bits-1 downto 0));
end generic_counter;

architecture arch of generic_counter is
    signal data:unsigned(bits-1 downto 0);
begin
    process(clk,rst)
    begin
        if rst = '0' then
            data <= (others => '0');
        else
            if clk'event and clk = '1' then
                data <= data + 1;
            end if;
        end if;
    end process;
    
    q <= std_logic_vector(data);
    
end arch;