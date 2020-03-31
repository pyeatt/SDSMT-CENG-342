----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/31/2020
-- Lab 7
-- Design Name: hexTo7Seg_testbench
-- Project Name: Lab7
----------------------------------------------------------------------------------
-- test time: 6400ns


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- entity declaration for testbench
entity hexTo7Seg_testbench is
end hexTo7Seg_testbench;


-- this tests all three implementations of hex_to_7seg
architecture tb_arch of hexTo7Seg_testbench is
    signal input_hex : STD_LOGIC_VECTOR (3 downto 0);
    signal input_dp : STD_LOGIC;
    signal output_sop_sseg : STD_LOGIC_VECTOR (6 downto 0);
    signal output_sop_dpo : STD_LOGIC;
    signal output_conditional_sseg : STD_LOGIC_VECTOR (6 downto 0);
    signal output_conditional_dpo : STD_LOGIC;
    signal output_select_sseg : STD_LOGIC_VECTOR (6 downto 0);
    signal output_select_dpo : STD_LOGIC;
begin

    sop_uut: entity work.hexTo7Seg(sop_arch)
    port map(
        hex => input_hex,
        dp => input_dp,
        sseg => output_sop_sseg,
        dpo => output_sop_dpo
        );
             
    conditional_uut: entity work.hexTo7Seg(conditional_arch)
    port map(
        hex => input_hex,
        dp => input_dp, 
        sseg => output_conditional_sseg,
        dpo => output_conditional_dpo
        );
             
    select_uut: entity work.hexTo7Seg(select_arch)
    port map(
        hex => input_hex,
        dp => input_dp, 
        sseg => output_select_sseg,
        dpo => output_select_dpo
        );
        
test: process
    variable I: integer;
    variable temp: STD_LOGIC_VECTOR (4 downto 0);
begin
    for I in 0 to 31 loop    
        temp := std_logic_vector(to_unsigned(I,5));
        input_hex <= temp(3 downto 0);
        input_dp <= temp(4);
        wait for 200 ns;
    end loop;

end process;

end tb_arch;
