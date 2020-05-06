library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.my_package.ALL;

entity CPU_test is
end CPU_test;

architecture Bench of CPU_test is
   signal clock : std_logic := '0';
   signal reset : std_logic := '0'; -- active low
   signal Mcen :  std_logic; -- active low
   signal Moen : std_logic; -- active low
   signal Mwen : std_logic; -- active low
   signal Mbyte : std_logic; -- active low
   signal Mhalf : std_logic; -- active low
   signal Mrts : std_logic := '0'; -- active low
   signal Mrte : std_logic := '0'; -- active low
   signal MAddr : std_logic_vector(31 downto 0);
   signal MDatao,MDataT : std_logic_vector(31 downto 0);
   signal MDatai : std_logic_vector(15 downto 0);
   signal MDataHi: std_logic_vector(15 downto 0) := (others => '0'); 
   signal I_line: std_logic_vector(15 downto 0);
   
begin

    MdataT <= MDataHi & MDatai;
    CPU: entity work.CPU(arch)
        Port Map(
                  clock => clock,
                  reset => reset, 
                  Mcen => Mcen,
                  Moen => Moen,
                  Mwen => Mwen,
                  Mbyte => Mbyte,
                  Mhalf => Mhalf,
                  Mrts => Mrts,
                  Mrte => Mrte,
                  MAddr => MAddr,
                  MDatao => MDatao,
                  MDatai => MDataT 
                );
            
    --start clock
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
  mrts <= '0';
  wait for 30 ns;
  MDatai <= X"A7C0";
  mrte <= '1';
  wait for 10 ns;
  mrte <= '0';
  wait for 30 ns;
  mrte <= '1';
  -- test RI instructions and fetch2 state
  MDatai <= "1100010101010000"; -- move immediate aa to r0
  mrte <= '1';
  wait for 35 ns;
  mrte <= '0';
  wait for 10 ns;
  mrte <= '1';
  MDatai <= "1100001010101001"; -- move immediate 55 to r1
  wait for 35 ns;
  Mrte <= '0';
  wait for 10 ns;
  MDatai <= X"00b7"; -- or r0 with 55, should get ff
  wait for 30 ns;
  MDatai <= "1101101010101000"; -- xor r0 with 55, should get aa 
  wait for 10 ns;
  MDatai <= "1101001010101000"; -- or r0 with 55, should get ff
  wait for 30 ns;
  MDatai <= "1101101010101000"; -- xor r0 with 55, should get aa
  wait for 30 ns; --c878
  MDatai <= "1100100001111000"; -- and r0 with 0f, should get 0a
  wait for 30 ns;
  
  -- test RRI instructions
  MDatai <= "1010000100001010"; -- add r2,r1,#4 should get 0x59
  wait for 30 ns;
  MDatai <= "1010100001010011"; -- lsl r3,r2,#1 should get B2
  wait for 30 ns;
  MDatai <= "1011000010011100"; -- lsr r4,r3,#2 should get 2C
  wait for 30 ns;
  MDatai <= "1010100111011101"; -- lsl r5,r3,#7 should get 5900 and cc and nc
  wait for 30 ns;
  MDatai <= "1010100001101110"; -- lsl r6,r5,#2 should get b200 and cc and ns
  wait for 30 ns;
  MDatai <= "1011100010110110"; -- asr r6,r6,#1 should get ec80 and cc and ns
  wait for 30 ns;
  MDatai <= "1011100100110110"; -- asr r6,r6,#1 should get FEC8 and cc and ns
  wait for 30 ns;
  MDatai <= "1011100001010010"; -- asr r2,r2,#1 should get 2C and cs
  wait for 30 ns;
  MDatai <= "1011100011010010"; -- asr r2,r2,#3 should get 5 and cs
  wait for 30 ns;
  -- registers should contain: 0000 fec8 5900 002c 00b2 0005 0055 000a
  -- 335 ns into simulation
  -- test RR instructions
  MDatai <= "1000010100110000"; -- not r0,r6  should get 0137
  wait for 30 ns;
  MDatai <= "1000110000010011"; -- lsl r3,r2  should get 0x1640
  wait for 30 ns;
  MDatai <= "1001010000010101"; -- lsr r5,r2  should get 02c8
  wait for 30 ns;
  MDatai <= "1001110000010011"; -- asr r3,r2  should get b2
  wait for 30 ns;
  MDatai <= "1001110000010110"; -- asr r6,r2  should get FFF6
  wait for 30 ns;
  -- registers: should contain 0 fff6 02c8 2c b2 5 55 0137

  -- MDatai <= "1011001000110100"; -- lsr r4,r6,#8 should get EC
  -- wait for 20 ns;

-- 455 ns into simulation
  -- test RRR instructions
  MDatai <= "1000000010001011"; -- add r3,r1,r2 should get 005A and cc
  wait for 30 ns;
  MDatai <= "1000000110000001"; -- add r1,r0,r6 should get 012d and cs
  wait for 30 ns;
  MDatai <= "1000100010010001"; -- adc r1,r2,r2 should get B and cc
  wait for 30 ns;
  MDatai <= "1001000101000001"; -- sub r1,r0,r5 should get fe6f and cc
  wait for 30 ns;
  MDatai <= "1001000000101001"; -- sub r1,r5,r0 should get E6C9 and cs
  wait for 30 ns;
  MDatai <= "1001100111010001"; -- sbc r1,r2,r7 should get 4
  wait for 30 ns;
  MDatai <= "1000010100111000"; -- not r0,r7  should get FFFF
  wait for 30 ns;
  -- registers: should contain 0 ff20 02c8 2c 05a 5 ffff 1bff
  MDatai <= "1001101000001010"; -- xor r2,r0,r1 should get FFFB
  wait for 30 ns;
  MDatai <= "1001001000001011"; -- orr r3,r0,r1 should get FFFF
  wait for 30 ns;
  MDatai <= "1000101000110100"; -- and r4,r6,r0 should get 1b20
  wait for 30 ns;
  -- test comparison, hcf and illegal instruction
  MDatai <= "1000011000111101"; -- cmp r5,r7
  wait for 30 ns;
  MDatai <= "1000011100011001"; -- cmp r5,#0x2c
  wait for 30 ns;
  MDatai <= "1000011100100001"; -- cmp r5,#0x2b
  wait for 30 ns;
  MDatai <= "1000011100101001"; -- cmp r5,#0x2d
  wait for 30 ns;
  -- PC should contain 003E
  -- test branches
  MDatai <= "1100000000100001"; -- move immediate 4  to r1
  wait for 30 ns;
  MDatai <= "1100000100000000"; -- move immediate 0x20  to r0
  wait for 30 ns;
  MDatai <= "1110100000000000";  -- br  r0 r7=unchanged, pc=0020    
  wait for 30 ns;
  MDatai <= "1110000000000001";  -- blr r1 r7=0022, pc=0004 
  wait for 30 ns;
  MDatai <= "1111100000000101";  -- br  forward r7=unchanged, pc=0056
  wait for 30 ns;
  MDatai <= "1111000000000110";  -- blr forward r7=0058, pc=005a
  wait for 30 ns;
  MDatai <= "1111100001111001";  -- br  backward r7=unchanged, pc=0042
  wait for 30 ns;
  MDatai <= "1111000001111010";  -- blr backward r7=44, pc=0046
  wait for 30 ns;
  -- insert some no-ops
  MDatai <= "1010000000000000";  -- noop
  wait for 30 ns;
  MDatai <= "1010000000000000";  -- noop
  wait for 30 ns;
  MDatai <= "1010000000000000";  -- noop
  wait for 30 ns;
  MDatai <= "1010000000000000";  -- noop
  wait for 30 ns;
  MDatai <= "1010000000000000";  -- noop
  wait for 30 ns;
  MDatai <= "1010000000000000";  -- noop
  wait for 30 ns;
  MDatai <= "1110000001111000";  -- HCF
  wait for 30 ns;
    wait;
  end process;
end Bench;
