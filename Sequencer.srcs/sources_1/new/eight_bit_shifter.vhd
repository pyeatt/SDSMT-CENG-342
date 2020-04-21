library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity eight_bit_shifter is
    generic( shift_bits: natural := 3);
    Port ( din: in std_logic_vector((2**shift_bits)-1 downto 0);
           dout: out std_logic_vector((2**shift_bits)-1 downto 0);
           shift_amt: in std_logic_vector(shift_bits-1 downto 0);
           func: in std_logic_vector(1 downto 0);
           co: out std_logic
          );
end eight_bit_shifter;

architecture Behavioral of eight_bit_shifter is
    signal logic_left, logic_right, arith_right: std_logic_vector(7 downto 0);
    signal co_left, co_right: std_logic;
begin
    --logical left shift
    with shift_amt select
        logic_left <= din when "000",
                      din(6 downto 0) & '0' when "001",
                      din(5 downto 0) & "00" when "010",
                      din(4 downto 0) & "000" when "011",
                      din(3 downto 0) & "0000" when "100",
                      din(2 downto 0) & "00000" when "101",
                      din(1 downto 0) & "000000" when "110",
                      din(0) & "0000000" when others;
    with shift_amt select
        co_left <= '0' when "000",
                    din(7) when "001",
                    din(6) when "010",
                    din(5) when "011",
                    din(4) when "100",
                    din(3) when "101",
                    din(2) when "110",
                    din(1) when others;
    --logical right shift
    with shift_amt select
        logic_right <= din when "000",
                      '0' & din(7 downto 1) when "001",
                      "00" & din(7 downto 2) when "010",
                      "000" & din(7 downto 3) when "011",
                      "0000" & din(7 downto 4) when "100",
                      "00000" & din(7 downto 5) when "101",
                      "000000" & din(7 downto 6) when "110",
                      "0000000" & din(7) when others;
    
        arith_right <= din when shift_amt = "000" else
                      '0' & din(7 downto 1) when (shift_amt = "001") and (din(7) = '0') else
                      "00" & din(7 downto 2) when (shift_amt = "010") and (din(7) = '0') else
                      "000" & din(7 downto 3) when (shift_amt = "011") and (din(7) = '0') else
                      "0000" & din(7 downto 4) when (shift_amt = "100") and (din(7) = '0') else
                      "00000" & din(7 downto 5) when (shift_amt = "101") and (din(7) = '0') else
                      "000000" & din(7 downto 6) when (shift_amt = "110") and (din(7) = '0') else
                      "0000000" & din(7) when (shift_amt = "111") and (din(7) = '0') else
                      '1' & din(7 downto 1) when (shift_amt = "001") and (din(7) = '1') else
                      "11" & din(7 downto 2) when (shift_amt = "010") and (din(7) = '1') else
                      "111" & din(7 downto 3) when (shift_amt = "011") and (din(7) = '1') else
                      "1111" & din(7 downto 4) when (shift_amt = "100") and (din(7) = '1') else
                      "11111" & din(7 downto 5) when (shift_amt = "101") and (din(7) = '1') else
                      "111111" & din(7 downto 6) when (shift_amt = "110") and (din(7) = '1') else
                      "1111111" & din(7);
    with shift_amt select
        co_right <= '0' when "000",
                    din(0) when "001",
                    din(1) when "010",
                    din(2) when "011",
                    din(3) when "100",
                    din(4) when "101",
                    din(5) when "110",
                    din(6) when others;
    with func select
        dout <= din when "00",
                logic_left when "01",
                logic_right when "10",
                arith_right when others;
    with func select
        co <= 'X' when "00",
              co_left when "01",
              co_right when others;
end Behavioral;

architecture Generic_shifter of eight_bit_shifter is
    type shift_sigs is array (shift_bits downto 0) of std_logic_vector((2**Shift_bits)+1 downto 0);
    signal temp_right, temp_left: shift_sigs;
    signal A_in_fake: std_logic_vector((2**Shift_bits)+1 downto 0);
    signal shift_sig: std_logic_vector(Shift_bits-1 downto 0);
    signal func_sig: std_logic_vector(1 downto 0);
begin
    shift_sig <= shift_amt;
    gen_fillers: for J in 0 to (2**shift_bits)+1 generate
        A_in_fake(J) <= '0' when func = "10" else
                        '0' when func = "01" else
                        '0' when din((2**shift_bits)-1) = '0' else
                        '1';
    end generate gen_fillers;
    
    temp_right(0)((2**shift_bits) downto 1) <= din;
    temp_right(0)(0) <= '0';
    temp_left(0)((2**shift_bits) downto 1) <= din;
    temp_left(0)((2**shift_bits)+1) <= '0';
    
    gen_shift1: for I in 1 to shift_bits generate
        temp_right(I) <= A_in_fake((2**(I-1))+1 downto 1) & 
                         temp_right(I-1)((2**Shift_bits) downto (2**(I-1)))
                         when shift_sig(I-1)='1' else temp_right(I-1);
    end generate gen_shift1;
    
    gen_shift2: for I in 1 to shift_bits generate
        temp_left(I) <= temp_left(I-1)((2**shift_bits)-(2**(I-1))+1 downto 1) & 
                          A_in_fake((2**Shift_bits) downto (2**shift_bits)-(2**(I-1)))
                          when shift_sig(I-1)='1' else temp_left(I-1);
    end generate gen_shift2;
    
    dout <= temp_right(shift_bits)((2**shift_bits) downto 1) when func(1) = '1' 
            else temp_left(shift_bits)((2**shift_bits) downto 1) when func="01"
            else din;
    co <= temp_right(shift_bits)(0) when func(1) = '1' else
          temp_left(shift_bits)((2**shift_bits)+1) when func = "01" else
          '0';
end generic_shifter;