library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Generic_Full_Adder_Subtractor is
    Generic(log_N: integer := 2);
    Port ( A_in, B_in: in std_logic_vector((2**log_N)-1 downto 0);
           C_in: in std_logic;
           S_out: out std_logic_vector((2**log_N)-1 downto 0);
           C_out: out std_logic;
           Overflow: out std_logic;
           Func: in std_logic_vector(1 downto 0)
           );
end Generic_Full_Adder_Subtractor;

architecture With_Overflow_Detection of Generic_Full_Adder_Subtractor is
    signal carry_sig: std_logic_vector((2**log_N) downto 0);
    signal mux_out, mux_xor_f1: std_logic;
    signal B_addsub: std_logic_vector((2**log_N)-1 downto 0);
begin
    
    C_out <= carry_sig((2**log_N));
    ---------------------------------------------------------------
    with Func(0) select
        mux_out <= c_in when '1',
                   '0' when others;
    mux_xor_f1 <= Func(1) XOR mux_out;
    carry_sig(0) <= mux_xor_f1;
    ---------------------------------------------------------------
    gen_addsub: for I in 0 to (2**log_N)-1 generate
        b_addsub(I) <= b_in(I) XOR Func(1);
        
        addsub_I: entity work.Full_Adder(standard)
                  port map(a=>A_in(I), b=>b_addsub(I), Cin=>carry_sig(I), Cout=>carry_sig(I + 1), S=>S_out(I));
    end generate gen_addsub;
    
    overflow <= carry_sig((2**log_N)) XOR carry_sig((2**log_N)-1);
    
end With_Overflow_Detection;

architecture No_Subtractor of Generic_Full_Adder_Subtractor is
    signal carry_sig: std_logic_vector((2**log_N) downto 0);
begin
    carry_sig(0) <= C_in;
    C_out <= carry_sig((2**log_N));
    
    gen_addsub: for I in 0 to (2**log_N)-1 generate
        addsub_I: entity work.Full_Adder(standard)
                  port map(a=>A_in(I), b=>B_in(I), Cin=>carry_sig(I), Cout=>carry_sig(I + 1), S=>S_out(I));
    end generate gen_addsub;
    
    overflow <= carry_sig((2**log_N)) XOR carry_sig((2**log_N)-1);

end No_Subtractor;

architecture With_Carry_Lookahead_no_sub of Generic_Full_Adder_Subtractor is
    signal carry_sig: std_logic_vector((2**log_N) downto 0);
    signal B_addsub: std_logic_vector((2**log_N)-1 downto 0);
    signal G, P: std_logic_vector((2**log_N)-1 downto 0);
begin
    carry_sig(0) <= C_in;
    C_out <= carry_sig((2**log_N));
    
    gen_addsub: for I in 0 to (2**log_N)-1 generate
        
        G(I) <= A_in(I) and B_in(I);
        P(I) <= A_in(I) XOR B_in(I);
        carry_sig(I+1) <= G(I) or (P(I) and carry_sig(I));
        
        S_out(I) <= P(I) XOR carry_sig(I);
    end generate gen_addsub;
    
    overflow <= carry_sig((2**log_N)) XOR carry_sig((2**log_N)-1);
    
end With_Carry_Lookahead_no_sub;