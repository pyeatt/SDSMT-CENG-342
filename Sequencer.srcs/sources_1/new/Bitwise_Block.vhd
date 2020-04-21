library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Bitwise_Block is
    generic(log_bits: natural := 2);
    Port (A_in, B_in: in std_logic_vector((2**log_bits)-1 downto 0);
          D_out: out std_logic_vector((2**log_bits)-1 downto 0);
          Func: in std_logic_vector(1 downto 0);
          Flags: out std_logic_vector(3 downto 0)
          );
end Bitwise_Block;

architecture Behavioral of Bitwise_Block is
    signal N, Z, Carry_out, V: std_logic; 
    signal zero_sig, temp_out: std_logic_vector((2**log_bits)-1 downto 0);
    signal bit_not, bit_and, bit_or, bit_xor: std_logic_vector((2**log_bits)-1 downto 0);
begin
    --generate zeros for comparisons
    gen_zero: for I in (2**log_bits)-1 downto 0 generate
        zero_sig(I) <= '0';
    end generate gen_zero;

    --structures
    Gen_NOT: for I in 0 to (2**log_bits)-1 generate
        bit_not(I) <= not B_in(I);
    end generate Gen_NOT;
    
    Gen_AND: for J in 0 to (2**log_bits)-1 generate
        bit_and(J) <= A_in(J) and B_in(J);
    end generate Gen_AND;
    
    Gen_OR: for N in 0 to (2**log_bits)-1 generate
        bit_or(N) <= A_in(N) OR B_in(N);
    end generate Gen_OR;
    
    Gen_XOR: for K in 0 to (2**log_bits)-1 generate
        bit_xor(K) <= A_in(K) XOR B_in(K);
    end generate Gen_XOR;
    
    temp_out <= bit_not when func = "00" else
                bit_and when func = "01" else
                bit_or  when func = "10" else
                bit_XOR;
    
    --flags
    Carry_out <= '0';
    V <= '0';
    N <= '1' when temp_out((2**log_bits)-1) = '1' else '0';
    Z <= '1' when temp_out = zero_sig else '0';
    
    --outputs
    D_out <= temp_out;
    Flags <= N & Z & Carry_out & V;
    
end Behavioral;
