library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity D_Flip_Flop is
    Port ( D: in std_logic;
           Q: out std_logic;
           clk: in std_logic;
           enable: in std_logic;
           reset: in std_logic
           );
end D_Flip_Flop;

architecture Behavioral of D_Flip_Flop is
    signal D_sig: std_logic;
    signal Q_sig: std_logic;
begin
    --next state
    with enable select --active low
        D_sig <= D when '0',
                 Q_sig when others;
    
    --the register     
    process(clk, reset)
    begin --reset active low
        if(reset = '0') then
            Q_sig <= '0';
        elsif (clk'event and clk = '1') then
            Q_sig <= D_sig;
        end if;
    end process;
    
    --output
    Q <= Q_sig;
end Behavioral;
