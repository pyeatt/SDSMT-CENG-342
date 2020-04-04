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
    signal PCie: std_logic := '0'; -- A `0' indicates that the Program Counter should be incremented on the rising clock edge. The Program counter always contains an even number, and is always incremented by two
    signal PCDsel: std_logic := '1'; -- A `1' indicates that the Program Counter should be placed on the D bus, rather than the output of the ALU
    signal IMMBsel: std_logic := '1'; -- A `1' indicates that the Immediate Data, instead of the register file, should be should be used as the B input to the ALU
    signal IMM: std_logic_vector(data_width-1 downto 0); -- Immediate Data that was encoded as part of the current instruction
    signal ALUfunc: std_logic_vector(3 downto 0); -- Selects the operation to be performed by the ALU
    signal MCtrl: std_logic_vector(3 downto 0); -- Control signals from the CPU to Memory/IO
    signal CCRle: std_logic := '1'; -- A `0' indicates that the Condition Code Register should be loaded on the rising clock edge
    signal Flags: std_logic_vector(3 downto 0); -- Output used by the Branch Test Unit so that it can determine whether a branch should be taken or not
    signal MARle: std_logic := '0'; -- A `0' indicates that the Memory Address Register and Memory Data Register should be loaded on the rising clock edge
    signal MCRle: std_logic := '0'; -- A `0' indicates that the Memory Control Register should be loaded on the rising clock edge
    signal Address: std_logic_vector(data_width-1 downto 0); -- Address provided to Memory and I/O devices for read and write operations
    signal Control: std_logic_vector(3 downto 0); -- ???
    signal Reset: std_logic; -- A `0' indicates that all registers should be set to zero. (Synchronous reset is preferred!)
    signal Clock: std_logic; -- Clock signal provided to all registers

    -- test signals
    signal MCRtestIn: unsigned(3 downto 0) := (others=>'0');--unsigned(to_signed(1,4));
    signal MDRtestIn: unsigned(data_width-1 downto 0) := (others=>'0');--unsigned(to_signed(1,4));

--    signal MCRtestOut: unsigned(3 downto 0) := (others=>'0');
--    signal MCRisCorrect: std_logic := '0';
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
        Reset <= '1';
        wait for 10 ns;
        Reset <= '0';
        wait for 10 ns;
        Reset <= '1';
--        wait for 110 ns;
--        Reset <= '0';
--        wait for 10 ns;
--        Reset <= '1';
        wait;
    end process ResetTest;


    ClockTest: process
    begin
        Clock <= '1';
        wait for 5 ns;
        Clock <= not Clock;
        loop
            wait for 10 ns;
            Clock <= not Clock;
        end loop;
    end process ClockTest;
    
    
    -- load values 0 through 7 into registers 0 through 7
    LoadRegisterFile: process
    begin
        wait for 20 ns;
        DIsel <= '1';
        Dlen <= '0';
        for i in 0 to 7 loop
            Dsel <= std_logic_vector(to_unsigned(i, 3));
            Data_in <= std_logic_vector(to_unsigned(i, data_width));
            wait for 20 ns;
        end loop;
        DIsel <= '0';
        Dlen <= '1';
        wait;
    end process LoadRegisterFile;
    
    
    -- every 160 ns read registers 0 through 7 to B bus
    ReadRegisterFileB: process
    begin
        wait for 180 ns; -- wait for register file to be filled
        for i in 0 to 7 loop
            Bsel <= std_logic_vector(to_unsigned(i, 3));
            wait for 20 ns;
        end loop;
    end process ReadRegisterFileB;
    
    
    -- every 160 ns read registers 0 through 7 to A bus
    ReadRegisterFileA: process
    begin
        wait for 180 ns; -- wait for register file to be filled
        for i in 0 to 7 loop
            Asel <= std_logic_vector(to_unsigned(i, 3));
            wait for 20 ns;
        end loop;
    end process ReadRegisterFileA;
    
    
    -- route the B bus to the LPU output
    MCRTest: process
    begin
        loop
            MCtrl <= std_logic_vector(MCRtestIn);
            wait for 20 ns;
            MCRle <= '0';
            wait for 10 ns;
            MCRle <= '1';
            wait for 10 ns;
            MCRtestIn <= MCRtestIn + 1;
            wait for 10 ns;
        end loop;
    end process MCRTest;
    
    
    ALUTest: process
    begin
        CCRle <= '0'; -- enable the CCR
        PCDsel <= '0'; -- route ALU output to D bus
        PCAsel <= '0'; -- route A bus to ALU
        IMMBsel <= '0'; -- rout B bus to ALU
        wait for 180 ns; -- wait for register file to be filled
        for i in 0 to 7 loop
            ALUfunc <= "0000"; -- this sets the ALU function
            wait for 20 ns;
        end loop;
        wait;
    end process ALUTest;


    MDRandMARTest: process
    begin
        wait for 180 ns; -- wait for the register file to be filled
        MARle <= '0'; -- enable the MDR
        loop
            MARle <= not MARle; -- toggle the enable on the MDR and MAR
            wait for 160 ns; -- wait for the next read cycle for the B bus
        end loop;
    end process MDRandMARTest;
    
    
    PC_test: process
    begin
        PCie <= '0'; -- enable PC counter
        PCDsel <= '0'; -- rout PC output to D bus
        wait for 180 ns;
    end process PC_test;



end tb_arch;



