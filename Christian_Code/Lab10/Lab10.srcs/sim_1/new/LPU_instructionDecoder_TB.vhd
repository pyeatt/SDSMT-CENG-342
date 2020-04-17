----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/16/2020
-- Lab 10
-- Design Name: LPU_instructionDecoder
-- Project Name: Lab10
----------------------------------------------------------------------------------
-- run time: 521 ns

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.instructionDecoderPKG.all;

package instructionDecoderTestPKG is

    -- this acts as indexes for each test case
    type tests_t is(
        CMPR1,
        CMPR2,
        CMPI1,
        CMPI2,
        RR1,
        RR2,
        RRR1,
        RRR2,
        RI1,
        RI2,
        RRI1,
        RRI2,
        PCRL1,
        PCRL2,
        LOAD1,
        LOAD2,
        STORE1,
        STORE2,
        BR1,
        BR2,
        BPCR1,
        BPCR2,
        HCF1,
        HCF2,
        ILLEGAL1,
        ILLEGAL2
        );

    -- this stores the instructions to be tested and is indexed by the test name
    type tests_t_array is array (tests_t) of std_logic_vector(15 downto 0);
    
    -- this stores expected test results
    type outputs_t is
        record
            T: instruction_t;
            Asel: std_logic_vector(2 downto 0);
            Bsel: std_logic_vector(2 downto 0);
            Dsel: std_logic_vector(2 downto 0);
            IMM: std_logic_vector(31 downto 0);
            ALUfunc: std_logic_vector(3 downto 0);
            DIsel: std_logic;
            Dlen: std_logic;
            PCAsel: std_logic;
            PCle: std_logic;
            PCie: std_logic;
            PCDsel: std_logic;
            IMMBsel: std_logic;
            CCRle: std_logic;
            MARle: std_logic;
            MCRle: std_logic;
            Byte: std_logic;
            Halfword: std_logic;
            CLKen: std_logic;
        end record;
    
    -- this stores expected test results for all the tests and is indexed by the test name
    type outputs_t_array is array(tests_t) of outputs_t;
    
    -- this verifys the expected with the actual results
    function CheckAnswer(
        T: instruction_t;
        imm: std_logic_vector(31 downto 0);
        Asel: std_logic_vector(2 downto 0);
        Bsel: std_logic_vector(2 downto 0);
        Dsel: std_logic_vector(2 downto 0);
        ALUfunc: std_logic_vector(3 downto 0);
        control: control_t_array;
        outputs: outputs_t
        ) return std_logic;
end instructionDecoderTestPKG;


package body instructionDecoderTestPKG is

    function CheckAnswer(
        T: instruction_t;
        imm: std_logic_vector(31 downto 0);
        Asel: std_logic_vector(2 downto 0);
        Bsel: std_logic_vector(2 downto 0);
        Dsel: std_logic_vector(2 downto 0);
        ALUfunc: std_logic_vector(3 downto 0);
        control: control_t_array;
        outputs: outputs_t
        ) return std_logic is
    begin
        if T = outputs.T and imm = outputs.imm and 
            Asel = outputs.Asel and Bsel = outputs.Bsel and 
            Dsel = outputs.Dsel and ALUfunc = outputs.ALUfunc and
            control(DIsel) = outputs.DIsel and
            control(immBsel) = outputs.immBsel and
            control(PCDsel) = outputs.PCDsel and
            control(PCAsel) = outputs.PCAsel and
            control(PCle) = outputs.PCle and
            control(PCie) = outputs.PCie and
            control(Dlen) = outputs.Dlen and
            control(CCRle) = outputs.CCRle and
            control(MARle) = outputs.MARle and
            control(MCRle) = outputs.MCRle and
            control(membyte) = outputs.Byte and
            control(memhalf) = outputs.Halfword and 
            control(clken) = outputs.CLKen then
            return '1';
        else
            return '0';
        end if;
    end CheckAnswer;
end package body instructionDecoderTestPKG;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.instructionDecoderPKG.all;
use work.instructionDecoderTestPKG.all;

entity LPU_instructionDecoder_TB is
end LPU_instructionDecoder_TB;

architecture tb_arch of LPU_instructionDecoder_TB is
    signal I : std_logic_vector(15 downto 0); -- instruction to decode
    signal CCRflags: CCR_t_array; -- stores flags from CCR
    signal T : instruction_t; -- instruction type
    signal imm: std_logic_vector(31 downto 0); -- immediate data field
    signal Asel: std_logic_vector(2 downto 0); -- select for register A
    signal Bsel: std_logic_vector(2 downto 0); -- select for register B
    signal Dsel: std_logic_vector(2 downto 0); -- select for register D
    signal ALUfunc: std_logic_vector(3 downto 0); -- function for ALU
    signal control: control_t_array := (others=>'0'); -- Mux and register enable signals

    signal curTest: tests_t; -- this displays the current test being run in the waveform
    signal instructions: tests_t_array; -- store the instructions to test
    signal outputs: outputs_t_array; -- stores teh correct output for each instruction
    
    signal isCorrect: std_logic := '0'; -- 1->correct; 0->incorrect

begin
    -- fill instruction array with test instructions
    instructions(CMPR1) <= "1000011000101010";
    instructions(CMPR2) <= "1000011000111000";
    instructions(CMPI1) <= "1001111100000111";
    instructions(CMPI2) <= "1001011100000101";
    instructions(RR1) <= "1000010100101010";
    instructions(RR2) <= "1000110000101010";
    instructions(RRR1) <= "1000100000111000";
    instructions(RRR2) <= "1001101101000101";
    instructions(RI1) <= "1101011111111000";
    instructions(RI2) <= "1100011111111010";
    instructions(RRI1) <= "1011100000111000";
    instructions(RRI2) <= "1010011111000111";
    instructions(PCRL1) <= "0000001111111000";
    instructions(PCRL2) <= "0011111111111001";
    instructions(LOAD1) <= "0011111100000101";
    instructions(LOAD2) <= "0000000010001001";
    instructions(STORE1) <= "0111111100000101";
    instructions(STORE2) <= "0100000110001001";
    instructions(BR1) <= "1110101010000110";
    instructions(BR2) <= "1110000000000001";
    instructions(BPCR1) <= "1111100001111111";
    instructions(BPCR2) <= "1111001010000000";
    instructions(HCF1) <= "1110100001111000";
    instructions(HCF2) <= "1110011111111010";
    instructions(ILLEGAL1) <= "1110000000011000";
    instructions(ILLEGAL2) <= "1110000000001000";
    
    -- fill outputs array with expected results
    outputs(CMPR1) <= (
        T => CMPR,
        Asel => "010",
        Bsel => "101",
        Dsel => "111",
        IMM => (others=>'1'),
        ALUfunc => "0100",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '0',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(CMPR2) <= (
        T => CMPR,
        Asel => "000",
        Bsel => "111",
        Dsel => "111",
        IMM => (others=>'1'),
        ALUfunc => "0100",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '0',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(CMPI1) <= (
        T => CMPI,
        Asel => "111",
        Bsel => "111",
        Dsel => "111",
        IMM => "00000000000000000000000001100000",
        ALUfunc => "0100",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(CMPI2) <= (
        T => CMPI,
        Asel => "101",
        Bsel => "111",
        Dsel => "111",
        IMM => "00000000000000000000000001000000",
        ALUfunc => "0100",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(RR1) <= (
        T => RR,
        Asel => "010",
        Bsel => "101",
        Dsel => "010",
        IMM => (others=>'1'),
        ALUfunc => "1001",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '0',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(RR2) <= (
        T => RR,
        Asel => "010",
        Bsel => "101",
        Dsel => "010",
        IMM => (others=>'1'),
        ALUfunc => "1010",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '0',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(RRR1) <= (
        T => RRR,
        Asel => "111",
        Bsel => "000",
        Dsel => "000",
        IMM => (others=>'1'),
        ALUfunc => "0010",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '0',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(RRR2) <= (
        T => RRR,
        Asel => "000",
        Bsel => "101",
        Dsel => "101",
        IMM => (others=>'1'),
        ALUfunc => "1111",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '0',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(RI1) <= (
        T => RI,
        Asel => "000",
        Bsel => "111",
        Dsel => "000",
        IMM => "00000000000000000000000011111111",
        ALUfunc => "1101",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(RI2) <= (
        T => RI,
        Asel => "010",
        Bsel => "111",
        Dsel => "010",
        IMM => "00000000000000000000000011111111",
        ALUfunc => "1000",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(RRI1) <= (
        T => RRI,
        Asel => "111",
        Bsel => "111",
        Dsel => "000",
        IMM => (others=>'0'),
        ALUfunc => "1110",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(RRI2) <= (
        T => RRI,
        Asel => "000",
        Bsel => "111",
        Dsel => "111",
        IMM => "00000000000000000000000000011111",
        ALUfunc => "0000",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '0',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(PCRL1) <= (
        T => PCRL,
        Asel => "111",
        Bsel => "111",
        Dsel => "000",
        IMM => "00000000000000000000000000011110",
        ALUfunc => "0000",
        DIsel => '1',
        Dlen => '0',
        PCAsel => '1',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '0',
        MCRle => '0',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(PCRL2) <= (
        T => PCRL,
        Asel => "111",
        Bsel => "111",
        Dsel => "001",
        IMM => "00000000000000000000000111111110",
        ALUfunc => "0000",
        DIsel => '1',
        Dlen => '0',
        PCAsel => '1',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '0',
        MCRle => '0',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(LOAD1) <= (
        T => LOAD,
        Asel => "000",
        Bsel => "111",
        Dsel => "101",
        IMM => "00000000000000000000000000111111",
        ALUfunc => "0000",
        DIsel => '1',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '0',
        MCRle => '0',
        Byte => '0',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(LOAD2) <= (
        T => LOAD,
        Asel => "001",
        Bsel => "111",
        Dsel => "001",
        IMM => (others=>'0'),
        ALUfunc => "0000",
        DIsel => '1',
        Dlen => '0',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '0',
        MCRle => '0',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(STORE1) <= (
        T => STORE,
        Asel => "000",
        Bsel => "101",
        Dsel => "111",
        IMM => "00000000000000000000000000111111",
        ALUfunc => "0000",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '0',
        MCRle => '0',
        Byte => '0',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(STORE2) <= (
        T => STORE,
        Asel => "001",
        Bsel => "001",
        Dsel => "111",
        IMM => "00000000000000000000000000000100",
        ALUfunc => "0000",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '0',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '0',
        MCRle => '0',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(BR1) <= (
        T => BR,
        Asel => "110",
        Bsel => "111",
        Dsel => "111",
        IMM => (others=>'0'),
        ALUfunc => "0000",
        DIsel => '0',
        Dlen => '1',
        PCAsel => '0',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(BR2) <= (
        T => BR,
        Asel => "001",
        Bsel => "111",
        Dsel => "111",
        IMM => (others=>'0'),
        ALUfunc => "0000",
        DIsel => '0',
        Dlen => '0',
        PCAsel => '0',
        PCle => '0',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(BPCR1) <= (
        T => BPCR,
        Asel => "111",
        Bsel => "111",
        Dsel => "111",
        IMM => "00000000000000000000000011111110",
        ALUfunc => "0000",
        DIsel => '0',
        Dlen => '1',
        PCAsel => '1',
        PCle => '0',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(BPCR2) <= (
        T => BPCR,
        Asel => "111",
        Bsel => "111",
        Dsel => "111",
        IMM => (others=>'0'),
        ALUfunc => "0000",
        DIsel => '0',
        Dlen => '1',
        PCAsel => '1',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '0'
        );
    outputs(HCF1) <= (
        T => HCF,
        Asel => "111",
        Bsel => "111",
        Dsel => "111",
        IMM => (others=>'1'),
        ALUfunc => "1111",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '1',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '1'
        );
    outputs(HCF2) <= (
        T => HCF,
        Asel => "111",
        Bsel => "111",
        Dsel => "111",
        IMM => (others=>'1'),
        ALUfunc => "1111",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '1',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '1'
        );
    outputs(ILLEGAL1) <= (
        T => ILLEGAL,
        Asel => "111",
        Bsel => "111",
        Dsel => "111",
        IMM => (others=>'1'),
        ALUfunc => "1111",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '1',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '1'
        );
    outputs(ILLEGAL2) <= (
        T => ILLEGAL,
        Asel => "111",
        Bsel => "111",
        Dsel => "111",
        IMM => (others=>'1'),
        ALUfunc => "1111",
        DIsel => '1',
        Dlen => '1',
        PCAsel => '1',
        PCle => '1',
        PCie => '1',
        PCDsel => '1',
        IMMBsel => '1',
        CCRle => '1',
        MARle => '1',
        MCRle => '1',
        Byte => '1',
        Halfword => '1',
        CLKen => '1'
        );

    decoder:
        entity work.LPU_instructionDecoder(arch)
        port map(
            I => I,
            CCRflags => CCRflags,
            T => T,
            imm => imm,
            Asel => Asel,
            Bsel => Bsel,
            Dsel => Dsel,
            ALUfunc => ALUfunc,
            control => control        
            );
     
     -- set static values for the CCR values   
     CCRflags(N) <= '1';
     CCRflags(Z) <= '0';
     CCRflags(Co) <= '0';
     CCRflags(V) <= '1';       
            
    test: process
    begin
        wait for 1 ns; -- ensure the instructions and results are loaded
        
        -- generate results
        for j in instructions'left to instructions'right loop
            I <= instructions(j);
            curTest <= j; -- display which test is being run in the waveform
            wait for 1 ns;
            
            -- verify results
            isCorrect <= CheckAnswer(
                T,
                imm,
                Asel,
                Bsel,
                Dsel,
                ALUfunc,
                control,
                outputs(j) 
                );
            wait for 19 ns;
        end loop;
    end process test;
end tb_arch;
