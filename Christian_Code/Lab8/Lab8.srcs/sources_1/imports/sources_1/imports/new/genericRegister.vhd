----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/30/2020
-- Lab 7
-- Design Name: genericRegister
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- entity declaration for a rising-edge triggered generic register
entity genericRegister is
    generic(bits: integer := 8); -- number of bits
    port(
        en: in std_logic; -- active low enable (enable for write)
        clk: in std_logic; -- rising edge-triggered
        reset: in std_logic; -- active low synchronous reset
        d: in std_logic_vector(bits-1 downto 0);
        q: out std_logic_vector(bits-1 downto 0)
        );
end genericRegister;


-- implementation of a generic register using an if-else statment
architecture ifelse_arch of genericRegister is
    signal latched_data: std_logic_vector(bits-1 downto 0);
begin
    process(en,clk,reset)
    begin
        if clk'event and clk='1' then -- rising-edge enabled
            if reset = '0' then -- if reset is enabled
                latched_data <= (others => '0'); -- clear data
            elsif en='0' then
                latched_data <= d; -- shift in new value
            end if;
        end if;
    end process;
    
    q <= latched_data;
end ifelse_arch;
