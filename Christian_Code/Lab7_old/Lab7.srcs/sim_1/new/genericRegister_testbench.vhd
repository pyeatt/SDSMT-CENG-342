----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/14/2020
-- Lab 7
-- Design Name: genericRegister_testbench
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- entity declaration for a testbench for a generic register
entity genericRegister_testbench is
end genericRegister_testbench;


-- implementation for a testbench for a generic register
architecture tb_arch of genericRegister_testbench is
    signal qout: std_logic_vector(1 downto 0);
    signal control: unsigned(4 downto 0):="00000";
    signal reset: std_logic:='1';
    signal din: std_logic_vector(1 downto 0);
    signal clock,enable: std_logic;
begin
    uut: entity work.genericRegister(ifelse_arch)
        generic map(bits=>2)
        port map(
            en => enable,
            clk => clock,
            reset => reset,
            d => din,
            q => qout
            );
    
    process
    begin
        -- initialize register
        wait for 10 ns;
        reset <= '0';
        wait for 10 ns;
        reset <= '1';
        wait;
    end process;
    
    process
    begin
        loop
            wait for 10 ns;
            control <= control + 1;
        end loop;
    end process;
    
    din <= std_logic_vector(control(4 downto 3));
    clock <= control(0);
    enable <= control(2);

end tb_arch;