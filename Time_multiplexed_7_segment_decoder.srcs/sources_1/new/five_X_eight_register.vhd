library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Register_File is
    generic(Bits: natural := 5;
            Log_Registers: natural := 3
            );
    port(Data_in: in std_logic_vector(Bits-1 downto 0);
         clk: in std_logic;
         reset: in std_logic;
         enable: in std_logic;
         Write: in std_logic;
         Write_Address, Read_Address: in std_logic_vector((Log_Registers)-1 downto 0);
         Data_out: out std_logic_vector(bits-1 downto 0)
         );
end Register_File;

architecture behavioral of Register_File is
    type reg_file is array((2**Log_Registers)-1 downto 0) of std_logic_vector(Bits-1 downto 0);
    signal registers: reg_file;
begin
    process(clk, reset, enable)
    begin
        if(reset='0') then
            registers <= (others=>(others=>'0'));
        else
            if (enable = '0' and clk'event and clk='1') then
                if Write = '0' then
                    registers(to_integer(unsigned(Write_Address))) <= Data_in;
                end if;
            end if;
         end if;
    end process;
    
    Data_out <= registers(to_integer(unsigned(Read_Address)));
end behavioral;