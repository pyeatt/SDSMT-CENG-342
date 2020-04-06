----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/05/2020
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
    type TEST_STATE is (
        SETUP,
        SUCC_WRITE_RF,
        SUCC_READ_A_RF,
        SUCC_READ_B_RF,
        ALU_ADD,
        ALU_ADC,
        ALU_SUB,
        ALU_SBC,
        ALU_NOT,
        ALU_AND,
        ALU_OR,
        ALU_XOR,
        ALU_B,
        ALU_LSL,
        ALU_LSR,
        ALU_ASR, 
        LOAD_PC,       
        FAIL_WRITE,
        READ
        );
    signal state: TEST_STATE := SETUP; -- This marks each quarter test period
    signal dat: natural := 0; -- input data
    signal immeadiate: integer := 4; -- constant for ALU operations
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
   
   
   test: process
    begin
        -- clear the MAR
        state <= SETUP;
        Reset <= '1';
        Dlen <= '1';
        PCle <= '1';
        PCie <= '1';
        PCDsel <= '1';
        PCAsel <= '1';
        IMMBsel <= '1';
        CCRle <= '1';
        MARle <= '1';
        MCRle <= '1';
        wait for 10 ns;
        Reset <= '0';
        wait for 15 ns;
        Reset <= '1';
        
        loop
            
            -- load values into registers 0 through 3
            state <= SUCC_WRITE_RF;
            DIsel <= '1';
            Dlen <= '0';
            dat <= dat + 1;
            for i in 0 to 3 loop
                Dsel <= std_logic_vector(to_unsigned(i, 3));
                Data_in <= std_logic_vector(to_unsigned(dat, data_width));
                wait for 20 ns;
                dat <= dat + 1;
            end loop;
            
            -- route registers 0 through 3 to B bus
            state <= SUCC_READ_B_RF;
            MARle <= '0'; -- enable B bus to be outputted to 'Data_out'
            for i in 0 to 3 loop
                Bsel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            
            -- test ALU
            CCRle <= '0'; -- enable the CCR
            PCDsel <= '0'; -- route ALU output to D bus
            PCAsel <= '0'; -- route A bus to ALU
            IMMBsel <= '1'; -- route 'IMM" to ALU
            IMM <= std_logic_vector(to_unsigned(immeadiate, data_width)); -- 4 is a constant for calculations
            state <= ALU_ADD;
            ALUfunc <= "0000";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_ADC;
            ALUfunc <= "0010";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_SUB;
            ALUfunc <= "0100";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_SBC;
            ALUfunc <= "0110";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_NOT;
            ALUfunc <= "1001";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_AND;
            ALUfunc <= "1011";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_OR;
            ALUfunc <= "1101";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_XOR;
            ALUfunc <= "1111";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_B;
            ALUfunc <= "1000";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_LSL;
            ALUfunc <= "1010";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_LSR;
            ALUfunc <= "1100";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;
            state <= ALU_ASR;
            ALUfunc <= "1110";
            for i in 0 to 3 loop
                Asel <= std_logic_vector(to_unsigned(i, 3));
                wait for 20 ns;
            end loop;


            -- add zero from A bus to IMM, store resutl in PC and output to result
            state <= LOAD_PC;
            IMMBsel <= '1'; -- route IMM to ALU
            PCAsel <= '0'; -- route A bus into ALU
            PCle <= '0'; -- enable PC load
            PCie <= '1'; -- diable PC increment
            PCDsel <= '1'; -- route PC to D bus
            ALUfunc <= "0000"; -- set ALU to ADD
            IMM <= std_logic_vector(to_unsigned(1, data_width)); -- set IMM to 'dat'
            Asel <= std_logic_vector(to_unsigned(0, 3)); -- set A bus to 0
            wait for 40 ns;
            
        end loop;
    end process test;
end tb_arch;



