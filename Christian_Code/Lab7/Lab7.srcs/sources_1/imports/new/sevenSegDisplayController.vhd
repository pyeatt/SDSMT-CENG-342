----------------------------------------------------------------------------------
-- Author: Christian Weaver & Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 03/31/2020
-- Lab 7
-- Design Name: sevenSegDisplayController
-- Project Name: Lab7
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- entity declaration for a 7-seg controller
entity sevenSegDisplayController is
    generic(
        adr_bits: integer := 3; -- log_2(number of displays)
        div_bits: integer := 20 -- sets refresh rate (divide by 2**div_bits)
        );
    port(
        en: in std_logic; -- chip enable (active low)
        wr: in std_logic; -- write enable (active low)
        reset: in std_logic; -- asynch reset (active low)
        address: in std_logic_vector(adr_bits-1 downto 0); -- address
        data_in: in std_logic_vector(4 downto 0); -- dp is on data(5)
        clock: in std_logic; -- clock
        sseg: out std_logic_vector(7 downto 0); -- segment drivers
        an: out std_logic_vector(2**adr_bits-1 downto 0) -- anodes
        );
end sevenSegDisplayController;


-- implementation of 7-seg controller using a structural design
architecture struct_arch of sevenSegDisplayController is
    signal count: std_logic_vector(div_bits-1 downto 0);
    signal to_7seg_decoder: std_logic_vector(4 downto 0);
begin

    -- a set of registers
    regs: entity work.genericRegisterFile(struct_arch)
        generic map(n_sel=>adr_bits)
        port map(
            en=>en,
            clk=>wr,
            rst=>reset,
            dsel=>address,
            d=>data_in(4 downto 0),
            qsel=>count(div_bits-1 downto div_bits-adr_bits),
            q=>to_7seg_decoder
            );
    
    -- a 7-segment decoder to convert data in the registers to signals
    -- for the 7-segment displays
    ssdec: entity work.hexTo7Seg(sop_arch)
        port map(
            hex=>to_7seg_decoder(3 downto 0),
            dp=>to_7seg_decoder(4),
            dpo=>sseg(7),
            sseg=>sseg(6 downto 0)
            );
    
    -- a decoder to select the 7-segment display anode
    andec: entity work.genericDecoder(proc_arch)
        generic map(bits=>adr_bits)
        port map(
            sel=>count(div_bits-1 downto div_bits-adr_bits),
            Y=>an
            );
    
    -- a counter to control switching between the displays
    cnt: entity work.genericCounter(ifelse_arch)
        generic map(bits=>div_bits)
        port map(
            clk=>clock,
            rst=>reset,
            q=>count
            );
    
end struct_arch;
