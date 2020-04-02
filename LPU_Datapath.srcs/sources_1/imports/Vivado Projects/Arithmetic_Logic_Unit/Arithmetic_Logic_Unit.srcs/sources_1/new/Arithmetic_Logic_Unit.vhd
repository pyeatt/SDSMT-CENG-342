--Author: Clayton Heeren
--Date: March 11, 2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Arithmetic_Logic_Unit is
    generic(log_bits: natural := 3);
    Port (A_in, B_in: in std_logic_vector((2**log_bits)-1 downto 0);
          Carry_in: in std_logic;
          Func: in std_logic_vector(3 downto 0);
          R_out: out std_logic_vector((2**log_bits)-1 downto 0);
          Flags: out std_logic_vector(3 downto 0)
          );
end Arithmetic_Logic_Unit;

architecture Behavioral of Arithmetic_Logic_Unit is
    signal add_flags, bitwise_flags, shift_flags: std_logic_vector(3 downto 0);
    signal inside_func_bits, outside_func_bits: std_logic_vector(1 downto 0);
    signal add_sub_out, bitwise_out, shift_out, zero_sig: std_logic_vector((2**log_bits)-1 downto 0);
begin
    --generate zeros for comparisons
    gen_zero: for I in (2**log_bits)-1 downto 0 generate
        zero_sig(I) <= '0';
    end generate gen_zero;

    --control signals
    inside_func_bits <= Func(2 downto 1);
    outside_func_bits <= Func(3) & Func(0);
    
    --block signals
    adder: entity work.Adder_Block(Behavioral)
           generic map(Log_bits=>log_bits)
           Port Map(A_in=>A_in, B_in=>B_in, C_in=>Carry_in, Func=>inside_func_bits,
                    Flags=>add_flags, Sum=>add_sub_out);
                    
    Bitwise: entity work.Bitwise_Block(Behavioral)
             generic map(Log_bits=>log_bits)
             Port Map(A_in=>A_in, B_in=>B_in, Func=>inside_func_bits,
                      Flags=>bitwise_flags, D_out=>bitwise_out);
                      
    Shift: entity work.Shifter_Block(Behavioral)
             generic map(Log_bits=>log_bits)
             Port Map(A_in=>A_in, B_in=>B_in, Func=>inside_func_bits,
                      Flags=>shift_flags, D_out=>shift_out);
    
    --mux outputs
    with outside_func_bits select
        R_out <= add_sub_out when "00",
                 bitwise_out when "11",
                 shift_out when "10",
                 zero_sig when others;--when others coming when we have more functions
    with outside_func_bits select
        Flags <= add_flags when "00",
                 bitwise_flags when "11",
                 shift_flags when "10",
                 "0000" when others;
    
end Behavioral;
