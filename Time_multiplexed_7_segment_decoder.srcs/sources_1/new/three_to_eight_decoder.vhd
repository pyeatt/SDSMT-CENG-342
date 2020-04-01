library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity three_to_eight_decoder is
    generic(in_bits: natural := 3);
    Port ( Sel: in std_logic_vector(in_bits-1 downto 0);
           Enable: in std_logic;
           An: out std_logic_vector((2**in_bits)-1 downto 0)
           );
end three_to_eight_decoder;

architecture Behavioral of three_to_eight_decoder is
    signal Enable_sig: std_logic;
begin
    Enable_sig <= not Enable;
    an(7) <= not ((sel(2)) and (sel(1)) and (sel(0))) and Enable_sig;
    an(6) <= not ((sel(2)) and (sel(1)) and (not sel(0))) and Enable_sig;
    an(5) <= not ((sel(2)) and (not sel(1)) and (sel(0))) and Enable_sig;
    an(4) <= not ((sel(2)) and (not sel(1)) and (not sel(0))) and Enable_sig;
    an(3) <= not ((not sel(2)) and (sel(1)) and (sel(0))) and Enable_sig;
    an(2) <= not ((not sel(2)) and (sel(1)) and (not sel(0))) and Enable_sig;
    an(1) <= not ((not sel(2)) and (not sel(1)) and (sel(0))) and Enable_sig;
    an(0) <= not ((not sel(2)) and (not sel(1)) and (not sel(0))) and Enable_sig;

end Behavioral;
