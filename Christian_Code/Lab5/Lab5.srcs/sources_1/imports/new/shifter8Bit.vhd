----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/02/2020
-- Lab 5
-- Design Name: shifter8Bit
-- Project Name: Lab5
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- This defines an 8-bit shifter
entity shifter8Bit is
    Port (din: in std_logic_vector(7 downto 0); -- input
          dout: out std_logic_vector(7 downto 0); --  output
          shamt: in std_logic_vector(2 downto 0); -- amount to be shifted
          func: in std_logic_vector(1 downto 0); -- type of shift-> 00: No shift, 
                                                                 -- 01: Logical shift left, 
                                                                 -- 10: Logical shift right, 
                                                                 -- 11: Arithmetic shift right 
          co: out std_logic); -- Last bit that was shifted out
end shifter8Bit;


-- This implements the 8-bit shifter using staged design
architecture proc_arch of shifter8Bit is
begin
    process(din, shamt, func)
        variable dinTemp: std_logic_vector(7 downto 0);
        variable doutTemp: std_logic_vector(7 downto 0);
        variable shamtTemp: std_logic_vector(2 downto 0); 
        variable funcTemp: std_logic_vector(1 downto 0);
        variable coTemp: std_logic;
        variable s0: std_logic_vector(9 downto 0) := (others => '0');
        variable s1: std_logic_vector(9 downto 0) := (others => '0');
        variable s2: std_logic_vector(9 downto 0) := (others => '0');
    begin
        -- initialize the variables with the input values
        dinTemp := din;
        shamtTemp := shamt; 
        funcTemp := func;
        
        -- No shift
        if funcTemp = "00" then
            doutTemp := dinTemp;
            coTemp := '0';
            
        -- Logical shift left
        elsif funcTemp = "01" then
            if shamtTemp(0) = '1' then 
                s0 := dinTemp(7 downto 0) & "00"; 
            else 
                s0(9 downto 1) := '0' & dinTemp;
            end if;
            if shamtTemp(1) = '1' then 
                s1 := s0(7 downto 1) & "000";
            else
                s1 := s0;
            end if;
            if shamtTemp(2) = '1' then
                s2 := s1(5 downto 1) & "00000";
            else
                s2 := s1;
            end if;    
            doutTemp := s2(8 downto 1);    
            coTemp := s2(9);
        
        -- Logical shift right + Arithmetic shift right (if positive)  
        elsif (funcTemp =  "10") or ((funcTemp = "11") and dinTemp(7) = '0') then
            if shamtTemp(0) = '1' then
                s0 := "00" & dinTemp(7 downto 0);
            else
                s0(8 downto 0) := dinTemp & '0';
            end if;
            if shamtTemp(1) = '1' then
                s1 := "000" & s0(8 downto 2);
            else 
                s1 := s0;
            end if;
            if shamtTemp(2) = '1' then
                s2 := "00000" & s1(8 downto 4);
            else
                s2 := s1;
            end if;
            doutTemp := s2(8 downto 1);
            coTemp := s2(0);   
            
        -- 11: Arithmetic shift right (if negative)     
        else
            if shamtTemp(0) = '1' then
                s0 := "11" & dinTemp(7 downto 0);
            else
                s0(8 downto 0) := dinTemp & '0';
            end if;
            if shamtTemp(1) = '1' then
                s1 := "111" & s0(8 downto 2);
            else
                s1 := s0;
            end if;
            if shamtTemp(2) = '1' then
                s2 := "11111" & s1(8 downto 4);
            else
                s2 := s1;
            end if;     
            doutTemp := s2(8 downto 1);    
            coTemp := s2(0); 
        end if;
    
        dout <= doutTemp;
        co <= coTemp;    
    end process;
end proc_arch;
