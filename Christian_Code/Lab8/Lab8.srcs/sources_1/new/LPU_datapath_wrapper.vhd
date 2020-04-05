----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/05/2020
-- Lab 8
-- Design Name: LPU_datapath_wrapper
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LPU_datapath_wrapper is
    generic(
        data_width: integer := 2
        );
    Port(
        Asel: in std_logic; -- Selects the register to output on the A bus (only can select first 2 registers)
        Bsel: in std_logic; -- Selects the register to output on the B bus (only can select first 2 registers)
        Dsel: in std_logic; -- Selects the register to output on the D bus (only can select first 2 registers)
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
        --MCtrl: in std_logic_vector(3 downto 0); -- Control signals from the CPU to Memory/IO
        CCRle: in std_logic; -- A `0' indicates that the Condition Code Register should be loaded on the rising clock edge
        Flags: out std_logic_vector(3 downto 0); -- Output used by the Branch Test Unit so that it can determine whether a branch should be taken or not
        --MARle: in std_logic; -- A `0' indicates that the Memory Address Register and Memory Data Register should be loaded on the rising clock edge
        --MCRle: in std_logic; -- A `0' indicates that the Memory Control Register should be loaded on the rising clock edge
        Address: out std_logic_vector(data_width-1 downto 0); -- Address provided to Memory and I/O devices for read and write operations
        Control: out std_logic_vector(3 downto 0); -- ???
        Reset: in std_logic; -- A `0' indicates that all registers should be set to zero. (Synchronous reset is preferred!)
        Clock: in std_logic -- Clock signal provided to all registers
        );
end LPU_datapath_wrapper;


architecture arch of LPU_datapath_wrapper is
    signal AselInternal: std_logic_vector(2 downto 0) := (others=>'0'); -- Selects the register to output on the A bus
    signal BselInternal: std_logic_vector(2 downto 0) := (others=>'0'); -- Selects the register to output on the B bus
    signal DselInternal: std_logic_vector(2 downto 0) := (others=>'0'); -- Selects the register to output on the D bus
    signal MCtrl: std_logic_vector(3 downto 0) := (others=>'0'); -- Control signals from the CPU to Memory/IO
    signal MCRle: std_logic := '0'; -- A `0' indicates that the Memory Control Register should be loaded on the rising clock edge
    signal notDlen: std_logic; -- makes Dlen active high
    signal notDIsel: std_logic; -- makes DIsel active high
    signal notCCRle: std_logic; -- makes CCRle active high

begin
    
    AselInternal(0) <= Asel;
    BselInternal(0) <= Bsel;
    DselInternal(0) <= Dsel;
    
    notDlen <= not Dlen;
    notDIsel <= not DIsel;
    notCCRle <= not CCRle;
    
    LPU_datapath:
        entity work.LPU_datapath(arch)
        generic map(
            data_width => data_width
            )
        port map(
             Asel => AselInternal,
             Bsel => BselInternal,
             Dsel => DselInternal,
             DIsel => notDIsel,
             Dlen => notDlen,
             Data_in => Data_in,
             Data_out => Data_out,
             PCAsel => PCAsel,
             PCle => PCle,
             PCie => PCie,
             PCDsel => PCDsel,
             IMMBsel => IMMBsel,
             IMM => IMM,
             ALUfunc => ALUfunc,
             MCtrl => MCtrl,
             CCRle => notCCRle,
             Flags => Flags,
             MARle => '0',
             MCRle => MCRle,
             Address => Address,
             Control => Control,
             Reset => Reset,
             Clock => Clock
             );
end arch;


