--Author: Clayton Heeren
--Date: March 27, 2020
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_register_file_5_testbench is
end generic_register_file_5_testbench;

architecture arch of generic_register_file_5_testbench is
    signal B_bus, A_bus:std_logic_vector(7 downto 0);
    signal D_in_sel: std_logic_vector (2 downto 0):="000";
    signal A_out_sel, B_out_sel: std_logic_vector (2 downto 0):="000";
    signal reset:std_logic:='0';
    signal data_in:std_logic_vector(7 downto 0);
    signal clock:std_logic:='0';
    signal write: std_logic;
begin
    uut: entity work.register_file(behavioral)
         generic map(Bits=>8,Log_Registers=>3)
         port map(clk=>clock,reset=>reset, write_address=>D_in_sel, A_out=>A_bus, B_out=>B_bus,
                  data_in=>data_in, A_select=>A_out_sel,B_select=>B_out_sel, write=>write);
    
    process
    begin
       wait for 10 ns;
       reset <= '1';
       wait;
    end process;
   
    process
    begin
        wait for 5 ns;
        clock <= not clock;
        loop
            wait for 10 ns;
            clock <= not clock;
        end loop;
    end process;
    
    process
    begin
        wait for 20ns;
        write <= '0';
        D_in_sel <= "000";
        data_in <= "10101010";--0xAA
        wait for 20ns;
        D_in_sel <= "001";
        data_in <= "10111010";--0xBA
        wait for 20ns;
        D_in_sel <= "010";
        data_in <= "11011001";--0xD9
        wait for 20ns;
        D_in_sel <= "011";
        data_in <= "11110011";--0xF3
        wait for 20ns;
        D_in_sel <= "100";
        data_in <= "11001111";--0xCF
        wait for 20ns;
        D_in_sel <= "101";
        data_in <= "00011000";--0x18
        wait for 20ns;
        D_in_sel <= "110";
        data_in <= "10001110";--0x8E
        wait for 20ns;
        D_in_sel <= "111";
        data_in <= "11111111";--0xFF
        wait for 20ns;
        write <= '1';
        wait;
    end process;
    
    process
        variable dat:natural:=0;
    begin
        wait for 180ns;
        loop
            for dat in 7 downto 0 loop
                B_out_sel <= std_logic_vector(to_unsigned(dat, 3));
                wait for 10ns;
            end loop;
        end loop;
    end process;
    process
        variable i:natural:=0;
    begin
        wait for 180ns;
        loop
            for i in 0 to 7 loop
            A_out_sel <= std_logic_vector(to_unsigned(i, 3));
            wait for 10 ns;
            end loop;
        end loop;
    end process;
    
end arch;