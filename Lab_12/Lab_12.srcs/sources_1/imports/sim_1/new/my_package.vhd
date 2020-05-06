library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package my_package is

  type slv_array_5 is array(natural range <>) of std_logic_vector(4 downto 0);
  type slv_array_8 is array(natural range <>) of std_logic_vector(7 downto 0);
  type slv_array_16 is array(natural range <>) of std_logic_vector(15 downto 0);
  type slv_array_18 is array(natural range <>) of std_logic_vector(17 downto 0);
  type slv_array_32 is array(natural range <>) of std_logic_vector(31 downto 0);

  -- The following instruction types are supported:
  -- Compare registers
  -- Compare immediate
  -- Register-Register-Register
  -- Register-Register-Immediate
  -- Register-Register
  -- Register-Immediate
  -- PC-relative Load
  -- Load
  -- Store
  -- Branch/branch and link with register target
  -- Branch/branch and link with  Program Counter Relative target
  -- Halt and catch fire
  type instruction_t is (CMPR, CMPI, RR, RRR, RI, RRI,
                         PCRL, LOAD, STORE, BR, BPCR, HCF, ILLEGAL);

  type state_t is (START, FETCHWAIT, FETCH1, FETCH2, EX1, LDST);

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

  -- Define some control words that the sequencer can send.  Also
  -- define a mask that the sequencer can use to modify the control
  -- word coming from the instruction decoder for load/store
  -- operations.
  
  -- START_cw: Don't do anything. Make sure that control lines to
  -- memory are de-asserted
  constant START_cw     : control_t_array := "10000111111111101";

  -- FETCHWAIT: Make sure that control lines to memory are de-asserted
  constant FETCHWAIT_cw : control_t_array := "10010111111111101";

  -- FETCH1: Latch PC into MAR, increment PC, and assert halfword
  -- memory read
  constant FETCH1_cw    : control_t_array := "10010101100110001";

  -- FETCH2: Maintain memory read state, latch IR. next state is
  -- FETCH2
  constant FETCH2_cw    : control_t_array := "00000111111111111";

  -- FETCH2_proceed: End memory read, latch IR. next state is EX1
  constant FETCH2_proceed_cw    : control_t_array := "00000111111111101";
  
  -- EX1: 'Or' this mask with the control word coming from the
  -- instruction decoder in the EX1 state to de-assert control lines
  -- to memory when Mrts=1 (also used in the LDST state when Mrte=0)
  constant EX1_mask     : control_t_array := "10000000011111101";

  -- Some useful functions...
  function to_string ( a: std_logic_vector) return string;
  
  function "and" (Left, Right: control_t_array) return control_t_array;
    
  function "or" (Left, Right: control_t_array) return control_t_array;
    
  function to_std_logic_vector(ctr: control_t_array) return std_logic_vector;

  type flag_t is (n,z,c,v);

  type flag_array is array(flag_t) of std_logic;
  
end package my_package;

package body my_package is
  
  function "and" (Left, Right: control_t_array) return control_t_array is
    variable rval : control_t_array;
    variable i : control_t;
  begin
    for i in control_t loop
      rval(i) := Left(i) and Right(i); 
    end loop;
    return rval;
  end function "and";


  function "or" (Left, Right: control_t_array) return control_t_array is
    variable rval : control_t_array;
    variable i : control_t;
  begin
    for i in control_t loop
      rval(i) := Left(i) or Right(i); 
    end loop;
    return rval;
  end function "or";


  function to_std_logic_vector(ctr: control_t_array) return std_logic_vector is
    variable rval : std_logic_vector(control_t'pos(control_t'left) to
                                     control_t'pos(control_t'right));
    variable i : control_t;
  begin
    for i in control_t loop
      rval(control_t'pos(i)) := ctr(i);
    end loop;
    return rval;
  end function to_std_logic_vector;
    
  function to_string ( a: std_logic_vector) return string is
    variable b : string (1 to a'length) := (others => NUL);
    variable stri : integer := 1; 
  begin
    for i in a'range loop
      b(stri) := std_logic'image(a((i)))(2);
      stri := stri+1;
    end loop;
    return b;
  end function;

end package body my_package;
