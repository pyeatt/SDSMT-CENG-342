library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LPU is
    generic(
            Bits: integer:=32; -- number of bits
            Nsel: integer:=3 -- number of address bits
            );
    Port ( 
            Asel: in std_logic_vector(Nsel-1 downto 0);
            Bsel: in std_logic_vector(Nsel-1 downto 0);
            Dsel: in std_logic_vector(Nsel-1 downto 0);
            DIsel: in std_logic;
            Dlen: in std_logic;
            Data_in: in std_logic_vector(Bits-1 downto 0);
            Data_out: out std_logic_vector(Bits-1 downto 0);
            PCAsel, PCie, PCle, PCDsel: in std_logic;
            IMMBsel: in std_logic;
            IMM: in std_logic_vector(Bits-1 downto 0);
            ALUfunc: in std_logic_vector(3 downto 0);
            MCtrl: in std_logic_vector(4 downto 0);
            CCRle: in std_logic;
            Flags: out std_logic_vector(3 downto 0);
            MARle, MCRle: in std_logic;
            Control: out std_logic_vector(4 downto 0);
            Adress: out std_logic_vector(Bits-1 downto 0);
            reset, clk: in std_logic
          );
end LPU;

architecture arch of LPU is
    attribute mark_debug: string;
    signal A_bus, B_bus, D_bus: std_logic_vector(Bits-1 downto 0);
    signal A_alu, B_alu: unsigned(Bits-1 downto 0);
    signal ALU_out: std_logic_vector(Bits-1 downto 0);
    signal PC_out: std_logic_vector(Bits-1 downto 0);
    attribute mark_debug of PC_out: signal is "true";
    signal CCR_in, CCR_out: std_logic_vector(3 downto 0);
    signal Register_in: std_logic_vector(Bits-1 downto 0); 
    signal alu_ci: std_logic_vector(0 downto 0);
    signal AdressI: std_logic_vector(Bits-1 downto 0);
    attribute mark_debug of AdressI: signal is "true";
begin

    Adress <= AdressI;
    MCR: entity work.MCR(arch) 
            port map(input => MCtrl, output => Control, Enable => MCRle,
                        clk => clk, reset => reset);
                    
    MDR: entity work.MDR(arch)
            generic map (Bits => Bits)
            port map( input => B_bus, output => Data_out, Enable => MARle,
                        clk => clk, reset => reset);
                        
    MAR: entity work.MAR(arch)
            generic map (Bits => Bits)
            port map( input => D_bus, output => AdressI, Enable => MARle,
                        clk => clk, reset => reset);
                        
    CCR: entity work.CCR(arch)
            port map( input => CCR_in, output => CCR_out, Enable => CCRle,
                        clk => clk, reset => reset);
                        
    Flags <= CCR_out;
    
    -- 2 input muxes, select which gets loaded into alu input
    A_alu <= unsigned(A_bus) when PCAsel = '0' else unsigned(PC_out);
    B_alu <= unsigned(B_bus) when IMMBsel = '0' else unsigned(IMM);
    alu_ci(0) <= CCR_out(2); 
    ALU: entity work.Generic_ALU(cheating)
        generic map( N_bit => Bits)
        port map( A => A_alu, 
        B => B_alu, 
        F => ALUfunc, 
        Ci => alu_ci,
                    Co => CCR_in(2), Z => CCR_in(1), N => CCR_in(0), 
                    V => CCR_in(3),
                     R => ALU_out);
    
    PC: entity work.PC(arch)
        generic map( Bits => Bits, Increment => 2)
        port map( input => ALU_out, output => PC_out, Load =>PCle,
                    IncE => PCie, clk => clk, reset => reset);            
                    
    D_bus <= ALU_out when PCDsel = '0' else PC_out;
    
    Register_in <= D_bus when DIsel = '0' else Data_in;
    
    RegisterFile: entity work.register_file(Behavioral)
                    generic map( Bits => Bits, Nsel => Nsel)
                    port map( Asel => Asel, Bsel => Bsel, Dsel => Dsel, 
                                DIsel => Dlen, Din => Register_in, 
                                A => A_bus, B => B_bus, clk => clk, 
                                reset => reset);
     
end arch;
