----------------------------------------------------------------------------------
-- Author: Dr. Larry Pyeatt
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/11/2020
-- Lab 10
-- Design Name: LPU_instructionDecoder
-- Project Name: Lab10
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package instructionDecoderPKG is
type instruction_t is (CMPR, CMPI, RR, RRR, RI, RRI,
PCRL, LOAD, STORE, BR, BPCR, HCF, ILLEGAL);

type control_t is(
    Irle, -- instruction register latch enable : active low
    DIsel, -- select memory to register file input : active high
    immBsel, -- select immediate data onto B bus : active high
    PCDsel, -- select program counter onto D bus : active high
    PCAsel, -- select program counter onto A bus : active high
    PCle, -- enable program counter load : active low
    PCie, -- enable program counter increment : active low
    Dlen, -- enable load of register file : active low
    CCRle, -- enable load of flags register : active low
    
    -- The following five signals go to the Memory Control Register
    -- Together, they are the MCtrl input to the datapath
    memcen, -- enable memory : active low
    memoen, -- perform memory read : active low
    memwen, -- perform memory write : active low
    membyte, -- read/write byte instead of word : active low
    memhalf, -- read/write halfword instead of word : active low
    
    MARle, -- enable MAR/MDR to latch address/data : active low
    MCRle, -- enable memory control register latch : active low
    clken); -- enable the clock : active high
    
    type control_t_array is array (control_t) of std_logic;
end package;