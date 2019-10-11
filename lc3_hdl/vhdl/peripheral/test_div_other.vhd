--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:20:57 10/04/2019
-- Design Name:   
-- Module Name:   C:/Users/user/Desktop/code/lc3calc/lc3_hdl/test_div_other.vhd
-- Project Name:  lc3_hdl
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DIVISION
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY test_div_other IS
END test_div_other;
 
ARCHITECTURE behavior OF test_div_other IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DIVISION
    PORT(
         NUMBER : IN  std_logic_vector(15 downto 0);
         NUMBER2 : IN  std_logic_vector(15 downto 0);
         START : IN  std_logic;
         RESULT : OUT  std_logic_vector(15 downto 0);
         RESIDUE : OUT  std_logic_vector(15 downto 0);
         FINISH : OUT  std_logic_vector(15 downto 0);
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal NUMBER : std_logic_vector(15 downto 0) := (others => '0');
   signal NUMBER2 : std_logic_vector(15 downto 0) := (others => '0');
   signal START : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal RESULT : std_logic_vector(15 downto 0);
   signal RESIDUE : std_logic_vector(15 downto 0);
   signal FINISH : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DIVISION PORT MAP (
          NUMBER => NUMBER,
          NUMBER2 => NUMBER2,
          START => START,
          RESULT => RESULT,
          RESIDUE => RESIDUE,
          FINISH => FINISH,
          clk => clk
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;

		NUMBER <= std_logic_vector (to_signed(10, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(3, NUMBER2'length));
		START <= '1';
		wait for 100 ns;
		--clear <= '1';
		--wait for 10 ns;
		--clear <= '0';
		
		NUMBER <= std_logic_vector (to_signed(10, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(-3	, NUMBER2'length));
		START <= '1';
		wait for 100 ns;
		
		NUMBER <= std_logic_vector (to_signed(-10, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(3, NUMBER2'length));
		START <= '1';
		wait for 100 ns;
		
		NUMBER <= std_logic_vector (to_signed(-10, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(-3, NUMBER2'length));
		START <= '1';
		wait for 100 ns;
		
		NUMBER <= std_logic_vector (to_signed(10, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(2, NUMBER2'length));
		START <= '1';
		wait for 100 ns;
		
		NUMBER <= std_logic_vector (to_signed(10, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(-2, NUMBER2'length));
		START <= '1';
		wait for 100 ns;
		
		NUMBER <= std_logic_vector (to_signed(10, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(0, NUMBER2'length));
		START <= '1';
		
		wait for 100 ns;
		NUMBER <= std_logic_vector (to_signed(0, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(10, NUMBER2'length));
		START <= '1';
		wait for 100 ns;
		

		NUMBER <= std_logic_vector (to_signed(-32768, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(2, NUMBER2'length));
		START <= '1';
		wait for 100 ns;	
		-- at doing the absolute value we get overflow


		NUMBER <= std_logic_vector (to_signed(-32767, NUMBER'length));
		NUMBER2 <= std_logic_vector (to_signed(2, NUMBER2'length));
		START <= '1';
		wait for 100 ns;
		
      wait for clk_period*10;



      wait;
   end process;

END;
