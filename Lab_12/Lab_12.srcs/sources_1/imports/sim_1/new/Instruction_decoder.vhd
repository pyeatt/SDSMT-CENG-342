library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.ALL;

entity instruction_decoder is
port(
        I : in std_logic_vector(15 downto 0); -- instruction to decode
        T : out instruction_t; -- instruction type
        Flags: in std_logic_vector(3 downto 0);
        imm: out std_logic_vector(31 downto 0); -- immediate data field
        Asel: out std_logic_vector(2 downto 0); -- select for register A
        Bsel: out std_logic_vector(2 downto 0); -- select for register B
        Dsel: out std_logic_vector(2 downto 0); -- select for register D
        ALUfunc: out std_logic_vector(3 downto 0); -- function for ALU
        control: out control_t_array -- Mux and register enable signals
    );
 end instruction_decoder;

architecture arch of instruction_decoder is
    constant zero_vec: std_logic_vector(31 downto 0) := "00000000000000000000000000000000";
    signal line_T: instruction_t; 
    signal take_branch: std_logic; -- input from BTU 
    signal CMP_imm : std_logic_vector(6 downto 0);
    signal RI_imm  : std_logic_vector(7 downto 0);
    signal RRI_imm : std_logic_vector(4 downto 0);
    signal PCRL_imm: std_logic_vector(8 downto 0);
    signal BPCR_imm: std_logic_vector(7 downto 0);
    signal LDST_imm0: std_logic_vector(5 downto 0);
    signal LDST_imm1: std_logic_vector(6 downto 0);
    signal LDST_imm2: std_logic_vector(7 downto 0);
    signal IrleI,DIselI, immBselI,
     PCDselI,
     PCAselI,
     PCleI, 
     PCieI, 
     DlenI, 
     CCRleI, 
     memcenI,
     memoenI,
     memwenI,
     membyteI,
     memhalfI,
     MARleI, 
     MCRleI, 
     clkenI: std_logic;
begin
    --Pyeatt cheaty's doodles 
    
    -- BTU 
    BTU: entity work.BTU(sanity_check)
    port map (N => Flags(0), 
              Z => Flags(1), 
              C => Flags(2), 
              V => Flags(3),
              Encoding => I(10 downto 7),
              brout => take_branch
              );
            
    -- Asel
    Asel <= I(2 downto 0) when line_T = CMPR else 
            I(2 downto 0) when line_T = CMPI else
            I(2 downto 0) when line_T = RR else
            I(5 downto 3) when line_T = RRR else
            I(2 downto 0) when line_T = RI else
            I(5 downto 3) when line_T = RRI else
            I(5 downto 3) when line_T = LOAD else
            I(5 downto 3) when line_T = STORE else
            I(2 downto 0) when line_T = BR else
            "111" when line_T = PCRL else --this was a mistake as it makes it harder from reading the table
            "111" when line_T = BPCR else
            "111" when line_T = HCF else
            "111"; -- just in case they add something  
            
    -- Bsel
    Bsel <= I(5 downto 3) when line_T = CMPR else 
            "111" when line_T = CMPI else --this was a mistake as it makes it harder from reading the table
            I(5 downto 3) when line_T = RR else
            I(8 downto 6) when line_T = RRR else
            "111" when line_T = RI else
            "111" when line_T = RRI else
            "111" when line_T = PCRL else
            "111" when line_T = LOAD else
            I(2 downto 0) when line_T = STORE else
            "111" when line_T = BR else
            "111" when line_T = BPCR else
            "111" when line_T = HCF else
            "111"; -- just in case they add something 
  
    -- Dsel 
        Dsel <= "111" when line_T = CMPR else 
            "111" when line_T = CMPI else
            I(2 downto 0) when line_T = RR else
            I(2 downto 0) when line_T = RRR else
            I(2 downto 0) when line_T = RI else
            I(2 downto 0) when line_T = RRI else
            I(2 downto 0) when line_T = PCRL else
            I(2 downto 0) when line_T = LOAD else
            "111" when line_T = STORE else
            "111" when line_T = BR else
            "111" when line_T = BPCR else
            "111" when line_T = HCF else
            "111"; -- just in case they add something
    
    -- assinging values 
     CMP_imm <= I(12 downto 11) & I(7 downto 3);
     RI_imm <= I(10 downto 3); 
     RRI_imm <= I(10 downto 6);
     PCRL_imm <= I(13 downto 6) & '0';
     BPCR_imm <= I(6 downto 0) & '0'; 
     LDST_imm0 <= I(13 downto 8);
     LDST_imm1 <= I(13 downto 8) & '0'; 
     LDST_imm2 <= I(13 downto 8) & "00";
                
    -- IMM
    IMM <= (others=>'1') when line_T = CMPR else  
            std_logic_vector(resize(signed(CMP_imm),32)) when line_T = CMPI else
            (others=>'1') when line_T = RR else
            (others=>'1') when line_T = RRR else
            std_logic_vector(resize(signed(RI_imm),32)) when line_T = RI else
            std_logic_vector(resize(signed(RRI_imm),32)) when line_T = RRI else
            std_logic_vector(resize(signed(PCRL_imm),32)) when line_T = PCRL else
            std_logic_vector(resize(signed(LDST_imm0),32)) when line_T = LOAD AND I(7 downto 6) = "00" else
            std_logic_vector(resize(signed(LDST_imm1),32)) when line_T = LOAD AND I(7 downto 6) = "01" else
            std_logic_vector(resize(signed(LDST_imm2),32)) when line_T = LOAD AND I(7 downto 6) = "10" else
            std_logic_vector(resize(signed(LDST_imm0),32)) when line_T = STORE AND I(7 downto 6) = "00" else
            std_logic_vector(resize(signed(LDST_imm1),32)) when line_T = STORE AND I(7 downto 6) = "01" else
            std_logic_vector(resize(signed(LDST_imm2),32)) when line_T = STORE AND I(7 downto 6) = "10" else
            (others=>'0')  when line_T = BR else
            std_logic_vector(resize(signed(BPCR_imm),32)) when line_T = BPCR else
            (others=>'1') when line_T = HCF else
            (others=>'1');
            
    -- ALUfunc
    ALUfunc <= "0100" when line_T = CMPR else 
            "0100" when line_T = CMPI else --this was a mistake as it makes it harder from reading the table
            '1' & I(12 downto 11) & NOT(I(12) OR I(11)) when line_T = RR AND I(7 downto 6) = "00" else
            (I(9) & I(12 downto 11) & I(9)) when line_T = RRR else
            '1' & I(12 downto 11) & (I(12) OR I(11)) when line_T = RI else
            (I(12) OR I(11)) & I(12 downto 11) & '0' when line_T = RRI else
            "0000" when line_T = PCRL else
            "0000" when line_T = LOAD else
            "0000" when line_T = STORE else
            "0000" when line_T = BR else
            "0000" when line_T = BPCR else
            "1111" when line_T = HCF else
            "1111"; -- just in case they add something 
   --Irle
   control(Irle) <= IrleI;
   IrleI <= '1'; -- ask pyeatt what to do with this *****************************************************************************************************************************************************************************************
            
    -- DIsel
    control(DIsel) <= DIselI;
            DIselI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '0' when line_T = RR else
            '0' when line_T = RRR else
            '0' when line_T = RI else
            '0' when line_T = RRI else
            '1' when line_T = PCRL else 
            '1' when line_T = LOAD else
            '1' when line_T = STORE else
            '0' when line_T = BR else
            '0' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- Dlen
    control(Dlen) <= DlenI;
            DlenI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '0' when line_T = RR else
            '0' when line_T = RRR else
            '0' when line_T = RI else
            '0' when line_T = RRI else
            '0' when line_T = PCRL else 
            '0' when line_T = LOAD else
            '1' when line_T = STORE else
            NOT(take_branch) OR I(11) when line_T = BR else
            NOT(take_branch) OR I(11) when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- PCAsel
    control(PCAsel) <= PCAselI;
            PCAselI <= '0' when line_T = CMPR else 
            '0' when line_T = CMPI else
            '0' when line_T = RR else
            '0' when line_T = RRR else
            '0' when line_T = RI else
            '0' when line_T = RRI else
            '1' when line_T = PCRL else 
            '0' when line_T = LOAD else
            '0' when line_T = STORE else
            '0' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- PCle
    control(PCle) <= PCleI;
            PCleI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '1' when line_T = PCRL else 
            '1' when line_T = LOAD else
            '1' when line_T = STORE else
            NOT(take_branch) when line_T = BR else
            NOT(take_branch)when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- PCie
    control(PCie) <= PCieI;
    PCieI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '1' when line_T = PCRL else 
            '1' when line_T = LOAD else
            '1' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- PCDsel
    control(PCDsel) <= PCDselI;
            PCDselI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '0' when line_T = RR else
            '0' when line_T = RRR else
            '0' when line_T = RI else
            '0' when line_T = RRI else
            '0' when line_T = PCRL else 
            '0' when line_T = LOAD else
            '0' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- IMMBsel
    control(IMMBsel) <= IMMBselI;
            IMMBselI <= '0' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '0' when line_T = RR else
            '0' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '1' when line_T = PCRL else 
            '1' when line_T = LOAD else
            '1' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- CCRle
    control(CCRle) <= CCRleI;
        CCRleI <= '0' when line_T = CMPR else 
            '0' when line_T = CMPI else
            '0' when line_T = RR else
            '0' when line_T = RRR else
            '0' when line_T = RI else
            '0' when line_T = RRI else
            '1' when line_T = PCRL else 
            '1' when line_T = LOAD else
            '1' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- MARle
    control(MARle) <= MARleI;
        MARleI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '0' when line_T = PCRL else 
            '0' when line_T = LOAD else
            '0' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- MCRle
    control(MCRle) <= MCRleI;
        MCRleI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '0' when line_T = PCRL else 
            '0' when line_T = LOAD else
            '0' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
    
    -- Mbyte
    control(membyte) <= membyteI;
        membyteI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '1' when line_T = PCRL else 
            '0' when line_T = LOAD AND (i(7 downto 6) = "00") else 
            '0' when line_T = STORE  AND (i(7 downto 6) = "00") else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- Mhalfword
    control(memhalf) <= memhalfI;
        memhalfI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '1' when line_T = PCRL else
            '0' when line_T = LOAD AND (i(7 downto 6) = "01") else 
            '0' when line_T = STORE  AND (i(7 downto 6) = "01") else  
           -- I(7) OR NOT(I(6)) when line_T = LOAD else
           -- I(7) OR NOT(I(6)) when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- Mcen
    control(memcen) <= memcenI;
        memcenI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '0' when line_T = PCRL else 
            '0' when line_T = LOAD else
            '0' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
    
    -- Moen
    control(memoen) <= memoenI;
        memoenI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '0' when line_T = PCRL else 
            '0' when line_T = LOAD else
            '1' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- Mwen
    control(memwen) <= memwenI;
        memwenI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '1' when line_T = PCRL else 
            '1' when line_T = LOAD else
            '0' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '1' when line_T = HCF else
            '1'; -- just in case they add something
            
    -- clken
    control(clken) <= clkenI;
        clkenI <= '1' when line_T = CMPR else 
            '1' when line_T = CMPI else
            '1' when line_T = RR else
            '1' when line_T = RRR else
            '1' when line_T = RI else
            '1' when line_T = RRI else
            '1' when line_T = PCRL else 
            '1' when line_T = LOAD else
            '1' when line_T = STORE else
            '1' when line_T = BR else
            '1' when line_T = BPCR else
            '0' when line_T = HCF else
            '0'; -- just in case they add something
        
    -- T 
    T <= line_T;
    line_T <= CMPR when I(15 downto 6) = "1000011000" else 
        CMPI when I(15 downto 13) = "100" and I(10 downto 8) = "111" else
        RR when I(15 downto 13) = "100" and I(10 downto 9) = "10" and I(7 downto 6) = "00" else
        RRR when I(15 downto 13) = "100" and I(10) = '0' else
        RI when I(15 downto 13) = "110" else
        RRI when I(15 downto 13) = "101" else
        PCRL when I(15 downto 14) = "00" and I(5 downto 3) = "111" else 
        LOAD when I(15 downto 14) = "00" and I(5 downto 3) /= "111" else
        STORE when I(15 downto 14) = "01" else
        BR when I(15 downto 12) = "1110" and I(6 downto 3) = "0000" else
        BPCR when I(15 downto 12) = "1111" else
        HCF when I(15 downto 12) = "1110" and I(6 downto 3) = "1111" else
        ILLEGAL; -- just in case they add something

end arch;