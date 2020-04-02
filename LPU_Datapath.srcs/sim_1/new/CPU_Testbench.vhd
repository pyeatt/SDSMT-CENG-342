--Author: Clayton Heeren
--Date: March 29, 2020
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU_Testbench is
end CPU_Testbench;

architecture Behavioral of CPU_Testbench is
    constant log_registers: natural := 3;
    constant Log_bits: natural := 3;
    signal reset: std_logic := '0';
    signal clock: std_logic := '0';
    signal Asel, Bsel, Dsel: std_logic_vector(log_registers-1 downto 0);
    signal DIsel, Dlen: std_logic;
    signal data_in: std_logic_vector((2**log_Bits)-1 downto 0);
    signal data_out: std_logic_vector((2**log_Bits)-1 downto 0);
    signal PCAsel, PCle, PCie, PCDsel: std_logic;
    signal IMMBsel: std_logic;
    signal IMM: std_logic_vector((2**log_bits)-1 downto 0);
    signal ALUfunc: std_logic_vector(3 downto 0);
    signal CCRle: std_logic;
    signal Flags: std_logic_vector(3 downto 0);
    signal MARle: std_logic;
    signal MCtrl: std_logic_vector(3 downto 0);
    signal MCRle: std_logic;
    signal Control: std_logic_vector(3 downto 0);
    signal Address: std_logic_vector((2**log_bits)-1 downto 0);
begin
    --unit under test
    UUT: entity work.CPU_Datapath(Behavioral)
         Generic Map(Log_bits=>Log_bits, Log_registers=>Log_registers)
         Port Map(reset=>reset, clock=>clock, Asel=>Asel, Bsel=>Bsel,
                  Dsel=>Dsel, DIsel=>DIsel, Dlen=>Dlen, data_in=>data_in,
                  data_out=>data_out, PCAsel=>PCAsel, PCle=>PCle, PCie=>PCie,
                  PCDsel=>PCDsel, IMMBsel=>IMMBsel, IMM=>IMM, ALUfunc=>ALUfunc,
                  CCRle=>CCRle, Flags=>Flags, MARle=>MARle, Control=>Control,
                  Address=>Address, MCtrl=>MCtrl, MCRle=>MCRle);
    --initialize
    process
    begin
        wait for 10ns;
        reset <= '1';
        wait;
    end process;
    --clock
    process
    begin
        wait for 5ns;
        loop
            clock <= not clock;
            wait for 10ns;
        end loop;
    end process;
    --load register file
    process
    begin
        wait for 20ns;
        DIsel <= '1';
        Dlen <= '0';
        Dsel <= "000";
        data_in <= "10101010";--0xAA
        wait for 20ns;
        Dsel <= "001";
        data_in <= "10111010";--0xBA
        wait for 20ns;
        Dsel <= "010";
        data_in <= "11011001";--0xD9
        wait for 20ns;
        Dsel <= "011";
        data_in <= "11110011";--0xF3
        wait for 20ns;
        Dsel <= "100";
        data_in <= "11001111";--0xCF
        wait for 20ns;
        Dsel <= "101";
        data_in <= "00011000";--0x18
        wait for 20ns;
        Dsel <= "110";
        data_in <= "10001110";--0x8E
        wait for 20ns;
        Dsel <= "111";
        data_in <= "00000011";--0x03
        wait for 20ns;
        Dlen <= '1';
        MARle <= '0';
        MCRle <='0';
        CCRle <= '0';
        PCie <= '0';
        IMMBsel <= '0';
        PCAsel <='0';
        PCDsel <= '1';
        --test Program counter increment
        IMMBsel <= '1';--pass in immediate
        IMM <= "00000001";
        wait for 580ns;
        --test program counter load
        PCie <= '1';
        PCle <= '0';
        ALUfunc <= "1000";--pass B
        wait for 20ns;
        IMM <= "11110000";
        wait for 20ns;
        IMM <= "00110110";
        wait for 40ns;
    end process;
    --
end Behavioral;
--to keep simulation short, replace ALUfunc input to whatever functions you want to test
        --test PASSB from registers
        --ALUfunc <= "1000";
--        Asel <= "111";
--        for I in 0 to 7 loop
--            Bsel <= std_logic_vector(to_unsigned(I,3));
--            wait for 20ns;
--        end loop;
        --test LSL from registers
--        ALUfunc <= "1010";
--        for I in 0 to 7 loop
  --          Bsel <= std_logic_vector(to_unsigned(I,3));
    --        wait for 20ns;
      --  end loop;
        --test LSR from registers
        --ALUfunc <= "1100";
        --for I in 0 to 7 loop
         --   Bsel <= std_logic_vector(to_unsigned(I,3));
           -- wait for 20ns;
        --end loop;
        --test ASR from registers
       -- ALUfunc <= "1110";
        --for I in 0 to 7 loop
          --  Bsel <= std_logic_vector(to_unsigned(I,3));
            --wait for 20ns;
       -- end loop;