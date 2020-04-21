library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Adder_Block is
    Generic(log_bits: Natural := 2);
    Port (A_in, B_in: in std_logic_vector((2**log_bits)-1 downto 0);
          C_in: in std_logic;
          Func: in std_logic_vector(1 downto 0);
          Flags: out std_logic_vector(3 downto 0);
          Sum: out std_logic_vector((2**log_bits)-1 downto 0)
          );
end Adder_Block;

architecture Behavioral of Adder_Block is
    Signal N, Z, C_out, V: std_logic;
    Signal Sum_sig, zero_sig: std_logic_vector((2**log_bits)-1 downto 0);
begin
    --generate zeros for comparisons
    gen_zero: for I in (2**log_bits)-1 downto 0 generate
        zero_sig(I) <= '0';
    end generate gen_zero;
    
    --the adding structures
    Adder_Subtractor: entity work.Generic_Full_Adder_Subtractor(With_Overflow_Detection)
                      Generic Map(log_N=>log_bits)
                      Port Map(A_in=>A_in, B_in=>B_in, C_in=>C_in, S_out=>Sum_sig,
                               C_out=>C_out, Overflow=>V, Func=>Func);
    N <= Sum_sig((2**log_bits)-1);
    Z <= '1' when Sum_sig = zero_sig else '0';
    
    --outputs
    Flags <= N & Z & C_out & V;
    sum <= Sum_sig;
end Behavioral;
