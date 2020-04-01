library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Time_Mux_7_Seg_Dec is
    generic( address_bits: natural := 3;
             division_bits: natural := 20
             );
    Port ( Data_in: in std_logic_vector(4 downto 0);
           Address: in std_logic_vector(address_bits-1 downto 0);
           write: in std_logic;
           enable: in std_logic;
           reset: in std_logic;
           clk: in std_logic;
           sseg_out: out std_logic_vector(7 downto 0);
           Anode_out: out std_logic_vector((2**address_bits)-1 downto 0)
           );
end Time_Mux_7_Seg_Dec;

architecture Behavioral of Time_Mux_7_Seg_Dec is
    signal Read_Address: std_logic_vector(division_bits-1 downto 0);
    signal Hex_Data: std_logic_vector(4 downto 0);
begin
    --data register file
    register_file: entity work.Register_File(Behavioral)
                   Generic Map(Bits=>5,Log_Registers=>address_bits)
                   Port Map(Data_in=>Data_in, clk=>clk, reset=>reset,
                            Write=>write, Write_Address=>Address, 
                            Read_Address=>Read_address(division_bits-1 downto division_bits-address_bits),
                            Data_out=>Hex_data,
                            enable=>enable); 
    --hex to seven segment decoder
    seven_segment: entity work.Seven_Segment_Display(Clayton_Gate_Arch)
                   Port Map(i_in=>Hex_Data(3 downto 0), DP_in=>Hex_Data(4),
                            O_out=>sseg_out(6 downto 0), DP_out=>sseg_out(7));
    --counter
    counter: entity work.Counter(Prof_method)
             Generic Map(Bits=>division_bits)
             Port Map(Reset=>Reset, clk=>clk, count=>Read_Address);
    --three to eight decoder, Want to make generic. Don't know how...
    three_by_eight: entity work.three_to_eight_decoder(Behavioral)
                    port map(Sel=>Read_Address(division_bits-1 downto division_bits-address_bits), 
                             Enable=>'0', An=>Anode_out);
    
end Behavioral;
