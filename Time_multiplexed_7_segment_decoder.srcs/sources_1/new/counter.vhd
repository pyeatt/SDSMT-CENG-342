library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Counter is
    Generic(Bits: natural := 3);
    Port( Reset: in std_logic;
          clk: in std_logic;
          count: out std_logic_vector(Bits-1 downto 0)
          );
end Counter;

architecture Behavioral of Counter is
    --signal reset_sig: std_logic;
    signal count_sig: std_logic_vector(bits-1 downto 0);
    signal reg_sig: std_logic_vector(bits-1 downto 0);
    signal zero_sig: std_logic_vector(bits-1 downto 0);
begin
    gen_zero: for k in 0 to bits-1 generate
                  zero_sig(k) <= '0';
    end generate gen_zero;

    --store state
    gen_reg: for J in 0 to Bits-1 generate
                 reg_J: entity work.D_Flip_Flop(behavioral)
                        Port map(D=>count_sig(J), Q=>reg_sig(J), clk=>clk,
                                 enable=>'0', reset=>reset);
    end generate gen_reg;
    
    --make next state
    gen_struct: for I in 1 to Bits-1 generate
                    count_sig(I) <= reg_sig(I) XOR reg_sig(I-1);
    end generate gen_struct;
    
    --sets to 0 for start
    --needs to be done at initialization
    process(reset,clk)
    begin
        if (reset = '0') then
            count <= zero_sig;
        else
            count_sig(0) <= reg_sig(0) XOR '1';
            count <= count_sig;
        end if;
    end process;
    
end Behavioral;

Architecture Prof_method of Counter is
    signal data: unsigned(Bits-1 downto 0);
Begin
    process(clk, Reset)
    begin
        if (Reset = '0') then
            data <= (others => '0');
        else
            if clk'event and clk = '1' then
                data <= data + 1;
            end if;
        end if;
    end process;
    
    count <= std_logic_vector(data);
    
end Prof_method;