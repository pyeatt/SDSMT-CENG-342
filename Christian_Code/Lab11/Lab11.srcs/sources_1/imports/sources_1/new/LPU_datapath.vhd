----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_datapath
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- This is the datapath for the LPU
entity LPU_datapath is
    generic(
        data_width: integer := 32
        );
    Port(
        Asel: in std_logic_vector(2 downto 0); -- Selects the register to output on the A bus
        Bsel: in std_logic_vector(2 downto 0); -- Selects the register to output on the B bus
        Dsel: in std_logic_vector(2 downto 0); -- Selects the register to output on the D bus
        DIsel: in std_logic; -- A `1' indicates that the register selected by Dsel is loaded with Data in rather than the D Bus
        Dlen: in std_logic; -- A `0' indicates that the register selected by Dsel should be loaded on the next clock cycle. Otherwise the register file does not change
        Data_in: in std_logic_vector(data_width-1 downto 0); -- Data arriving from Memory or I/O devices
        Data_out: out std_logic_vector(data_width-1 downto 0); -- Data to be stored in Memory or I/O devices
        PCAsel: in std_logic; -- A `1' indicates that the PC should be used, instead of the register file, as the A input to the ALU
        PCle: in std_logic; -- A `0' indicates that the Program Counter should be loaded on the rising clock edge
        PCie: in std_logic; -- A `0' indicates that the Program Counter should be incremented on the rising clock edge. The Program counter always contains an even number, and is always incremented by two
        PCDsel: in std_logic; -- A `1' indicates that the Program Counter should be placed on the D bus, rather than the output of the ALU
        IMMBsel: in std_logic; -- A `1' indicates that the Immediate Data, instead of the register file, should be should be used as the B input to the ALU
        IMM: in std_logic_vector(data_width-1 downto 0); -- Immediate Data that was encoded as part of the current instruction
        ALUfunc: in std_logic_vector(3 downto 0); -- Selects the operation to be performed by the ALU
        MCtrl: in std_logic_vector(4 downto 0); -- Control signals from the CPU to Memory/IO
        CCRle: in std_logic; -- A `0' indicates that the Condition Code Register should be loaded on the rising clock edge
        Flags: out std_logic_vector(3 downto 0); -- Output used by the Branch Test Unit so that it can determine whether a branch should be taken or not
        MARle: in std_logic; -- A `0' indicates that the Memory Address Register and Memory Data Register should be loaded on the rising clock edge
        MCRle: in std_logic; -- A `0' indicates that the Memory Control Register should be loaded on the rising clock edge
        Address: out std_logic_vector(data_width-1 downto 0); -- Address provided to Memory and I/O devices for read and write operations
        Control: out std_logic_vector(4 downto 0); -- ???
        Reset: in std_logic; -- A `0' indicates that all registers should be set to zero. (Synchronous reset is preferred!)
        Clock: in std_logic -- Clock signal provided to all registers
        );
end LPU_datapath;


architecture arch of LPU_datapath is
    signal A_bus: std_logic_vector(data_width-1 downto 0); -- Data bus to carry signal A
    signal B_bus: std_logic_vector(data_width-1 downto 0); -- Data bus to carry signal B
    signal D_bus: std_logic_vector(data_width-1 downto 0); -- Data bus to carry signal D
    signal RegFile_in: std_logic_vector(data_width-1 downto 0); -- Data bus to carry input signal to the Register File
    signal ALUA_in: std_logic_vector(data_width-1 downto 0); -- Data bus to carry input signal to the ALU port A
    signal ALUB_in: std_logic_vector(data_width-1 downto 0); -- Data bus to carry input signal to the ALU port B
    signal ALU_out: std_logic_vector(data_width-1 downto 0); -- Data bus to carry output signal of ALU
    signal PC_out: std_logic_vector(data_width-1 downto 0); -- Data bus to carry output signal of PC
    signal CCR_in: std_logic_vector(3 downto 0); -- Data bus to carry input signal of CCR
    signal CCR_out: std_logic_vector(3 downto 0); -- Data bus to carry output signal of CCR
begin

    RegisterFile:
        entity work.LPU_RegisterFile(arch)
        generic map(
            DataWidth => data_width,
            NumSelBits => 3
            )
        port map(
            Asel => Asel,
            Bsel => Bsel,
            Dsel => Dsel,
            WriteEn => Dlen,
            Din => RegFile_in,
            Aout => A_bus,
            Bout => B_bus,
            Clock => Clock,
            Reset => Reset
            );

    RegFile_in <= D_bus when DIsel = '0' else
                  Data_in;
                  
    ALU:
        entity work.genericALU(struct_arch)
        generic map(
            userWidth => data_width
            )
        port map(
            A => ALUA_in,
            B => ALUB_in,
            Ci => CCR_out(2),
            Func => ALUfunc,
            R => ALU_out,
            N => CCR_in(0),
            Z => CCR_in(1),
            Co => CCR_in(2),
            V => CCR_in(3)
            );

    ALUA_in <= A_bus when PCAsel = '0' else
               PC_out;
    ALUB_in <= B_bus when IMMBsel = '0' else
               IMM;

    PC:
        entity work.LPU_PC(arch)
        generic map(
            NumBits => data_width,
            Increment => 2
            )
        port map(
            PCin => ALU_out,
            PCout => PC_out,
            LoadEn => PCle,
            Inc => PCie,
            Clock => Clock,
            Reset => Reset
            );

    CCR:
        entity work.LPU_CCR(arch)
        port map(
            CCRin => CCR_in,
            CCRout => CCR_out,
            LoadEn => CCRle,
            Clock => Clock,
            Reset => Reset
            );

    Flags <= CCR_out;

    MCR:
        entity work.LPU_MCR(arch)
        port map(
            MCRin => MCtrl,
            MCRout => Control,
            LoadEn => MCRle,
            Clock => Clock,
            Reset => Reset
            );

    MDR:
        entity work.LPU_MDR(arch)
        generic map(
            NumBits => data_width
            )
        port map(
            MDRin => B_bus,
            MDRout => Data_out,
            LoadEn => MARle,
            Clock => Clock,
            Reset => Reset
            );

    MAR:
        entity work.LPU_MAR(arch)
        generic map(
            NumBits => data_width
            )
        port map(
            MARin => D_bus,
            MARout => Address,
            LoadEn => MARle,
            Clock => Clock,
            Reset => Reset
            );

    D_bus <= ALU_out when PCDsel = '0' else
             PC_out;
           
end arch;











