----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/02/2020
-- Lab 8
-- Design Name: LPU_datapath_TB
-- Project Name: Lab8
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LPU_datapath_TB is
end LPU_datapath_TB;


architecture tb_arch of LPU_datapath_TB is
    constant data_width: integer := 32;
    signal Asel: std_logic_vector(2 downto 0); -- Selects the register to output on the A bus
    signal Bsel: std_logic_vector(2 downto 0); -- Selects the register to output on the B bus
    signal Dsel: std_logic_vector(2 downto 0); -- Selects the register to output on the D bus
    signal DIsel: std_logic := '1'; -- A `1' indicates that the register selected by Dsel is loaded with Data in rather than the D Bus
    signal Dlen: std_logic := '1'; -- A `0' indicates that the register selected by Dsel should be loaded on the next clock cycle. Otherwise the register file does not change
    signal Data_in: std_logic_vector(data_width-1 downto 0); -- Data arriving from Memory or I/O devices
    signal Data_out: std_logic_vector(data_width-1 downto 0); -- Data to be stored in Memory or I/O devices
    signal PCAsel: std_logic := '1'; -- A `1' indicates that the PC should be used, instead of the register file, as the A input to the ALU
    signal PCle: std_logic := '1'; -- A `0' indicates that the Program Counter should be loaded on the rising clock edge
    signal PCie: std_logic := '1'; -- A `0' indicates that the Program Counter should be incremented on the rising clock edge. The Program counter always contains an even number, and is always incremented by two
    signal PCDsel: std_logic := '1'; -- A `1' indicates that the Program Counter should be placed on the D bus, rather than the output of the ALU
    signal IMMBsel: std_logic := '1'; -- A `1' indicates that the Immediate Data, instead of the register file, should be should be used as the B input to the ALU
    signal IMM: std_logic_vector(data_width-1 downto 0); -- Immediate Data that was encoded as part of the current instruction
    signal ALUfunc: std_logic_vector(3 downto 0); -- Selects the operation to be performed by the ALU
    signal MCtrl: std_logic_vector(3 downto 0); -- Control signals from the CPU to Memory/IO
    signal CCRle: std_logic := '1'; -- A `0' indicates that the Condition Code Register should be loaded on the rising clock edge
    signal Flags: std_logic_vector(3 downto 0); -- Output used by the Branch Test Unit so that it can determine whether a branch should be taken or not
    signal MARle: std_logic := '1'; -- A `0' indicates that the Memory Address Register and Memory Data Register should be loaded on the rising clock edge
    signal MCRle: std_logic := '1'; -- A `0' indicates that the Memory Control Register should be loaded on the rising clock edge
    signal Address: std_logic_vector(data_width-1 downto 0); -- Address provided to Memory and I/O devices for read and write operations
    signal Control: std_logic_vector(3 downto 0); -- ???
    signal Reset: std_logic := '1'; -- A `0' indicates that all registers should be set to zero. (Synchronous reset is preferred!)
    signal Clock: std_logic := '1'; -- Clock signal provided to all registers
begin

    LPU_datapath:
        entity work.LPU_datapath(arch)
        generic map(
            data_width => data_width
            )
        port map(
             Asel => Asel,
             Bsel => Bsel,
             Dsel => Dsel,
             DIsel => DIsel,
             Dlen => Dlen,
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
             CCRle => CCRle,
             Flags => Flags,
             MARle => MARle,
             MCRle => MCRle,
             Address => Address,
             Control => Control,
             Reset => Reset,
             Clock => Clock
             );

    ResetTest: process
    begin
        wait for 10 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait for 110 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
        wait;
    end process ResetTest;
    
    ClockTest: process
    begin
        wait for 5 ns;
        Clock <= not Clock;
        loop
            wait for 10 ns;
            Clock <= not Clock;
        end loop;
    end process ClockTest;




end tb_arch;



