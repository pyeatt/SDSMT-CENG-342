--Author: Clayton Heeren
--Date: April 1, 2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Wrapper is
    generic( log_Bits: natural := 2;--4 bits
             Log_Registers: natural :=2
             );
    Port ( reset: in std_logic;--reset
           clock: in std_logic;--clock
           Asel, Bsel, Dsel: in std_logic_vector(log_registers-1 downto 0);--6 slide switches
           --DIsel: in std_logic;
           Dlen: in std_logic;--slide switch
           data_in: in std_logic_vector((2**log_bits)-1 downto 0);--4 slide switches
           data_out: out std_logic_vector((2**log_bits)-1 downto 0);--4 LEDs
           --PCAsel: in std_logic;
           --PCle: in std_logic;
           --PCie: in std_logic;
           PCDsel: in std_logic;--push button
           IMMBsel: in std_logic;--push button
           --IMM: in std_logic_vector((2**log_bits)-1 downto 0);
           ALUfunc: in std_logic_vector(3 downto 0);--4 slide switches
           --CCRle: in std_logic;
           Flags: out std_logic_vector(3 downto 0);--4 LEDs
           --MARle: in std_logic;
           --MCtrl: in std_logic_vector(3 downto 0);
           --MCRle: in std_logic;
           Control: out std_logic_vector(3 downto 0);
           Address: out std_logic_vector((2**log_bits)-1 downto 0)--4 LEDs
           );
end Wrapper;

architecture Behavioral of Wrapper is
    
begin
    CPU: entity work.CPU_datapath(behavioral)
         Generic Map(log_bits=>log_bits, Log_Registers=>log_registers)
         Port Map(reset=>reset, clock=>clock, Asel=>Asel, Bsel=>Bsel,
                  Dsel=>Dsel, DIsel=>'1', Dlen=>Dlen, data_in=>data_in,
                  data_out=>data_out, PCAsel=>'0', PCle=>'1', PCie=>'0',
                  PCDsel=>PCDsel, IMMBsel=>IMMBsel, IMM=>"0001", ALUfunc=>ALUfunc,
                  CCRle=>'0', Flags=>Flags, MARle=>'0', Control=>Control,
                  Address=>Address, MCtrl=>"0110", MCRle=>'0');

end Behavioral;
