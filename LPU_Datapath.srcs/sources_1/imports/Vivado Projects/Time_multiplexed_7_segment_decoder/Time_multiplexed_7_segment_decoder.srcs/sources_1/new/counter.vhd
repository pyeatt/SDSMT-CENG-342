--Author: Clayton Heeren
--Date: March 27, 2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_Counter is
    Generic(Bits: natural := 3);
    Port( Reset: in std_logic;
          clk: in std_logic;
          count: out std_logic_vector(Bits-1 downto 0);
          PC_in: in std_logic_vector(bits-2 downto 0);
          PC_le: in std_logic;
          PC_ie: in std_logic
          );
end PC_Counter;

Architecture Arch of PC_Counter is
    signal data: unsigned(Bits-2 downto 0);
Begin
    process(clk)
    begin
        if (clk'event and clk = '1') then
            if (Reset = '0') then --synchronous reset
                data <= (others => '0');
            elsif (PC_le = '0') then --load PC
                data <= unsigned(PC_in);
            elsif (PC_ie = '0') then --increment PC
                data <= data + 1;    
            end if;
        end if;
    end process;
    
    count <= std_logic_vector(data) & '0';
    
end arch;