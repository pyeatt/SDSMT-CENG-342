--Author: Clayton Heeren
--Date: March 25, 2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Generic_Register_testbench is
end Generic_Register_testbench;

architecture Behavioral of Generic_Register_testbench is
    constant bits: natural := 5;
    signal Data_in, Data_out: std_logic_vector(bits-1 downto 0);
    signal load_enable: std_logic := '1';
    signal clk, reset: std_logic := '0';
begin
    UUT: entity work.generic_register(behavioral)
         Generic Map(bits=>bits)
         Port Map(clk=>clk, reset=>reset, enable=>Load_enable,
                  data_in=>data_in, data_out=>data_out);
    --initialize
    process
    begin
        wait for 10ns;
        reset <= '1';
        wait;
    end process;
    
    process
    begin
        wait for 5ns;
        clk <= not clk;
        loop
            wait for 10ns;
            clk <= not clk;
        end loop;
    end process;
    
    --test
    process
    variable I: integer;
    begin
        wait for 20ns;
        loop
            for I in 0 to (2**bits)-1 loop
                load_enable <= '0';
                Data_in <= std_logic_vector(to_unsigned(I,bits));
                wait for 20ns;
            end loop;
        end loop;
    end process;
    
end Behavioral;
