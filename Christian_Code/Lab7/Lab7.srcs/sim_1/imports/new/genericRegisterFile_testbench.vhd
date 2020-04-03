----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/30/2020
-- Lab 7
-- Design Name: genericRegisterFile_testbench
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- entity declaration for a testbench for a generic 5-bit register file
entity genericRegisterFile_testbench is
end genericRegisterFile_testbench;


-- implementation for a testbench for a generic 5-bit register file
architecture tb_arch of genericRegisterFile_testbench is
    signal qout: std_logic_vector(4 downto 0);
    signal control: unsigned(4 downto 0):= "00000";
    signal inselect: std_logic_vector (1 downto 0):= "00";
    signal outselect: std_logic_vector (1 downto 0):= "00";
    signal reset: std_logic := '1';
    signal din: std_logic_vector(4 downto 0);
    signal clock,enable: std_logic := '1';
begin

    uut: entity work.genericRegisterFile(struct_arch)
        generic map(n_sel=>2)
        port map(
            en=>enable,
            clk=>clock,
            rst=>reset,
            dsel=>inselect,
            d=>din,
            qsel=>outselect,
            q=>qout
            );
    
    -- clear the register file
    process
    begin
        wait for 10 ns;
        reset <= '0';
        wait for 10 ns;
        reset <= '1';
        wait;
    end process;
    
    -- run the clock
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
        variable dat,i: natural := 0;
    begin
        loop
            -- write data to the register file
            for i in 0 to 3 loop
                inselect <= std_logic_vector(to_unsigned(i,2));
                din <= std_logic_vector(to_unsigned(dat,5));
                dat := dat + 1;
                enable <= '0';
                wait for 10 ns;
                enable <= '1';
                wait for 10 ns;
            end loop;
            
            -- read data from the register file
            for i in 0 to 3 loop
                outselect <= std_logic_vector(to_unsigned(i,2));
                wait for 10 ns;
            end loop;
        end loop;
    end process;
end tb_arch;