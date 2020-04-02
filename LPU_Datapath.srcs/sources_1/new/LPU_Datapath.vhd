--Author: Clayton Heeren
--Date: March 29, 2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU_Datapath is
    Generic( log_Bits: natural := 5;
             Log_Registers: natural :=3
             );
    Port ( reset: in std_logic;
           clock: in std_logic;
           Asel, Bsel, Dsel: in std_logic_vector(log_registers-1 downto 0);
           DIsel, Dlen: in std_logic;
           data_in: in std_logic_vector((2**log_Bits)-1 downto 0);
           data_out: out std_logic_vector((2**log_Bits)-1 downto 0);
           PCAsel, PCle, PCie, PCDsel: in std_logic;
           IMMBsel: in std_logic;
           IMM: in std_logic_vector((2**log_bits)-1 downto 0);
           ALUfunc: in std_logic_vector(3 downto 0);
           CCRle: in std_logic;
           Flags: out std_logic_vector(3 downto 0);
           MARle: in std_logic;
           MCtrl: in std_logic_vector(3 downto 0);
           MCRle: in std_logic;
           Control: out std_logic_vector(3 downto 0);
           Address: out std_logic_vector((2**log_bits)-1 downto 0)
           );
end CPU_Datapath;

architecture Behavioral of CPU_Datapath is
    signal A_bus, B_bus, A_ALU, B_ALU, ALU_out, PC_out, D_bus, MAR_out, D_mux_out: std_logic_vector((2**log_bits)-1 downto 0);
    signal CCR_out: std_logic_vector(3 downto 0);
    signal ALU_flags_sig: std_logic_vector(3 downto 0);
begin
    --Register file 8X32-bits
    with DIsel select
        D_mux_out <= data_in when '1',
                     D_bus when others;
    reg_file: entity work.Register_File(behavioral)
              generic map(Bits=>2**log_bits, Log_Registers=>log_registers)
              Port Map(Data_in=>D_mux_out, clk=>clock, reset=>reset, write=>Dlen,
                       Write_Address=>Dsel, A_select=>Asel, B_select=>Bsel,
                       A_out=>A_bus, B_out=>B_bus);
    --Program Counter
    Pro_count: entity work.PC_Counter(Arch)
               Generic Map(Bits=>2**log_bits)
               Port Map(Reset=>reset, clk=>clock, count=>PC_out, 
                        PC_in=>ALU_out((2**log_bits)-1 downto 1), PC_le=>PCle,
                        PC_ie=>PCie);
    --D bus
    with PCDsel select
        D_bus <= ALU_out when '0',
                 PC_out when others;
    --ALU
    with PCAsel select
        A_ALU <= A_bus when '0',
                 PC_out when others;
    with IMMBsel select
        B_ALU <= B_bus when '0',
                 IMM when others;
    ALU: entity work.Arithmetic_Logic_Unit(Behavioral)
         Generic Map(log_bits=>log_bits)
         Port Map(A_in=>A_ALU, B_in=>B_ALU, Carry_in=> CCR_out(1),
                  Func=>ALUfunc, R_out=>ALU_out, Flags=>ALU_flags_sig);
    --CCR
    CCR: entity work.Generic_register(Behavioral)
         Generic Map(Bits=>4)
         Port Map(clk=>clock, reset=>reset, enable=>CCRle, 
                  data_in=>ALU_flags_sig, data_out=>CCR_out);
    --MAR
    MAR: entity work.Generic_Register(Behavioral)
         Generic Map(Bits=>(2**log_bits))
         Port Map(clk=>clock, reset=>reset, enable=>MARle,
                  data_in=>D_bus, data_out=>Address);
    --MDR
    MDR: entity work.generic_register(behavioral)
         Generic Map(Bits=>2**log_bits)
         Port Map(clk=>clock, reset=>reset, enable=>MARle,
                  data_in=>B_bus, data_out=>data_out);
    --MCR
    MCR: entity work.generic_register(behavioral)
         Generic Map(Bits=>4)
         Port Map(clk=>clock, reset=>reset, enable=>MCRle,
                  Data_in=>MCtrl, data_out=>control);
    --remaining outputs
    flags <= CCR_out;
end Behavioral;
