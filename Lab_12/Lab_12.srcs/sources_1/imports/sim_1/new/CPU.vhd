library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.my_package.ALL;

entity CPU is
    port(
        clock : in std_logic;
        reset : in std_logic; -- active low
        Mcen : out std_logic; -- active low
        Moen : out std_logic; -- active low
        Mwen : out std_logic; -- active low
        Mbyte : out std_logic; -- active low
        Mhalf : out std_logic; -- active low
        Mrts : in std_logic; -- active low
        Mrte : in std_logic; -- active low
        MAddr : out std_logic_vector(31 downto 0);
        MDatao : out std_logic_vector(31 downto 0);
        --ALU_test: out std_logic_vector(3 downto 0);
        MDatai : in std_logic_vector(31 downto 0)
        );
end CPU;

architecture arch of CPU is
    --attribute mark_debug: string;
    --signal alu_f: std_logic_vector(3 downto 0);
    --attribute mark_debug of alu_f : signal is "true";
    attribute mark_debug: string; 
    signal T_line: instruction_t;
    signal I_line: std_logic_vector(15 downto 0);
    attribute mark_debug of I_line: signal is "true";
    signal Flags_line: std_logic_vector(3 downto 0);
    signal IMM_line: std_logic_vector(31 downto 0);
    signal Asel_line: std_logic_vector(2 downto 0);
    signal Bsel_line: std_logic_vector(2 downto 0);
    signal Dsel_line: std_logic_vector(2 downto 0);
    signal ALUfunc_line: std_logic_vector(3 downto 0);
    signal CWin_line: control_t_array; -- CW_ID
    signal CWout_line: control_t_array;-- CW_DP
    
begin
       -- ALU_test <= ALUfunc_line;
        -- need the register to hold the instruction
        Instruction_register: entity work.generic_register(Behavioral)
        generic map( bits => 16)
        port map(
               Enable => CWout_line(Irle),
               clk => clock,
               reset => reset,
               din => MDatai(15 downto 0),
               dout => I_line
            );
        
        -- Better work -__- considering the time I put into this thing
        Instruction_decoder: entity work.instruction_decoder(arch)
        port map (
                    I => I_line,
                    T => T_line,
                    Flags => Flags_line,
                    imm => IMM_line,
                    Asel => Asel_line,
                    Bsel => Bsel_line,
                    Dsel => Dsel_line,
                    ALUfunc => ALUfunc_line,
                    control => CWin_line
                  );
        
        sequecner: entity work.sequencer(arch)
        port map(
                    T => T_line,
                    CWin => CWin_line, 
                    CWout => CWout_line, 
                    Mrte => Mrte,
                    Mrts => Mrts,
                    clk => clock,
                    reset => reset
                 );
        
        datapath: entity work.LPU(arch)
        generic map (Bits => 32, Nsel => 3)
        port map (
                    Asel => Asel_line,
                    Bsel => Bsel_line, 
                    Dsel => Dsel_line,
                    DIsel => CWout_line(DISel),
                    Dlen => CWout_line(Dlen),
                    Data_in => MDatai,
                    Data_out => MDatao,
                    PCAsel => CWout_line(PCAsel),
                    PCie => CWout_line(PCie),
                    PCle => CWout_line(PCle),
                    PCDsel => CWout_line(PCDsel),
                    IMMBsel => CWout_line(IMMBsel),
                    IMM => IMM_line,
                    ALUfunc => ALUfunc_line,
                    MCtrl(4) => CWout_line(memcen),
                    MCtrl(3) => CWout_line(memoen),
                    MCtrl(2) => CWout_line(memwen),
                    MCtrl(1) => CWout_line(membyte),
                    MCtrl(0) => CWout_line(memhalf),
                    CCRle => CWout_line(CCRle),
                    Flags => Flags_line, --Flags 3 = V  2 = Co  1 = Z  N = 0
                    MARle => CWout_line(MARle),
                    MCRle => CWout_line(MCRle),
                    Adress => MAddr, 
                    Control(4) => Mcen,
                    Control(3) => Moen,
                    Control(2) => Mwen,
                    Control(1) => Mbyte,
                    Control(0) => Mhalf, 
                    reset => reset,
                    clk => clock
                 );
end arch;
