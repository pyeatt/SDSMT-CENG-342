----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/14/2020
-- Lab 10
-- Design Name: LPU_instructionDecoder
-- Project Name: Lab10
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.instructionDecoderPKG.all;

entity LPU_instructionDecoder_TB is
end LPU_instructionDecoder_TB;

architecture tb_arch of LPU_instructionDecoder_TB is
    signal I : std_logic_vector(15 downto 0); -- instruction to decode
    signal take_branch: std_logic; -- input from BTU (0->no branch; 1->branch)
    signal T : instruction_t; -- instruction type
    signal imm: std_logic_vector(31 downto 0); -- immediate data field
    signal Asel: std_logic_vector(2 downto 0); -- select for register A
    signal Bsel: std_logic_vector(2 downto 0); -- select for register B
    signal Dsel: std_logic_vector(2 downto 0); -- select for register D
    signal ALUfunc: std_logic_vector(3 downto 0); -- function for ALU
    signal control: control_t_array; -- Mux and register enable signals
begin
    decoder:
        entity work.LPU_instructionDecoder(arch)
        port map(
            I => I,
            take_branch => take_branch,
            T => T,
            imm => imm,
            Asel => Asel,
            Bsel => Bsel,
            Dsel => Dsel,
            ALUfunc => ALUfunc,
            control => control          
            );
            
            
    process
    begin
        for j in 0 to 2**17-1 loop
            I <= std_logic_vector(to_unsigned(j, 17)(16 downto 1));
            take_branch <= std_logic(to_unsigned(j, 17)(0));
            
            wait for 20 ns;
        end loop;
    
    end process;

end tb_arch;
