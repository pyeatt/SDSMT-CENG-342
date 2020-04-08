----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/07/2020
-- Lab 9
-- Design Name: LPU_BTU_TB
-- Project Name: Lab9
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity LPU_BTU_TB is
end LPU_BTU_TB;

architecture tb_arch of LPU_BTU_TB is
    signal condition: std_logic_vector(3 downto 0); -- this is the condition code
    signal N: std_logic; -- this is the negative flag
    signal Z: std_logic; -- this is the zero flag
    signal Co: std_logic; -- this is the carry-out flag
    signal V: std_logic; -- this is the overflow flag
    signal branch: std_logic; -- this flag determines if a branch should be taken
    --signal counter: unsigned(7 downto 0) := (others => '0'); -- keeps track of the minterm value
    signal counter: integer := 0; -- keeps track of the minterm value
    signal correctValues: std_logic_vector(0 to 255) := "1111111111111111000000001111111111111111000000000000111100001111111100001111000000110011001100111100110011001100010101010101010110101010101010100101010110101010101000000101000001011111101011111010101001010101001100000011000011111100111111000000000000000000";
    signal isCorrect: std_logic := '0';
    signal temp: std_logic := '0';
begin

    BTU:
        entity work.LPU_BTU(behavioral)
        port map(
            condition => condition,
            N => N,
            Z => Z,
            Co => Co,
            V => V,
            branch => branch
            );
    
    test: process
        variable i: integer := 0;
    begin
        for i in 0 to 2**8-1 loop
            condition <= std_logic_vector(to_unsigned(i,8)(7 downto 4));
            N <= std_logic(to_unsigned(i,8)(3));
            Z <= std_logic(to_unsigned(i,8)(2));
            Co <= std_logic(to_unsigned(i,8)(1));
            V <= std_logic(to_unsigned(i,8)(0));
            temp <= correctValues(i);
            wait for 1 ns;
            if branch = temp then
                isCorrect <= '1';
            else
                isCorrect <= '0';
            end if;
            wait for 9 ns;
            counter <= counter + 1;
        end loop;
    end process test;
    


end tb_arch;
