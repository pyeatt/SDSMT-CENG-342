----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 02/05/2020
-- Lab 2 
-- Design Name: hex_to_7seg_testbench - tb_arch
-- Project Name: Lab2
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.sseg_bus_type.all;

entity hex_to_7seg_testbench is
end hex_to_7seg_testbench;


-- this tests all three implementations of hex_to_7seg
architecture tb_arch of hex_to_7seg_testbench is
    signal input_hex : STD_LOGIC_VECTOR (3 downto 0);
    signal input_dp : STD_LOGIC;
    signal output_sop_sseg : sseg_bus;
    signal output_sop_dpo : STD_LOGIC;
    signal output_conditional_sseg : sseg_bus;
    signal output_conditional_dpo : STD_LOGIC;
    signal output_select_sseg : sseg_bus;
    signal output_select_dpo : STD_LOGIC;
begin

    sop_uut: entity work.hex_to_7seg(sop_arch)
    port map(hex => input_hex, dp => input_dp, 
             sseg => output_sop_sseg, dpo => output_sop_dpo);
             
    conditional_uut: entity work.hex_to_7seg(conditional_arch)
    port map(hex => input_hex, dp => input_dp, 
             sseg => output_conditional_sseg, dpo => output_conditional_dpo);
             
    select_uut: entity work.hex_to_7seg(select_arch)
    port map(hex => input_hex, dp => input_dp, 
             sseg => output_select_sseg, dpo => output_select_dpo);
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
