----------------------------------------------------------------------------------
-- Author: Christian Weaver
-- Class: CENG-342
-- Instructor: Dr. Pyeatt
-- Date: 04/16/2020
-- Lab 10
-- Design Name: LPU_instructionDecoder
-- Project Name: Lab10
----------------------------------------------------------------------------------


entity LPU_datapathWithInstructionDecoder is
    port(
        I : in std_logic_vector(15 downto 0); -- instruction to decode
        CCRflags: in CCR_t_array; -- stores flags from CCR
        Address: out std_logic_vector(data_width-1 downto 0); -- Address provided to Memory and I/O devices for read and write operations
        Control: out std_logic_vector(3 downto 0); -- ???
        Reset: in std_logic; -- A `0' indicates that all registers should be set to zero. (Synchronous reset is preferred!)
        Clock: in std_logic -- Clock signal provided to all registers
        );
end LPU_datapathWithInstructionDecoder;

architecture Behavioral of LPU_datapathWithInstructionDecoder is

begin


end Behavioral;
