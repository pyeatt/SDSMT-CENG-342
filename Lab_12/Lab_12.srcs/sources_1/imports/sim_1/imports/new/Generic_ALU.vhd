library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity Generic_Add_With_Overflow is
generic( N_Bit: integer := 32);
 
port(
        A: IN UnSigned(N_Bit-1 downto 0);
        B: IN UnSigned(N_bit-1 downto 0); 
        Ci: IN std_logic_vector(0 downto 0);
        Co: OUT STD_LOGIC; -- carry out
        V: OUT STD_LOGIC; -- overflow
        R: OUT std_logic_vector(N_Bit-1 downto 0)
       -- Test: OUT UnSigned(N_Bit downto 0) 
     );
end Generic_Add_With_Overflow;

architecture cheating of Generic_Add_With_Overflow is
    -- must add 0's to this if you change the value
    signal Rout: UnSigned(N_Bit-1 downto 0); -- Upper bits are used to house the carry over
    signal Ax: UnSigned(N_Bit-1 downto 0);
    signal Bx: UnSigned(N_Bit-1 downto 0);
    signal sum: unsigned((N_Bit - 1) downto 0);
    signal sum2: unsigned(1 downto 0);
begin

   Ax <= ( '0' & a(N_Bit - 2 downto 0));
   Bx <= ( '0' & b(N_Bit - 2 downto 0));
   sum <= Ax + Bx + unsigned(ci);
   sum2 <=('0' & A(N_Bit - 1)) + ('0' & B(N_Bit - 1))+ ('0' & sum(N_Bit - 1));
   
   R <= std_logic_vector((sum2(0) & sum(N_Bit - 2 downto 0)));
    -- carry flags
   Co <= std_logic(sum2(1));
   -- overflow
   V <= sum(N_Bit-1) XOR sum2(1); 

end cheating;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity Generic_ALU is
generic( N_Bit: integer := 32);
 
port(
        A: IN UnSigned(N_Bit-1 downto 0);
        B: IN UnSigned(N_bit-1 downto 0);
        F: IN STD_LOGIC_VECTOR(3 downto 0); 
        Ci: IN std_logic_vector(0 downto 0);
        Co: OUT STD_LOGIC; -- carry out
        Z: OUT STD_LOGIC; -- zero result
        N: OUT STD_LOGIC; -- negative
        V: OUT STD_LOGIC; -- overflow
        R: OUT std_logic_vector(N_Bit-1 downto 0)
       -- Test: OUT UnSigned(N_Bit downto 0) 
     );
end Generic_ALU;

architecture cheating of Generic_ALU is
    -- must add 0's to this if you change the value
    signal Rout: UnSigned(N_Bit-1 downto 0); -- Upper bits are used to house the carry over
    signal sum3: std_logic_vector(N_Bit - 1 downto 0);
    signal lsval: unsigned(N_bit downto 0);
    signal Btemp: UnSigned(N_bit-1 downto 0);
    signal Citemp: std_logic_vector(0 downto 0);
    signal Cotemp: STD_LOGIC;
    signal Vtemp: STD_LOGIC;
begin
    lsval <= shift_left ('0' & A, to_integer(B));
    with f select Btemp <=
    not(B) when "0100" | "0110",
    B when others;
    
    with f select Citemp <=
    Ci when "0010" | "0110",
    "1" when "0100",
    "0" when others;
    
    GAWO: entity work.Generic_Add_With_Overflow(cheating)
    generic map(N_Bit => N_Bit)
    port map(A=>A, B=>Btemp, Ci=>Citemp, Co=>Cotemp, V=>Vtemp, R=>sum3
            );
    -- negative
    N <= std_logic(Rout(N_bit-1));
    
    with f select V <= 
    Vtemp when "0000" | "0010" | "0100" | "0110",
    '0' when others;
    
    with f select Co <= 
    Cotemp when "0000" | "0010" | "0100" | "0110",
    lsval(N_Bit) when "1010",
    '0' when others;
    
    -- zero
    Z <= '1' when Rout= "0" else '0';
    
 -- selecting which function 
process(A,B,F,Ci,sum3)
    begin
    case F is
    when "0000" | "0010" | "0100" | "0110" => Rout <= unsigned(sum3); -- add 
    when "1001" => Rout <= NOT(B); -- Not B
    when "1011" => Rout <= A AND B; -- A and B 
    when "1101" => Rout <= A OR B; -- A Or B 
    when "1111" => Rout <= A XOR B; -- A Xor B
    when "1000" => Rout <= B; --Pass thru 
    when "1010" => Rout <= lsval(N_Bit - 1 downto 0); -- LSL  
    when "1100" => Rout <= shift_right(A, to_integer(B)); -- LSR 
    when "1110" => Rout <= shift_right(A, to_integer(signed(B)));-- ASR
    when others => Rout <= (others => '0'); -- otherwise nothing;
    end case;
end process;
    -- Output of the fucntion inputed
   R <= std_logic_vector(Rout(N_Bit-1 downto 0));
   --Test <= Rout;
end cheating;