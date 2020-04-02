library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Shifter_Block is
    generic(log_bits: natural := 2);
    Port (A_in, B_in: in std_logic_vector((2**log_bits)-1 downto 0);
          D_out: out std_logic_vector((2**log_bits)-1 downto 0);
          Func: in std_logic_vector(1 downto 0);
          Flags: out std_logic_vector(3 downto 0)
          );
end Shifter_Block;

architecture Behavioral of Shifter_Block is
    signal N, Z, Carry_out, V, V_temp: std_logic; 
    signal zero_sig, temp_D_out, B_sig, temp_out: std_logic_vector((2**log_bits)-1 downto 0);
begin
    --generate zeros for comparisons
    gen_zero: for I in (2**log_bits)-1 downto 0 generate
        zero_sig(I) <= '0';
    end generate gen_zero;

    --design structures
    shifter: entity work.eight_bit_shifter(Generic_Shifter)
             Generic Map(Shift_bits=>log_bits)
             Port Map(din=>A_in, Shift_amt=>B_in(log_bits-1 downto 0),
                      func=>Func, co=>Carry_out, dout=>temp_D_out);
    
    B_sig <= B_in;
    temp_out <= B_sig when func="00" else
                temp_D_out;
    
    --flags
    N <= '1' when temp_out((2**log_bits)-1) = '1' else '0';
    Z <= '1' when temp_out = zero_sig else '0';
    V_temp <= '1' when temp_out((2**log_bits)-1) /= A_in((2**log_bits)-1) else '0';
    V <= V_temp when Func = "01" else '0';
    
    --outputs
    Flags <= N & Z & Carry_out & V;
    D_out <= temp_out;
end Behavioral;
