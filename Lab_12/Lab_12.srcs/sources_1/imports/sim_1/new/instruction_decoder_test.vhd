library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.ALL;

entity instruction_decoder_test is
end instruction_decoder_test;

architecture bench of instruction_decoder_test is
        signal I : std_logic_vector(15 downto 0); -- instruction to decode
        signal T : instruction_t; -- instruction type
        signal Flags:  std_logic_vector(3 downto 0);
        signal imm: std_logic_vector(31 downto 0); -- immediate data field
        signal Asel: std_logic_vector(2 downto 0); -- select for register A
        signal Bsel: std_logic_vector(2 downto 0); -- select for register B
        signal Dsel: std_logic_vector(2 downto 0); -- select for register D
        signal ALUfunc: std_logic_vector(3 downto 0); -- function for ALU
        signal control: control_t_array := (others => '0'); -- Mux and register enable signals
        
begin
    
    instruction_decoder: entity work.instruction_decoder(arch)
        port map(
                    I => I, Flags => Flags, T => T, imm => imm,
                    Asel => Asel, Bsel => Bsel, Dsel => Dsel,
                    ALUfunc => ALUfunc, control => control
                 );
    
    Flags <= "1001";
    
    test: process 
    begin 
        wait for 5 ns;
        -- test the Compare register 
        I <= "1000011000101010";
        wait for 5 ns;
        -- Test Compare Immediate
        I <= "1001011100000101";
        wait for 5 ns;
        -- Test RR 
        I <= "1000010100101010";
        wait for 5 ns;
        -- Test RRR
        I <= "1001101101000101";
        wait for 5 ns;
        -- Test RI 
        I <= "1100011111111010";
        wait for 5 ns;
        -- Test RRI 
        I <= "1011100000111000";
        wait for 5 ns;
        -- Test PCRL
        I <= "0000001111111000";
        wait for 5 ns;
        -- Test Load 
        I <= "0011111100000101";
        wait for 5 ns;
        -- Test Store
        I <= "0111111100000101";
        wait for 5 ns;
        -- Test BR
        I <= "1110101010000110";
        wait for 5 ns;
        -- Test BPCR
        I <= "1111100001111111";
        wait for 5 ns;
        -- Test HCF
        I <= "1110100001111000";
        wait for 5 ns;
        -- Test Illegal 
        I <= "1110000000011000";
        wait for 5 ns;
     end process test; 
end bench;
