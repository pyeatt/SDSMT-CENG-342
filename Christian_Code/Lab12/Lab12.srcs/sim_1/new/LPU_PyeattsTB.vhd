-- testbench for initial testing of the CPU.  This is out of date, and
-- may not exactly match the final port map for the CPU.  Also, you will need
-- to double-check the instructions, as some of the formats changed between
-- version 1 and version 2 of the CPU.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity CPU_testbench is
end CPU_testbench;

architecture arch of CPU_testbench is
  signal clock  : std_logic:='0';
  signal reset  : std_logic:='1'; -- active low
  signal Mcen   : std_logic; -- active low
  signal Mread  : std_logic; -- active low
  signal Moen   : std_logic; -- active low
  signal Mwen   : std_logic; -- active low
  signal Mbyte  : std_logic; -- active low
  signal Mhalf  : std_logic; -- active low
  signal Mrts   : std_logic:='0'; -- active low 
  signal Mrte   : std_logic:='0'; -- active low 
  signal MAddr  : std_logic_vector(31 downto 0);
  signal ReadData  : std_logic_vector(31 downto 0);
  signal WriteData : std_logic_vector(31 downto 0);
begin

  uut: entity work.LPU(Behavioral)
    port map(clock  => clock,
             reset  => reset,
             Mcen   => Mcen,
             Moen   => Moen,
             Mwen   => Mwen,
             Mbyte  => Mbyte,
             Mhalf  => Mhalf,
             Mrts   => Mrts,
             Mrte   => Mrte,
             MAddr  => MAddr,
             MDatao => WriteData,
             MDatai => ReadData);


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
    wait for 20 ns;
    reset <= '1';
    wait;
  end process;

  
  
  run_tests: process
    procedure test(instruction : in std_logic_vector(15 downto 0)) is
    begin
      Mrts <= '0';
      if Mcen /= '0' then
        wait until Mcen = '0';
      end if;
      wait for 5 ns;
      ReadData <= x"0000" & instruction; -- or r0 with 55, should get ff
      Mrte <= '0';
      if Mcen /= '1' then
        wait until Mcen = '1';
      end if; 
      Mrts <= '1';
      Mrte <= '1';
      wait for 5 ns;
    end procedure test;
  begin

    Mrts <= '1';
    Mrte <= '1';
    wait until reset = '1';
    wait for 20 ns;
    
    test(x"A7C0"); -- add -1 to r0 - should get ffffffff
    
    test(x"FC84"); -- branch less than -- program counter should change
    
    test("1101001010101000"); -- or r0 with 55, should get ff
    
    test("1001000000000000"); -- sub r0,r0,r0 should get 

    -- test RI instructions and fetch2 state
    test("1100010101010000"); -- move immediate aa to r0

    test("1100001010101001"); -- move immediate 55 to r1


    test("1101001010101000"); -- or r0 with 55, should get ff

    test("1101101010101000"); -- xor r0 with 55, should get aa

    test("1100100001111000"); -- and r0 with 0f, should get 0a

    -- test RRI instructions
    test("1010000100001010"); -- add r2,r1,#4 should get 0x59

    test("1010100001010011"); -- lsl r3,r2,#1 should get B2

    test("1011000010011100"); -- lsr r4,r3,#2 should get 2C

    test("1010100111011101"); -- lsl r5,r3,#7 should get 5900 and cc and nc

    test("1010100001101110"); -- lsl r6,r5,#2 should get b200 and cc and ns

    test("1011100010110110"); -- asr r6,r6,#1 should get ec80 and cc and ns

    test("1011100100110110"); -- asr r6,r6,#1 should get FEC8 and cc and ns

    test("1011100001010010"); -- asr r2,r2,#1 should get 2C and cs

    test("1011100011010010"); -- asr r2,r2,#3 should get 5 and cs

    -- registers should contain: 0000 fec8 5900 002c 00b2 0005 0055 000a
    -- 335 ns into simulation
    -- test RR instructions
    test("1000010100110000"); -- not r0,r6  should get 0137

    test("1000110000010011"); -- lsl r3,r2  should get 0x1640

    test("1001010000010101"); -- lsr r5,r2  should get 02c8

    test("1001110000010011"); -- asr r3,r2  should get b2

    test("1001110000010110"); -- asr r6,r2  should get FFF6

    -- registers: should contain 0 fff6 02c8 2c b2 5 55 0137

    -- test("1011001000110100"); -- lsr r4,r6,#8 should get EC
    -- wait for 30 ns;

-- 455 ns into simulation
    -- test RRR instructions
    test("1000000010001011"); -- add r3,r1,r2 should get 005A and cc

    test("1000000110000001"); -- add r1,r0,r6 should get 012d and cs

    test("1000100010010001"); -- adc r1,r2,r2 should get B and cc

    test("1001000101000001"); -- sub r1,r0,r5 should get fe6f and cc

    test("1001000000101001"); -- sub r1,r5,r0 should get E6C9 and cs

    test("1001100111010001"); -- sbc r1,r2,r7 should get 4

    test("1000010100111000"); -- not r0,r7  should get FFFF

    -- registers: should contain 0 ff20 02c8 2c 05a 5 ffff 1bff
    test("1001101000001010"); -- xor r2,r0,r1 should get FFFB

    test("1001001000001011"); -- orr r3,r0,r1 should get FFFF

    test("1000101000110100"); -- and r4,r6,r0 should get 1b20

    -- test comparison, hcf and illegal instruction
    test("1000011000111101"); -- cmp r5,r7

    test("1000011100011001"); -- cmp r5,#0x2c

    test("1000011100100001"); -- cmp r5,#0x2b

    test("1000011100101001"); -- cmp r5,#0x2d

    -- PC should contain 003E
    -- test branches
    test("1100000000100001"); -- move immediate 4  to r1

    test("1100000100000000"); -- move immediate 0x20  to r0

    test("1110100000000000");  -- br  r0 r7=unchanged, pc=0020    

    test("1110000000000001");  -- blr r1 r7=0022, pc=0004 

    test("1111100000000101");  -- br  forward r7=unchanged, pc=0056

    test("1111000000000110");  -- blr forward r7=0058, pc=005a

    test("1111100001111001");  -- br  backward r7=unchanged, pc=0042

    test("1111000001111010");  -- blr backward r7=44, pc=0046

    -- insert some no-ops
    test("1010000000000000");  -- noop

    test("1010000000000000");  -- noop

    test("1010000000000000");  -- noop

    test("1010000000000000");  -- noop

    test("1010000000000000");  -- noop

    test("1010000000000000");  -- noop

    test("1110000001111000");  -- HCF

    wait;
  end process;
  
end arch;

