library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_register_file_5_testbench is
end generic_register_file_5_testbench;

architecture arch of generic_register_file_5_testbench is
    signal qout:std_logic_vector(4 downto 0);
    signal inselect: std_logic_vector (1 downto 0):="00";
    signal outselect: std_logic_vector (1 downto 0):="00";
    signal reset:std_logic:='1';
    signal din:std_logic_vector(4 downto 0);
    signal clock,enable:std_logic:='1';
    signal write: std_logic;
 begin
     uut: entity work.register_file(behavioral)
     generic map(Log_Registers=>2)
     port map(enable=>enable,clk=>clock,reset=>reset,write_address=>inselect,
              data_in=>din,Read_address=>outselect,data_out=>qout, write=>write);
    write <= '0';
     process
     begin
        wait for 10 ns;
        reset <= '0';
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
        variable dat,i:natural:=0;
     begin
         loop
            for i in 0 to 3 loop
                inselect <= std_logic_vector(to_unsigned(i,2));
                din <= std_logic_vector(to_unsigned(dat,5));
                dat := dat + 1;
                enable <= '0';
                wait for 10 ns;
                enable <= '1';
            end loop;
            for i in 0 to 3 loop
                outselect <= std_logic_vector(to_unsigned(i,2));
                wait for 10 ns;
            end loop;
        end loop;
    end process;
end arch;