----------------------------------------------------------------------------------
-- Author: Christian Weaver & Dr. Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/24/2020
-- Lab 11
-- Design Name: LPU_TB
-- Project Name: Lab11
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.LPU_helperPKG.all;


entity LPU_TB is
end LPU_TB;

architecture arch of LPU_TB is
     signal clock  : std_logic:='0';
     signal reset  : std_logic:='1'; -- active low
     signal Mcen: std_logic; -- active low
     signal Moen  : std_logic; -- active low
     signal Mwen : std_logic; -- active low
     signal Mbyte : std_logic; -- active low 
     signal Mhalf : std_logic; -- active low
     signal Mrts : std_logic := '0'; -- active low
     signal Mrte : std_logic := '0'; -- active low
     signal MAddr  : std_logic_vector(31 downto 0);
     signal MDatao : std_logic_vector(31 downto 0);
     signal MDatai : std_logic_vector(31 downto 0):="00000000000000001010101010101010";
    
     type testInstruction is(
        myNULL,
        MOV_R0_AA,
        MOV_R1_55,
        myWAIT,
        OR_R0_55,
        XOR_R0_55,
        AND_R0_0F,
        ADD_R2_R1,
        LSL_R3_R2_1,
        LSR_R4_R3_2,
        LSL_R5_R3_7,
        LSL_R6_R5_17,
        ASR_R6_R6_2,
        ASR_R6_R6_4,
        ASR_R2_R2_1,
        ASR_R2_R2_3,
        NOT_R0_R6,
        LSL_R3_R2,
        LSR_R5_R2,
        ASR_R3_R2,
        ASR_R6_R6,
        ADD_R3_R1_R2,
        ADD_R1_R0_R6,
        ADC_R1_R2_R2,
        SUB_R1_R0_R5,
        SUB_R1_R5_R0,
        SBC_R1_R2_R7,
        NOT_R0_R7,
        XOR_R2_R0_R1,
        ORR_R3_R0_R1,
        AND_R4_R6_R0,
        CMP_R5_R7,
        CMP_R1_0x2,
        CMP_R1_0x4,
        CMP_R1_0x5,
        MOV_R1_0x4,
        MOV_R0_0x20,
        BR_R0,
        BLR_R1,
        B_0xA,
        BL_0xC,
        B_minus0x2,
        BL_minus0x4,
        STH_R0_R0_0x0,
        myILLEGAL
        );
    signal instruction: testInstruction := myNULL;
   
    signal expectedResult: std_logic_vector(31 downto 0);
begin
    
    LPU:
        entity work.LPU(Behavioral)
        port map(
            clock => clock,
            reset => reset,
            Mcen => Mcen,
            Moen => Moen,
            Mwen => Mwen,
            Mbyte => Mbyte,
            Mhalf => Mhalf,
            Mrts => Mrts,
            Mrte => Mrte,
            Maddr => Maddr,
            Mdatao => Mdatao,
            Mdatai => Mdatai
            );

    process
    begin
        loop
            wait for 5 ns;
            clock <= not clock;
        end loop;
    end process;
    
    process
    begin
        reset <= '0';
        wait for 10 ns;
        reset <= '1';
        wait;
    end process;
    
    process
    begin
        -- test RI instructions and fetch2 state
        --  IT  OP  ImmU8   rd
        -- |110|XX|XXXXXXXX|XXX|
        instruction <= MOV_R0_AA;
        expectedResult <= (others=>'U');
        MDatai <= "00000000000000001100010101010000"; -- move immediate aa to r0
        Mrts <= '0';
        wait for 45 ns;
        Mrts <= '0';
        wait for 10 ns;
        Mrts <= '0';
        instruction <= MOV_R1_55;
        expectedResult <= (others=>'U');
        MDatai <= "00000000000000001100001010101001"; -- move immediate 55 to r1
        wait for 20 ns;
        
        -- test putting LPU into FETCHWAIT from EX1 state
        instruction <= myWAIT;
        Mrts <= '1';
        wait for 39 ns;
        
        Mrts <= '0';
        instruction <= OR_R0_55;
        expectedResult <= std_logic_vector(to_unsigned(255,32));
        MDatai <= "00000000000000001101001010101000"; -- or r0 with 55, should get ff
        wait for 30 ns;
        instruction <= XOR_R0_55;
        expectedResult <= std_logic_vector(to_unsigned(170,32));
        MDatai <= "00000000000000001101101010101000"; -- xor r0 with 55, should get aa
        wait for 30 ns;
        instruction <= AND_R0_0F;
        expectedResult <= std_logic_vector(to_unsigned(10,32));
        MDatai <= "00000000000000001100100001111000"; -- and r0 with 0f, should get 0a
        wait for 30 ns;
        
        -- test RRI instructions
        --  IT  OP Imm5  ra  rd
        -- |101|XX|XXXXX|XXX|XXX|
        instruction <= ADD_R2_R1;
        expectedResult <= std_logic_vector(to_unsigned(89,32));
        MDatai <= "00000000000000001010000100001010"; -- add r2,r1,#4 should get 0x59
        wait for 30 ns;
        instruction <= LSL_R3_R2_1;
        expectedResult <= std_logic_vector(to_unsigned(178,32));
        MDatai <= "00000000000000001010100001010011"; -- lsl r3,r2,#1 should get B2
        wait for 30 ns;
        instruction <= LSR_R4_R3_2;
        expectedResult <= std_logic_vector(to_unsigned(44,32));
        MDatai <= "00000000000000001011000010011100"; -- lsr r4,r3,#2 should get 2C
        wait for 30 ns;
        instruction <= LSL_R5_R3_7;
        expectedResult <= std_logic_vector(to_unsigned(22784,32));
        MDatai <= "00000000000000001010100111011101"; -- lsl r5,r3,#7 should get 5900 and cc and nc
        wait for 30 ns;
        instruction <= LSL_R6_R5_17;
        expectedResult <= "10110010000000000000000000000000";--std_logic_vector(to_unsigned(2986344448,32));
        MDatai <= "00000000000000001010110001101110"; -- lsl r6,r5,#17 should get b2000000 and cc and ns
        wait for 30 ns;
        instruction <= ASR_R6_R6_2;
        expectedResult <= "11101100100000000000000000000000";--std_logic_vector(to_unsigned(3967811584,32));
        MDatai <= "00000000000000001011100010110110"; -- asr r6,r6,#2 should get ec800000 and cc and ns
        wait for 30 ns;
        instruction <= ASR_R6_R6_4;
        expectedResult <= "11111110110010000000000000000000";--std_logic_vector(to_unsigned(4274520064,32));
        MDatai <= "00000000000000001011100100110110"; -- asr r6,r6,#4 should get feC80000 and cc and ns
        wait for 30 ns;
        instruction <= ASR_R2_R2_1;
        expectedResult <= std_logic_vector(to_unsigned(44,32));
        MDatai <= "00000000000000001011100001010010"; -- asr r2,r2,#1 should get 2C and cs
        wait for 30 ns;
        instruction <= ASR_R2_R2_3;
        expectedResult <= std_logic_vector(to_unsigned(5,32));
        MDatai <= "00000000000000001011100011010010"; -- asr r2,r2,#3 should get 5 and cs
        wait for 30 ns;
        --                          |   R7   |   R6   |   R5   |   R4   |   R3   |   R2   |   R1   |   R0   |
        -- registers should contain: 00000000 fec80000 00005900 0000002c 000000b2 00000005 00000055 0000000a
        
        -- 335 ns into simulation
        -- test RR instructions
        --  IT  op MT om res rb  rd
        -- |100|XX|10|X |00 |XXX|XXX
        instruction <= NOT_R0_R6;
        expectedResult <= std_logic_vector(to_unsigned(20447231,32));
        MDatai <= "00000000000000001000010100110000"; -- not r0,r6  should get 0137FFFF
        wait for 30 ns;
        instruction <= LSL_R3_R2;
        expectedResult <= std_logic_vector(to_unsigned(5696,32));
        MDatai <= "00000000000000001000110000010011"; -- lsl r3,r2  should get 1640
        wait for 30 ns;
        instruction <= LSR_R5_R2;
        expectedResult <= std_logic_vector(to_unsigned(712,32));
        MDatai <= "00000000000000001001010000010101"; -- lsr r5,r2  should get 02c8
        wait for 30 ns;
        instruction <= ASR_R3_R2;
        expectedResult <= std_logic_vector(to_unsigned(178,32));
        MDatai <= "00000000000000001001110000010011"; -- asr r3,r2  should get b2
        wait for 30 ns;
        instruction <= ASR_R6_R6;
        expectedResult <= "11111111111101100100000000000000"; --std_logic_vector(to_unsigned(65526,32));
        MDatai <= "00000000000000001001110000010110"; -- asr r6,r2  should get FFF64000?
        wait for 30 ns;
        --                          |   R7   |   R6   |   R5   |   R4   |   R3   |   R2   |   R1   |   R0   |
        -- registers should contain: 00000000 FFF64000 000002c8 0000002c 000000B2 00000005 00000055 0137FFFF
        
        -- MDatai <= "1011001000110100"; -- lsr r4,r6,#8 should get EC
        -- wait for 20 ns;
        
        -- 455 ns into simulation
        -- test RRR instructions
        --  IT  op MT om rb  ra  rd
        -- |100|XX|0 |X |XXX|XXX|XXX|
        instruction <= ADD_R3_R1_R2;
        expectedResult <= std_logic_vector(to_unsigned(90,32));
        MDatai <= "00000000000000001000000010001011"; -- add r3,r1,r2 should get 005A and cc
        wait for 30 ns;
        instruction <= ADD_R1_R0_R6;
        expectedResult <= "00000001001011100011111111111111";
        MDatai <= "00000000000000001000000110000001"; -- add r1,r0,r6 should get 012e3fff and cs
        wait for 30 ns;
        instruction <= ADC_R1_R2_R2;
        expectedResult <= "00000000000000000000000000001011";
        MDatai <= "00000000000000001000100010010001"; -- adc r1,r2,r2 should get B and cc
        wait for 30 ns;
        instruction <= SUB_R1_R0_R5;
        expectedResult <= std_logic_vector(to_unsigned(20446519,32));
        MDatai <= "00000000000000001001000101000001"; -- sub r1,r0,r5 should get 137fd37 and cc
        wait for 30 ns;
        instruction <= SUB_R1_R5_R0;
        expectedResult <= "11111110110010000000001011001001";
        MDatai <= "00000000000000001001000000101001"; -- sub r1,r5,r0 should get fec802c9 and cs
        wait for 30 ns;
        instruction <= SBC_R1_R2_R7;
        expectedResult <= std_logic_vector(to_unsigned(4,32));
        MDatai <= "00000000000000001001100111010001"; -- sbc r1,r2,r7 should get 4
        wait for 30 ns;
        instruction <= NOT_R0_R7;
        expectedResult <= "11111111111111111111111111111111";
        MDatai <= "00000000000000001000010100111000"; -- not r0,r7  should get FFFFFFFF
        wait for 30 ns;
        --                          |   R7   |   R6   |   R5   |   R4   |   R3   |   R2   |   R1   |   R0   |
        -- registers should contain: 00000000 FFF64000 000002c8 0000002c 0000005A 00000005 00000004 FFFFFFFF

        instruction <= XOR_R2_R0_R1;
        expectedResult <= "11111111111111111111111111111011";
        MDatai <= "00000000000000001001101000001010"; -- xor r2,r0,r1 should get FFFFFFFB
        wait for 30 ns;
        instruction <= ORR_R3_R0_R1;
        expectedResult <= "11111111111111111111111111111111";
        MDatai <= "00000000000000001001001001000011"; -- orr r3,r0,r1 should get FFFFFFFF
        wait for 30 ns;
        instruction <= AND_R4_R6_R0;
        expectedResult <= "11111111111101100100000000000000";
        MDatai <= "00000000000000001000101000110100"; -- and r4,r6,r0 should get FFF64000
        wait for 30 ns;
        --                          |   R7   |   R6   |   R5   |   R4   |   R3   |   R2   |   R1   |   R0   |
        -- registers should contain: 00000000 FFF64000 000002c8 FFF64000 FFFFFFFF FFFFFFFB 00000004 FFFFFFFF

        -- test comparison, hcf and illegal instruction
        instruction <= CMP_R5_R7;
        expectedResult <= std_logic_vector(to_unsigned(712,32));
        MDatai <= "00000000000000001000011000111101"; -- cmp r5,r7 should get 0x2C8
        wait for 30 ns;
        instruction <= CMP_R1_0x2;
        expectedResult <= std_logic_vector(to_unsigned(2,32));
        MDatai <= "00000000000000001000011100010001"; -- cmp r1,#0x2
        wait for 30 ns;
        instruction <= CMP_R1_0x4;
        expectedResult <= std_logic_vector(to_unsigned(0,32));
        MDatai <= "00000000000000001000011100100001"; -- cmp r1,#0x4
        wait for 30 ns;
        instruction <= CMP_R1_0x5;
        expectedResult <= "11111111111111111111111111111111";
        MDatai <= "00000000000000001000011100101001"; -- cmp r1,#0x5
        wait for 30 ns;
        -- PC should contain 0040

        -- test branches
        instruction <= MOV_R1_0x4;
        expectedResult <= std_logic_vector(to_unsigned(4,32));
        MDatai <= "00000000000000001100000000100001"; -- move immediate 4 to r1
        wait for 30 ns;
        instruction <= MOV_R0_0x20;
        expectedResult <= std_logic_vector(to_unsigned(32,32));
        MDatai <= "00000000000000001100000100000000"; -- move immediate 0x20 to r0
        wait for 30 ns;
        instruction <= BR_R0;
        expectedResult <= std_logic_vector(to_unsigned(32,32));
        MDatai <= "00000000000000001110100000000000";  -- br  r0 r7=unchanged, pc=0x20    
        wait for 30 ns;
        instruction <= BLR_R1;
        expectedResult <= std_logic_vector(to_unsigned(4,32));
        MDatai <= "00000000000000001110000000000001";  -- blr r1 r7=0022, pc=0x4 
        wait for 30 ns;
        instruction <= B_0xA;
        expectedResult <= std_logic_vector(to_unsigned(16,32));
        MDatai <= "00000000000000001111100000000101";  -- br  forward r7=unchanged, pc=0x10
        wait for 30 ns;
        instruction <= BL_0xC;
        expectedResult <= std_logic_vector(to_unsigned(30,32));
        MDatai <= "00000000000000001111000000000110";  -- blr forward r7=0x10, pc=0x1e
        wait for 30 ns;
        -- (PC automatically increments to 0x20)
        instruction <= B_minus0x2;
        expectedResult <= std_logic_vector(to_unsigned(30,32));
        MDatai <= "00000000000000001111100001111111";  -- br  backward r7=unchanged, pc=0x1e
        wait for 30 ns;
        instruction <= BL_minus0x4;
        expectedResult <= std_logic_vector(to_unsigned(28,32));
        MDatai <= "00000000000000001111000001111110";  -- blr backward r7=20, pc=0x1C
        wait for 30 ns;
        
        -- store
        instruction <= STH_R0_R0_0x0;
        expectedResult <= std_logic_vector(to_unsigned(32,32));
        MDatai <= "00000000000000000100000001000000";  -- STB backward r7=20, pc=0x1C
        wait for 30 ns;
        if Mcen = '0' then
            wait until Mcen = '1';
        end if;
        wait for 10 ns;
        
        instruction <= myILLEGAL;
        expectedResult <= (others=>'-');
        MDatai <= "00000000000000001110000000011000";  -- ILLEGAL
        wait for 30 ns;

        wait;
    end process;
end arch;

