----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/30/2020
-- Lab 7
-- Design Name: LPU_RegisterFile
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity LPU_RegisterFile is
    generic(
        data_width: integer := 32;
        num_sel: integer := 3
        );
        port(
            Asel: in std_logic_vector(num_sel-1 downto 0);
            Bsel: in std_logic_vector(num_sel-1 downto 0);
            Dsel: in std_logic_vector(num_sel-1 downto 0);
            LoadEn: in std_logic;
            Din: in std_logic_vector(data_width-1 downto 0);
            Aout: out std_logic_vector(data_width-1 downto 0);
            Bout: out std_logic_vector(data_width-1 downto 0);
            Clock: in std_logic;
            Reset: in std_logic
            );
end LPU_RegisterFile;



