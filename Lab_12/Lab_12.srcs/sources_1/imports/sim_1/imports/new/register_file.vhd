library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL; 

--slightly modifed code from register slides

entity register_file is
generic(
            Bits: integer:=32; -- number of bits
            Nsel: integer:=3 -- number of address bits
        );
 port(
            Asel: in std_logic_vector(Nsel-1 downto 0);
            Bsel: in std_logic_vector(Nsel-1 downto 0);
            Dsel: in std_logic_vector(Nsel-1 downto 0);
            DIsel: in std_logic;
            --Dlen: in std_logic;
            Din: in std_logic_vector (Bits-1 downto 0);
            -- Dout: out std_logic_vector (Bits-1 downto 0); whoops on the otherside 
            A: out std_logic_vector (Bits-1 downto 0);
            B: out std_logic_vector (Bits-1 downto 0);
            clk, reset: in std_logic
        );

end register_file;

architecture Behavioral of register_file is
        type slv_array is array (2**Nsel-1 downto 0) of 
        std_logic_vector(Bits-1 downto 0);
        attribute mark_debug: string;
        signal output: slv_array;
        signal Enables: std_logic_vector(2**Nsel-1 downto 0) := (others => '0');
        signal write: std_logic;
        attribute mark_debug of output: signal is "true";
begin
    -- set enable 
    write <= DIsel;
    
    -- create some amount of registers baed of the number of select bits
    -- originally was just going to use when statements, but I don't want
    -- to make that generic so we will just use generate :)
    Registers: for i in 0 to 2**Nsel-1 generate
        Register_num: 
            entity work.generic_register(Behavioral)
            generic map(Bits => Bits)
            port map(Enable => Enables(i), clk => clk, reset => reset,
            din => Din, dout => output(i)
            );
     end generate Registers;  
     
     -- Decode the registers we want using pyeatt's generic decoder :) thanks dad
     Decode:  
        entity work.decoder(Behavioral)
            generic map(Bits => Nsel)
            port map(Enable => write, sel => Dsel, output => Enables);

     -- why an error???       
     A <= output(to_integer(unsigned(Asel)));
     B <= output(to_integer(unsigned(Bsel)));
     
end Behavioral;