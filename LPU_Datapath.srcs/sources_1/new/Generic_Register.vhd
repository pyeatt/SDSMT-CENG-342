--Author: Clayton Heeren
--Date: March 25, 2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Generic_Register is
    Generic(Bits: natural := 2);
    Port ( clk: in std_logic;
           reset: in std_logic;
           enable: in std_logic;
           data_in: in std_logic_vector(bits-1 downto 0);
           data_out: out std_logic_vector(bits-1 downto 0)
           );
end Generic_Register;

architecture Behavioral of Generic_Register is
begin
    process(clk)
    begin
        if (clk'event and clk='1') then
            if(reset='0') then
                data_out <= (others=>'0');
            elsif (enable = '0') then
                data_out <= data_in;
            end if;
        end if;
    end process;
end Behavioral;
