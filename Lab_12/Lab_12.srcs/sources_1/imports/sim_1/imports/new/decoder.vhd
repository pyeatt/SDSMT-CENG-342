library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Modified code from pyeatts slides on 7seg part 2
entity decoder is
    generic (Bits: integer := 3);
    port(
            Enable: in std_logic;
            sel: in std_logic_vector(Bits - 1 downto 0);
            output: out std_logic_vector(2**Bits-1 downto 0)
        );
end decoder;

architecture Behavioral of decoder is
 
begin
    process(Enable,sel)
        variable pass_thru: natural;
        begin 
            if Enable = '1' then 
                output <= (others => '1');
            else 
                output <= (others => '1');
                pass_thru := to_integer(unsigned(sel));
                output(pass_thru) <= '0';
            end if;
    end process;        
end Behavioral;
