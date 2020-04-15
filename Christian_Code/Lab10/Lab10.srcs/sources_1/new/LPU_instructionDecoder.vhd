----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/14/2020
-- Lab 10
-- Design Name: LPU_instructionDecoder
-- Project Name: Lab10
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.instructionDecoderPKG.all;

entity LPU_instructionDecoder is
    port(
        I : in std_logic_vector(15 downto 0); -- instruction to decode
        take_branch: in std_logic_vector(3 downto 0); -- input from BTU
        T : out instruction_t; -- instruction type
        imm: out std_logic_vector(31 downto 0); -- immediate data field
        Asel: out std_logic_vector(2 downto 0); -- select for register A
        Bsel: out std_logic_vector(2 downto 0); -- select for register B
        Dsel: out std_logic_vector(2 downto 0); -- select for register D
        ALUfunc: out std_logic_vector(3 downto 0); -- function for ALU
        control: out control_t_array -- Mux and register enable signals
        );
end LPU_instructionDecoder;


architecture arch of LPU_instructionDecoder is
begin

    Asel <= I(2 downto 0) when I(15 downto 6) = "1000011000" else -- CMPR
        I(2 downto 0) when I(15 downto 13) = "100" and I(10 downto 8) = "111" else -- CMPI
        I(2 downto 0) when I(15 downto 13) = "100" and I(10 downto 9) = "10" and I(7 downto 6) = "00" else -- RR
        I(5 downto 3) when I(15 downto 13) = "100" and I(10) = '0' else -- RRR
        I(2 downto 0) when I(15 downto 13) = "110" else -- RI
        I(5 downto 3) when I(15 downto 13) = "101" else -- RRI
        "XXX" when I(15 downto 14) = "00" and I(5 downto 3) = "111" else -- PCRL
        I(5 downto 3) when I(15 downto 14) = "00" and I(5 downto 3) /= "111" else -- LOAD (this isn't exclusive from PCRL
        I(5 downto 3) when I(15 downto 14) = "01" else -- STORE
        I(2 downto 0) when I(15 downto 12) = "1110" and I(6 downto 3) = "0000" else -- BR
        "XXX" when I(15 downto 12) = "1111" else -- BPCR
        "XXX" when I(15 downto 12) = "1110" and I(6 downto 3) = "1111" else -- HCF
        "XXX"; -- ILLEGAL
        

    Bsel <= I(5 downto 3) when I(15 downto 6) = "1000011000" else -- CMPR
        "XXX" when I(15 downto 13) = "100" and I(10 downto 8) = "111" else -- CMPI
        I(5 downto 3) when I(15 downto 13) = "100" and I(10 downto 9) = "10" and I(7 downto 6) = "00" else -- RR
        I(8 downto 6) when I(15 downto 13) = "100" and I(10) = '0' else -- RRR
        "XXX" when I(15 downto 13) = "110" else -- RI
        "XXX" when I(15 downto 13) = "101" else -- RRI
        "XXX" when I(15 downto 14) = "00" and I(5 downto 3) = "111" else -- PCRL
        "XXX" when I(15 downto 14) = "00" and I(5 downto 3) /= "111" else -- LOAD (this isn't exclusive from PCRL
        I(2 downto 0) when I(15 downto 14) = "01" else -- STORE
        "XXX" when I(15 downto 12) = "1110" and I(6 downto 3) = "0000" else -- BR
        "XXX" when I(15 downto 12) = "1111" else -- BPCR
        "XXX" when I(15 downto 12) = "1110" and I(6 downto 3) = "1111" else -- HCF
        "XXX"; -- ILLEGAL
        
    Dsel <= "XXX" when I(15 downto 6) = "1000011000" else -- CMPR
        "XXX" when I(15 downto 13) = "100" and I(10 downto 8) = "111" else -- CMPI
        I(2 downto 0) when I(15 downto 13) = "100" and I(10 downto 9) = "10" and I(7 downto 6) = "00" else -- RR
        I(2 downto 0) when I(15 downto 13) = "100" and I(10) = '0' else -- RRR
        I(2 downto 0) when I(15 downto 13) = "110" else -- RI
        I(2 downto 0) when I(15 downto 13) = "101" else -- RRI
        I(2 downto 0) when I(15 downto 14) = "00" and I(5 downto 3) = "111" else -- PCRL
        I(2 downto 0) when I(15 downto 14) = "00" and I(5 downto 3) /= "111" else -- LOAD (this isn't exclusive from PCRL
        "XXX" when I(15 downto 14) = "01" else -- STORE
        "111" when I(15 downto 12) = "1110" and I(6 downto 3) = "0000" else -- BR
        "111" when I(15 downto 12) = "1111" else -- BPCR
        "XXX" when I(15 downto 12) = "1110" and I(6 downto 3) = "1111" else -- HCF
        "XXX"; -- ILLEGAL
    


end arch;



