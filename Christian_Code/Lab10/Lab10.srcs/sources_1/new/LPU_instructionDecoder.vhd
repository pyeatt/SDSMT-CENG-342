----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/11/2020
-- Lab 10
-- Design Name: LPU_instructionDecoder
-- Project Name: Lab10
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instructionDecoderPKG.all;

entity instructionDecoder is
    port(
        I : in std_logic_vector(15 downto 0); -- instruction to decode
        take_branch: in std_vector; -- input from BTU
        T : out instruction_t; -- instruction type
        imm: out std_logic_vector(31 downto 0); -- immediate data field
        Asel: out std_logic_vector(2 downto 0); -- select for register A
        Bsel: out std_logic_vector(2 downto 0); -- select for register B
        Dsel: out std_logic_vector(2 downto 0); -- select for register D
        ALUfunc: out std_logic_vector(3 downto 0); -- function for ALU
        control: out control_t_array -- Mux and register enable signals
        );
end instructionDecoder;


architecture arch of instructionDecoder is
begin


end arch;



