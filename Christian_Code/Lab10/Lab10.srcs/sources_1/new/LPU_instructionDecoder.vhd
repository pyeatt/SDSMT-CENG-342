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
        take_branch: in std_logic; -- input from BTU (0->no branch; 1->branch)
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
    signal T_internal: instruction_t; -- temporary instruction type
begin

    T <= T_internal;
    T_internal <= CMPR when I(15 downto 6) = "1000011000" else -- CMPR
        CMPI when I(15 downto 13) = "100" and I(10 downto 8) = "111" else -- CMPI
        RR when I(15 downto 13) = "100" and I(10 downto 9) = "10" and I(7 downto 6) = "00" else -- RR
        RRR when I(15 downto 13) = "100" and I(10) = '0' else -- RRR
        RI when I(15 downto 13) = "110" else -- RI
        RRI when I(15 downto 13) = "101" else -- RRI
        PCRL when I(15 downto 14) = "00" and I(5 downto 3) = "111" else -- PCRL
        LOAD when I(15 downto 14) = "00" and I(5 downto 3) /= "111" else -- LOAD (this isn't exclusive from PCRL
        STORE when I(15 downto 14) = "01" else -- STORE
        BR when I(15 downto 12) = "1110" and I(6 downto 3) = "0000" else -- BR
        BPCR when I(15 downto 12) = "1111" else -- BPCR
        HCF when I(15 downto 12) = "1110" and I(6 downto 3) = "1111" else -- HCF
        ILLEGAL; -- ILLEGAL
        
    Asel <= I(2 downto 0) when T_internal = CMPR else -- CMPR
        I(2 downto 0) when T_internal = CMPI else -- CMPI
        I(2 downto 0) when T_internal = RR else -- RR
        I(5 downto 3) when T_internal = RRR else -- RRR
        I(2 downto 0) when T_internal = RI else -- RI
        I(5 downto 3) when T_internal = RRI else -- RRI
        "XXX" when T_internal = PCRL else -- PCRL
        I(5 downto 3) when T_internal = LOAD else -- LOAD
        I(5 downto 3) when T_internal = STORE else -- STORE
        I(2 downto 0) when T_internal = BR else -- BR
        "XXX" when T_internal = BPCR else -- BPCR
        "XXX" when T_internal = HCF else -- HCF
        "XXX" when T_internal = ILLEGAL; -- ILLEGAL
        

    Bsel <= I(5 downto 3) when T_internal = CMPR else -- CMPR
        "XXX" when T_internal = CMPI else -- CMPI
        I(5 downto 3) when T_internal = RR else -- RR
        I(8 downto 6) when T_internal = RRR else -- RRR
        "XXX" when T_internal = RI else -- RI
        "XXX" when T_internal = RRI else -- RRI
        "XXX" when T_internal = PCRL else -- PCRL
        "XXX" when T_internal = LOAD else -- LOAD
        I(2 downto 0) when T_internal = STORE else -- STORE
        "XXX" when T_internal = BR else -- BR
        "XXX" when T_internal = BPCR else -- BPCR
        "XXX" when T_internal = HCF else -- HCF
        "XXX" when T_internal = ILLEGAL; -- ILLEGAL
        
    Dsel <= "XXX" when T_internal = CMPR else -- CMPR
        "XXX" when T_internal = CMPI else -- CMPI
        I(2 downto 0) when T_internal = RR else -- RR
        I(2 downto 0) when T_internal = RRR else -- RRR
        I(2 downto 0) when T_internal = RI else -- RI
        I(2 downto 0) when T_internal = RRI else -- RRI
        I(2 downto 0) when T_internal = PCRL else -- PCRL
        I(2 downto 0) when T_internal = LOAD else -- LOAD
        "XXX" when T_internal = STORE else -- STORE
        "111" when T_internal = BR else -- BR
        "111" when T_internal = BPCR else -- BPCR
        "XXX" when T_internal = HCF else -- HCF
        "XXX"; -- ILLEGAL

    IMM <= (others=>'X') when T_internal = CMPR else -- CMPR
        "0000000000000000000000000" & I(12 downto 11) & I(7 downto 3) when T_internal = CMPI else -- CMPI
        (others=>'X') when T_internal = RR else -- RR
        (others=>'X') when T_internal = RRR else -- RRR
        "000000000000000000000000" & I(10 downto 3) when T_internal = RI else -- RI
        "000000000000000000000000000" & I(10 downto 6) when T_internal = RRI else -- RRI
        "00000000000000000000000" & I(13 downto 6) & '0' when T_internal = PCRL else -- PCRL
        "00000000000000000000000000" & I(13 downto 8) when T_internal = LOAD and I(7 downto 6) = "00" else -- LOAD (sz = "00")
        "0000000000000000000000000" & I(13 downto 8) & '0' when T_internal = LOAD and I(7 downto 6) = "01" else -- LOAD (sz = "01")
        "000000000000000000000000" & I(13 downto 8) & "00" when T_internal = LOAD and I(7 downto 6) = "10" else -- LOAD (sz = "10")
        "00000000000000000000000000" & I(13 downto 8) when T_internal = LOAD and I(7 downto 6) = "00" else -- STORE (sz = "00")
        "0000000000000000000000000" & I(13 downto 8) & '0' when T_internal = LOAD and I(7 downto 6) = "01" else -- STORE (sz = "01")
        "000000000000000000000000" & I(13 downto 8) & "00" when T_internal = LOAD and I(7 downto 6) = "10" else -- STORE (sz = "10")
        (others=>'0') when T_internal = BR else -- BR
        "000000000000000000000000" & I(6 downto 0) & '0' when T_internal = BPCR else -- BPCR
        (others=>'X') when T_internal = HCF else -- HCF
        (others=>'X') when T_internal = ILLEGAL; -- ILLEGAL

    ALUfunc <= "0100" when T_internal = CMPR else -- CMPR
        "0100" when T_internal = CMPI else -- CMPI
        '1' & I(12 downto 11) & not(I(12) or I(11)) when T_internal = BR and I(7 downto 6) = "00" else -- RR
        I(9) & I(12 downto 11) & I(9) when T_internal = RRR else -- RRR
        '1' & I(12 downto 11) & (I(12) or I(11)) when T_internal = RI else -- RI
        (I(12) or I(11)) & I(12 downto 11) & '0' when T_internal = RRI else -- RRI
        "0000" when T_internal = PCRL else -- PCRL
        "0000" when T_internal = LOAD else -- LOAD
        "0000" when T_internal = STORE else -- STORE
        "0000" when T_internal = BR else -- BR
        "0000" when T_internal = BPCR else -- BPCR
        "XXXX" when T_internal = HCF else -- HCF
        "XXXX" when T_internal = ILLEGAL; -- ILLEGAL

    control(DIsel) <= 'X' when T_internal = CMPR else -- CMPR
        'X' when T_internal = CMPI else -- CMPI
        '0' when T_internal = RR else -- RR
        '0' when T_internal = RRR else -- RRR
        '0' when T_internal = RI else -- RI
        '0' when T_internal = RRI else -- RRI
        '1' when T_internal = PCRL else -- PCRL
        '1' when T_internal = LOAD else -- LOAD
        'X' when T_internal = STORE else -- STORE
        '0' when T_internal = BR else -- BR
        '0' when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(Dlen) <= '1' when T_internal = CMPR else -- CMPR
        '1' when T_internal = CMPI else -- CMPI
        '0' when T_internal = RR else -- RR
        '0' when T_internal = RRR else -- RRR
        '0' when T_internal = RI else -- RI
        '0' when T_internal = RRI else -- RRI
        '0' when T_internal = PCRL else -- PCRL
        '0' when T_internal = LOAD else -- LOAD
        '1' when T_internal = STORE else -- STORE
        (not take_branch) or I(11) when T_internal = BR else -- BR
        (not take_branch) or I(11) when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(PCAsel) <= '0' when T_internal = CMPR else -- CMPR
        '0' when T_internal = CMPI else -- CMPI
        '0' when T_internal = RR else -- RR
        '0' when T_internal = RRR else -- RRR
        '0' when T_internal = RI else -- RI
        '0' when T_internal = RRI else -- RRI
        '1' when T_internal = PCRL else -- PCRL
        I(5) and I(4) and I(3) when T_internal = LOAD else -- LOAD
        '0' when T_internal = STORE else -- STORE
        '0' when T_internal = BR else -- BR
        '1' when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(PCle) <= '1' when T_internal = CMPR else -- CMPR
        '1' when T_internal = CMPI else -- CMPI
        '1' when T_internal = RR else -- RR
        '1' when T_internal = RRR else -- RRR
        '1' when T_internal = RI else -- RI
        '1' when T_internal = RRI else -- RRI
        '1' when T_internal = PCRL else -- PCRL
        '1' when T_internal = LOAD else -- LOAD
        '1' when T_internal = STORE else -- STORE
        (not take_branch) when T_internal = BR else -- BR
        (not take_branch) when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(PCie) <= '1' when T_internal = CMPR else -- CMPR
        '1' when T_internal = CMPI else -- CMPI
        '1' when T_internal = RR else -- RR
        '1' when T_internal = RRR else -- RRR
        '1' when T_internal = RI else -- RI
        '1' when T_internal = RRI else -- RRI
        '1' when T_internal = PCRL else -- PCRL
        '1' when T_internal = LOAD else -- LOAD
        '1' when T_internal = STORE else -- STORE
        '1' when T_internal = BR else -- BR
        '1' when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(PCDsel) <= 'X' when T_internal = CMPR else -- CMPR
        'X' when T_internal = CMPI else -- CMPI
        '0' when T_internal = RR else -- RR
        '0' when T_internal = RRR else -- RRR
        '0' when T_internal = RI else -- RI
        '0' when T_internal = RRI else -- RRI
        '0' when T_internal = PCRL else -- PCRL
        '0' when T_internal = LOAD else -- LOAD
        '0' when T_internal = STORE else -- STORE
        '1' when T_internal = BR else -- BR
        '1' when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL
        
    control(IMMBsel) <= '0' when T_internal = CMPR else -- CMPR
        '1' when T_internal = CMPI else -- CMPI
        '0' when T_internal = RR else -- RR
        '0' when T_internal = RRR else -- RRR
        '1' when T_internal = RI else -- RI
        '1' when T_internal = RRI else -- RRI
        '1' when T_internal = PCRL else -- PCRL
        '1' when T_internal = LOAD else -- LOAD
        '1' when T_internal = STORE else -- STORE
        '1' when T_internal = BR else -- BR
        '1' when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(CCRle) <= '0' when T_internal = CMPR else -- CMPR
        '0' when T_internal = CMPI else -- CMPI
        '0' when T_internal = RR else -- RR
        '0' when T_internal = RRR else -- RRR
        '0' when T_internal = RI else -- RI
        '0' when T_internal = RRI else -- RRI
        '1' when T_internal = PCRL else -- PCRL
        '1' when T_internal = LOAD else -- LOAD
        '1' when T_internal = STORE else -- STORE
        '1' when T_internal = BR else -- BR
        '1' when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(MARle) <= '1' when T_internal = CMPR else -- CMPR
        '1' when T_internal = CMPI else -- CMPI
        '1' when T_internal = RR else -- RR
        '1' when T_internal = RRR else -- RRR
        '1' when T_internal = RI else -- RI
        '1' when T_internal = RRI else -- RRI
        '0' when T_internal = PCRL else -- PCRL
        '0' when T_internal = LOAD else -- LOAD
        '0' when T_internal = STORE else -- STORE
        '1' when T_internal = BR else -- BR
        '1' when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(MCRle) <= 'X' when T_internal = CMPR else -- CMPR
        '1' when T_internal = CMPI else -- CMPI
        '1' when T_internal = RR else -- RR
        '1' when T_internal = RRR else -- RRR
        '1' when T_internal = RI else -- RI
        '1' when T_internal = RRI else -- RRI
        '1' when T_internal = PCRL else -- PCRL
        '1' when T_internal = LOAD else -- LOAD
        '1' when T_internal = STORE else -- STORE
        '1' when T_internal = BR else -- BR
        '1' when T_internal = BPCR else -- BPCR
        'X' when T_internal = HCF else -- HCF
        'X' when T_internal = ILLEGAL; -- ILLEGAL

    control(membyte) <= I(7) or I(6) when T_internal = LOAD or T_internal = STORE else
        '1';
    
    control(memhalf) <= I(7) or (not I(6)) when T_internal = LOAD or T_internal = STORE else
        '1';
end arch;



