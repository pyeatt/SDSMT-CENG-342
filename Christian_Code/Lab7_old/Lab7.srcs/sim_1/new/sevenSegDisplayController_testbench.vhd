----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/14/2020
-- Lab 7
-- Design Name: sevenSegDisplayController_testbench
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity sevenSegDisplayController_testbench is
end sevenSegDisplayController_testbench;


architecture tb_arch of sevenSegDisplayController_testbench is
    signal en: std_logic:='1'; -- chip enable (active low)
    signal wr: std_logic:='1'; -- write enable (active low)
    signal reset: std_logic:='1'; -- asynch reset (active low)
    signal clock: std_logic:='1'; -- clock
    signal address: std_logic_vector(2 downto 0):="000";
    signal data_in: std_logic_vector(7 downto 0):="00000000";
    signal sseg: std_logic_vector(7 downto 0):="00000000";
    signal an: std_logic_vector(7 downto 0):="00000000";
    signal data_count:unsigned(7 downto 0) := "00000000" ;
begin
    disp: entity work.sevenSegDisplayController(struct_arch)
        generic map(
            adr_bits=>3,
            div_bits=>3
            )
        port map(
            en => en,
            wr => wr,
            reset => reset,
            clock => clock,
            address => address,
            data_in => data_in,
            sseg => sseg,
            an => an
            );
    
    process
        variable i:natural;
    begin
        wait for 30 ns;
        loop
            for i in 0 to 7 loop
                data_in <= std_logic_vector(data_count);
                address <= std_logic_vector(to_unsigned(i,3));
                en<='0';
                wait for 2 ns;
                wr<='0';
                wait for 5 ns;
                en<='1';
                wr<='1';
                data_count <= data_count + 1;
            end loop;
            wait for 400ns;
        end loop;
    end process;
    
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
        loop
            clock <= not clock;
            wait for 10 ns;
        end loop;
    end process;


end tb_arch;