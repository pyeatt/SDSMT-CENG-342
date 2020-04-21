--Author: Clayton Heeren
--Date: 4/19/2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;

entity CPU is
    Port ( clock, reset, Mrts, Mrte: in std_logic;
           Mcem, Moen, Mwen, Mbyte, Mhalf: out std_logic;
           MAddr, MDatao: out std_logic_vector(31 downto 0);
           MDatai: in std_logic_vector(31 downto 0);
           next_state, cur_state: out state_t;--remove when not simulating
           control: out control_t_array;--remove when not simulating
           T: out instruction_t--remove when not simulating
           );
end CPU;

architecture Behavioral of CPU is
    signal ID_CW, SQ_CW: control_t_array;
    signal Flags, ALUfunc: std_logic_vector(3 downto 0);
    signal Asel, Bsel, Dsel: std_logic_vector(2 downto 0);
    signal IMM: std_logic_vector(31 downto 0);
    signal MCtrl_in, Mctrl_out: std_logic_vector(4 downto 0);
    signal take_branch: std_logic;
    signal Instruction: Instruction_t;
    signal encoding: std_logic_vector(15 downto 0);
begin
----CPU------------------------------------------------------------------------------------------------------------
    MCtrl_in <= SQ_CW(memcen) & SQ_CW(MEMoen) & SQ_CW(memwen) & SQ_CW(membyte) & SQ_CW(memhalf);
    CPU_datapath: entity work.CPU_Datapath(Behavioral)
                  Generic Map(log_bits=>5, Log_Registers=>3)
                  Port Map(reset=>reset, clock=>clock, Asel=>Asel, Bsel=>Bsel, Dsel=>Dsel,
                           DIsel=>SQ_CW(Memsel), Dlen=>SQ_CW(Dle), Data_in=>MDatai, data_out=>MDatao,
                           PCAsel=>SQ_CW(PCAsel), PCle=>SQ_CW(PCle), PCie=>SQ_CW(PCie), PCDsel=>SQ_CW(PCDsel), 
                           IMMBsel=>SQ_CW(IMMBsel), IMM=>IMM, ALUfunc=>ALUfunc, CCRle=>SQ_CW(fle),
                           Flags=>Flags, MARle=>SQ_CW(MARle), MCtrl=>MCtrl_in, MCRle=>SQ_CW(mctle), 
                           control=>MCtrl_out, Address=>MAddr);
    Mcem <= MCtrl_out(4);
    Moen <= MCtrl_out(3);
    Mwen <= MCtrl_out(2);
    Mbyte <= MCtrl_out(1);
    Mhalf <= MCtrl_out(0);
-------------------------------------------------------------------------------------------------------------------
----Instruction Decoder--------------------------------------------------------------------------------------------
    IT: entity work.Instruction_Decoder(Behavioral)
        Port Map(I=>encoding, take_branch=>take_branch, T=>Instruction, imm=>IMM, Asel=>Asel,
                 Bsel=>Bsel, Dsel=>Dsel, ALUfunc=>ALUfunc, control=>ID_CW);
    T <= Instruction;--remove when not simulating
-------------------------------------------------------------------------------------------------------------------
----Instruction Register-------------------------------------------------------------------------------------------
    IR: entity work.generic_register(reset_to_high)
        Generic Map(Bits=>16)
        Port Map(clk=>clock, reset=>reset, enable=>SQ_CW(Irle), Data_in=>MDatai(15 downto 0),
                 Data_out=>encoding);
-------------------------------------------------------------------------------------------------------------------
----Branch Test Unit-----------------------------------------------------------------------------------------------
    BTU: entity work.Branch_Test_Unit(Mux)
         Port Map(N=>Flags(3), Z=>Flags(2), C=>flags(1), V=>Flags(0), Condition=>encoding(10 downto 7),
                  Branch=>take_branch);
-------------------------------------------------------------------------------------------------------------------
----Sequencer------------------------------------------------------------------------------------------------------
    SEQ: entity work.Sequencer(Behavioral)
         Port Map(Mrte=>Mrte, Mrts=>Mrts, clk=>clock, reset=>reset, CWin=>ID_CW, T=>Instruction,
                  CWout=>SQ_CW, cur_state_temp=>cur_state, next_state_temp=>next_state);
    control <= SQ_CW;--remove when not simulating
-------------------------------------------------------------------------------------------------------------------    
end Behavioral;
