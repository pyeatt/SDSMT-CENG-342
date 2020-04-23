----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/22/2020
-- Lab 11
-- Design Name: LPU
-- Project Name: Lab11
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LPU_helperPKG.all;

entity LPU is
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
        MDatai : in std_logic_vector(31 downto 0)
        );
end LPU;

architecture Behavioral of LPU is
    signal CW_SQ_ID_internal: control_t_array;
    signal CW_SQ_DP_internal: control_t_array;
    signal T_internal: instruction_t; -- instruction type
    signal I_internal: std_logic_vector(15 downto 0);
    signal CCRflags_internal: CCR_t_array; -- stores flags from CCR
    signal imm_internal: std_logic_vector(31 downto 0); -- immediate data field
    signal Asel_internal: std_logic_vector(2 downto 0); -- select for register A
    signal Bsel_internal: std_logic_vector(2 downto 0); -- select for register B
    signal Dsel_internal: std_logic_vector(2 downto 0); -- select for register D
    signal ALUfunc_internal: std_logic_vector(3 downto 0); -- function for ALU
begin

    sequencer: 
        entity work.LPU_sequencer(Behavioral)
        port map(
            Mrte => Mrte,
            Mrts => Mrts,
            T => T_internal,
            CWin => CW_SQ_ID_internal,
            CWout => CW_SQ_DP_internal,
            clk => clock,
            reset => reset
            );
            
    instructionDecoder:
        entity work.LPU_instructionDecoder(arch)
        port map(
            I => I_internal,
            CCRflags => CCRflags_internal,
            T => T_internal,
            imm => imm_internal,
            Asel => Asel_internal,
            Bsel => Bsel_internal,
            Dsel => Dsel_internal,
            ALUfunc => ALUfunc_internal,
            control => CW_SQ_ID_internal
            );

    datapath:
        entity work.LPU_datapath(arch)
        generic map(
            data_width => 32
            )
        port map(
            Asel => Asel_internal,
            Bsel => Bsel_internal,
            Dsel => Dsel_internal,
            DIsel => CW_SQ_DP_internal(DIsel),
            Dlen => CW_SQ_DP_internal(Dlen),
            Data_in => MDatai,
            Data_out => MDatao,
            PCAsel => CW_SQ_DP_internal(PCAsel),
            PCle => CW_SQ_DP_internal(PCle),
            PCie => CW_SQ_DP_internal(PCie),
            PCDsel => CW_SQ_DP_internal(PCDsel),
            IMMBsel => CW_SQ_DP_internal(IMMBsel),
            IMM => imm_internal,
            ALUfunc => ALUfunc_internal,
            MCtrl(4) => CW_SQ_DP_internal(memcen),
            MCtrl(3) => CW_SQ_DP_internal(memoen),
            MCtrl(2) => CW_SQ_DP_internal(memwen),
            MCtrl(1) => CW_SQ_DP_internal(membyte), 
            MCtrl(0) => CW_SQ_DP_internal(memhalf),
            CCRle => CW_SQ_DP_internal(CCRle),
            Flags(3) => CCRflags_internal(V),
            Flags(2) => CCRflags_internal(Co),
            Flags(1) => CCRflags_internal(Z),
            Flags(0) => CCRflags_internal(N),
            MARle => CW_SQ_DP_internal(MARle),
            MCRle => CW_SQ_DP_internal(MCRle),
            Address => MAddr,
            Control(4) => Mcen,
            Control(3) => Moen,
            Control(2) => Mwen,
            Control(1) => Mbyte,
            Control(0) => Mhalf,
            Reset => reset,
            Clock => clock
            );

    instructionRegister:
        entity work.genericRegister(ifelse_arch)
        generic map(
            bits => 16
            )
        port map(
            en => CW_SQ_DP_internal(Irle),
            clk => clock,
            reset => reset,
            d => MDatai(15 downto 0),
            q => I_internal
            );
            
end Behavioral;
