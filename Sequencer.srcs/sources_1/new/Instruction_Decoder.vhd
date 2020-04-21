--Author: Clayton Heeren
--Date: 4/10/2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;

entity Instruction_Decoder is
    Port ( I : in std_logic_vector(15 downto 0); -- instruction to decode
           take_branch: in std_logic; -- input from BTU
           T : out instruction_t; -- instruction type
           imm: out std_logic_vector(31 downto 0); -- immediate data field
           Asel: out std_logic_vector(2 downto 0); -- select for register A
           Bsel: out std_logic_vector(2 downto 0); -- select for register B
           Dsel: out std_logic_vector(2 downto 0); -- select for register D
           ALUfunc: out std_logic_vector(3 downto 0); -- function for ALU
           control: out control_t_array -- Mux and register enable signals
           );
end Instruction_Decoder;

architecture Behavioral of Instruction_Decoder is
    signal instruction: instruction_t;
    signal IMM_Sig: std_logic_vector(31 downto 0);
    signal sign_ex_CMPI, sign_ex_RRI, sign_ex_LS, sign_ex_BPCR, Dlen_BR, PCAsel_LOAD: std_logic;
    signal offset_sig_LS: std_logic_vector(7 downto 0);
    signal ALU_func_RR, ALU_func_RRR, ALU_func_RI, ALU_func_RRI: std_logic_vector(3 downto 0);
    signal mem_LS: std_logic_vector(4 downto 0);
    signal mem_MSBs: std_logic_vector(2 downto 0);
begin
    control(Irle) <= '0';
    --generate instruction
    process(I, take_branch)
    begin
        if(I = "1111111111111111") then
            instruction <= ILLEGAL;
        elsif (I(15 downto 13) = "100") then
            if (I(10) = '0') then
                instruction <= RRR;
            elsif (I(10 downto 9) = "10") then
                instruction <= RR;
            elsif (I(10 downto 8) = "110") then
                instruction <= CMPR;
            elsif (I(10 downto 8) = "111") then
                instruction <= CMPI;
            else
                instruction <= ILLEGAL;
            end if;
        elsif (I(15 downto 13) = "101") then
            instruction <= RRI;
        elsif (I(15 downto 13) = "110") then
            instruction <= RI;
        elsif (I(15 downto 14) = "00") then
            if(I(5 downto 3) = "111") then
                instruction <= PCRL;
            else
                instruction <= LOAD;
            end if;
        elsif (I(15 downto 14) = "01") then
            instruction <= STORE;
        elsif (I(15 downto 12) = "1111") then
            instruction <= BPCR;
        elsif (I(15 downto 12) = "1110") then
            if (I(6 downto 3) = "0000") then
                instruction <= BR;
            elsif (I(6 downto 3) = "1111") then
                instruction <= HCF;
            else
                instruction <= ILLEGAL;
            end if;
        else
            instruction <= ILLEGAL;
        end if;
    end process;
    --generate outputs
    --A select
    with instruction select
        Asel <= I(2 downto 0) when CMPR,
                I(2 downto 0) when CMPI,
                I(2 downto 0) when RR,
                I(5 downto 3) when RRR,
                I(2 downto 0) when RI,
                I(5 downto 3) when RRI,
                "---" when PCRL,
                I(5 downto 3) when LOAD,
                I(5 downto 3) when STORE,
                I(2 downto 0) when BR,
                "---" when BPCR,
                "---" when HCF,
                "---" when others;
    --B select
    with instruction select
        Bsel <= I(5 downto 3) when CMPR,
                "---" when CMPI,
                I(5 downto 3) when RR,
                I(8 downto 6) when RRR,
                "---" when RI,
                "---" when RRI,
                "---" when PCRL,
                "---" when LOAD,
                I(2 downto 0) when STORE,
                "---" when BR,
                "---" when BPCR,
                "---" when HCF,
                "---" when others;
    --data select
    with instruction select
        Dsel <= "---" when CMPR,
                "---" when CMPI,
                I(2 downto 0) when RR,
                I(2 downto 0) when RRR,
                I(2 downto 0) when RI,
                I(2 downto 0) when RRI,
                I(2 downto 0) when PCRL,
                I(2 downto 0) when LOAD,
                "---" when STORE,
                "111" when BR,
                "111" when BPCR,
                "---" when HCF,
                "---" when others;
    --Immeadiate
    sign_ex_CMPI <= '1' when I(12) = '1' else '0';
    sign_ex_RRI <= '1' when I(10) = '1' else '0';
    sign_ex_LS <= '1' when I(13) = '1' else '0';
    sign_ex_BPCR <= '1' when I(6) = '1' else '0';
    offset_sig_LS <= sign_ex_LS & sign_ex_LS & I(13 downto 8) when I(7 downto 6) = "00" else
                     sign_ex_LS & I(13 downto 8) & '0' when I(7 downto 6) = "01" else 
                     I(13 downto 8) & "00";
    with instruction select
        IMM_Sig <= (others=>'-') when CMPR,
                   (6=>I(12), 5=>I(11), 4=>I(7), 3=>I(6), 2=>I(5), 1=>I(4), 0=>I(3), others=>sign_ex_CMPI) when CMPI,--may need to sign extend
                   (others=>'-') when RR,
                   (others=>'-') when RRR,
                   (7=>I(10), 6=>I(9), 5=>I(8), 4=>I(7), 3=>I(6), 2=>I(5), 1=>I(4), 0=>I(3), others=>'0') when RI,
                   (4=>I(10), 3=>I(9), 2=>I(8), 1=>I(7), 0=>I(6), others=>sign_ex_RRI) when RRI,
                   (8=>I(13), 7=>I(12), 6=>I(11), 5=>I(10), 4=>I(9), 3=>I(8), 2=>I(7), 1=>I(6), others=>'0') when PCRL,
                   (7=>offset_sig_LS(7), 6=>offset_sig_LS(6), 5=>offset_sig_LS(5), 4=>offset_sig_LS(4), 3=>offset_sig_LS(3),
                   2=>offset_sig_LS(2), 1=>offset_sig_LS(1), 0=>offset_sig_LS(0), others=>sign_ex_LS) when LOAD,
                   (7=>offset_sig_LS(7), 6=>offset_sig_LS(6), 5=>offset_sig_LS(5), 4=>offset_sig_LS(4), 3=>offset_sig_LS(3),
                   2=>offset_sig_LS(2), 1=>offset_sig_LS(1), 0=>offset_sig_LS(0), others=>sign_ex_LS) when STORE,
                   (others=>'0') when BR,
                   (7=>I(6), 6=>I(5), 5=>I(4), 3=>I(2), 2=>I(1), 1=>I(0), others=>sign_ex_BPCR) when BPCR,
                   (others=>'-') when HCF,
                   (others=>'-') when others;
    IMM <= IMM_Sig;
    --ALU function
    ALU_func_RR <= "1001" when I(8) = '1' else ('1' & I(12 downto 11) & '0');
    ALU_func_RRR <= ('0' & I(12 downto 11) & '0') when I(9) = '0' else ('1' & I(12 downto 11) & '1');
    ALU_func_RI <= "1000" when I(12 downto 11) = "00" else ('1' & I(12 downto 11) & '1');
    ALU_func_RRI <= "0010" when I(12 downto 11) = "00" else ('1' & I(12 downto 11) & '0');
    with instruction select
        ALUfunc <= "0100" when CMPR,
                   "0100" when CMPI,
                   ALU_func_RR when RR,
                   ALU_func_RRR when RRR,
                   ALU_func_RI when RI,
                   ALU_func_RRI when RRI,
                   "0000" when PCRL,
                   "0000" when LOAD,
                   "1010" when STORE,
                   "0000" when BR,
                   "0000" when BPCR,
                   "----" when HCF,
                   "----" when others;
    --Data bus or memmory
    with instruction select
        control(memsel) <= '-' when CMPR,
                           '-' when CMPI,
                           '0' when RR,
                           '0' when RRR,
                           '0' when RI,
                           '0' when RRI,
                           '0' when PCRL,
                           '1' when LOAD,
                           '-' when STORE,
                           '0' when BR,
                           '0' when BPCR,
                           '-'when HCF,
                           '-' when others;
    --Load register enable
    Dlen_BR <= take_branch or I(11);
    with instruction select
        control(Dle)  <= '1' when CMPR,
                         '1' when CMPI,
                         '0' when RR,
                         '0' when RRR,
                         '0' when RI,
                         '0' when RRI,
                         '0' when PCRL,
                         '0' when LOAD,
                         '1' when STORE,
                         Dlen_BR when BR,
                         Dlen_BR when BPCR,
                         '-' when HCF,
                         '-' when others;
    --PC or A bus Select
    PCAsel_LOAD <= '1' when I(5 downto 3) = "111" else '0';
    with instruction select
        control(PCAsel) <= '0' when CMPR,
                           '0' when CMPI,
                           '0' when RR,
                           '0' when RRR,
                           '0' when RI,
                           '0' when RRI,
                           '1' when PCRL,
                           PCAsel_LOAD when LOAD,
                           '0' when STORE,
                           '0' when BR,
                           '1' when BPCR,
                           '-'when HCF,
                           '-' when others;
    --PC load enable
    with instruction select
        control(PCle) <= '1' when CMPR,
                         '1' when CMPI,
                         '1' when RR,
                         '1' when RRR,
                         '1' when RI,
                         '1' when RRI,
                         '1' when PCRL,
                         '1' when LOAD,
                         '1' when STORE,
                         take_branch when BR,
                         take_branch when BPCR,
                         '-' when HCF,
                         '-' when others;
    --PC increment
    with instruction select
        control(PCie) <= '1' when CMPR,
                         '1' when CMPI,
                         '1' when RR,
                         '1' when RRR,
                         '1' when RI,
                         '1' when RRI,
                         '1' when PCRL,
                         '1' when LOAD,
                         '1' when STORE,
                         '1' when BR,
                         '1' when BPCR,
                         '-' when HCF,
                         '-' when others;
    --PC or ALU select
    with instruction select
        control(PCDsel) <= '-' when CMPR,
                           '-' when CMPI,
                           '0' when RR,
                           '0' when RRR,
                           '0' when RI,
                           '0' when RRI,
                           '0' when PCRL,
                           '0' when LOAD,
                           '0' when STORE,
                           '1' when BR,
                           '1' when BPCR,
                           '-'when HCF,
                           '-' when others;
    --Immeadiate or B bus select
    with instruction select
        control(IMMBsel) <= '0' when CMPR,
                            '1' when CMPI,
                            '0' when RR,
                            '0' when RRR,
                            '1' when RI,
                            '1' when RRI,
                            '1' when PCRL,
                            '1' when LOAD,
                            '1' when STORE,
                            '1' when BR,
                            '1' when BPCR,
                            '-' when HCF,
                            '-' when others;
    --CCR load enable
    with instruction select
        control(fle)   <= '0' when CMPR,
                          '1' when CMPI,
                          '0' when RR,
                          '0' when RRR,
                          '0' when RI,
                          '0' when RRI,
                          '0' when PCRL,
                          '0' when LOAD,
                          '0' when STORE,
                          '1' when BR,
                          '1' when BPCR,
                          '-' when HCF,
                          '-' when others;
    --MAR load enable
    with instruction select
        control(MARle) <= '1' when CMPR,
                          '1' when CMPI,
                          '1' when RR,
                          '1' when RRR,
                          '1' when RI,
                          '1' when RRI,
                          '1' when PCRL,
                          '0' when LOAD,
                          '0' when STORE,
                          '1' when BR,
                          '1' when BPCR,
                          '-' when HCF,
                          '-' when others;
    --MCR load enable
    with instruction select
        control(mctle) <= '1' when CMPR,
                          '1' when CMPI,
                          '1' when RR,
                          '1' when RRR,
                          '1' when RI,
                          '1' when RRI,
                          '1' when PCRL,
                          '0' when LOAD,
                          '0' when STORE,
                          '1' when BR,
                          '1' when BPCR,
                          '-' when HCF,
                          '-' when others;
    --memory controls
    mem_MSBs <= "001" when instruction = LOAD else
                "010" when instruction = STORE else
                "111";
    mem_LS <= mem_MSBs & "11" when I(7 downto 6) = "10" else
              mem_MSBs & "10" when I(7 downto 6) = "01" else
              mem_MSBs & "01";
    control(memcen) <= mem_LS(4) when (instruction = LOAD) or (instruction = STORE) else '1';
    control(memoen) <= mem_LS(3) when (instruction = LOAD) or (instruction = STORE) else '1';
    control(memwen) <= mem_LS(2) when (instruction = LOAD) or (instruction = STORE) else '1';
    control(membyte) <= mem_LS(1) when (instruction = LOAD) or (instruction = STORE) else '1';
    control(memhalf) <= mem_LS(0) when (instruction = LOAD) or (instruction = STORE) else '1';
    --route outputs
    control(clken) <= '0' when instruction = HCF else '1';
    T <= instruction;
end Behavioral;
