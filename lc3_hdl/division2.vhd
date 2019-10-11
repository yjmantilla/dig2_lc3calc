----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:13:33 07/18/2019 
-- Design Name: 
-- Module Name:    TOP - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DIVISION is
    Port ( NUMBER : in  STD_LOGIC_VECTOR (15 downto 0);
	 			NUMBER2 : in std_logic_vector(15 downto 0);
				START : in std_logic;
				RESULT : out STD_LOGIC_vector(15 downto 0);
				RESIDUE: out STD_LOGIC_VECTOR(15 downto 0);
				FINISH: out STD_LOGIC_VECTOR(15 downto 0);
				clk : in std_logic
				);
			  

end DIVISION;

architecture Behavioral of DIVISION is

type estadosdiv is(loading, calcline);
signal divstate: estadosdiv := loading;
begin-----------------------------------------------------------------
 


division:process(clk, divstate)
variable dividend: std_logic_vector(15 downto 0);
variable divisor: std_logic_vector(15 downto 0);
variable counter: std_logic_vector(15 downto 0);
variable parcial: std_logic_vector(15 downto 0);

begin
	if(rising_edge(clk))then
		if(start = '1') then
				case divstate is	
					when loading =>
						divstate <= calcline;
					when calcline =>
						counter := "0000000000000000";
						dividend := NUMBER;
						divisor := NUMBER2;
						-- make number positive
						if(dividend(15) = '1' and divisor(15) =  '1') then
							dividend := not(dividend) + '1';
							divisor := not(divisor) + '1';
							parcial := dividend;
						elsif(dividend(15) = '1') then
							dividend := not(dividend) + '1';
							parcial := dividend;
						elsif(divisor(15) = '1') then
							divisor := not(divisor) + '1';
							parcial := dividend;
						else
							dividend := dividend;
							divisor := divisor;
							parcial := dividend;
						end if;
						--special cases
						if(dividend < divisor) then
							RESULT <= "0000000000000000";
							RESIDUE <= divisor;
							FINISH <= x"8000";
						elsif(divisor = "000000000000000" or divisor = "100000000000000") then
							RESULT <= x"8000";
							RESIDUE <= x"8000";
							FINISH <= x"8000";
						elsif(dividend = "000000000000000" or dividend = "100000000000000") then
							RESULT <= "0000000000000000";
							RESIDUE <= "0000000000000000";
							FINISH <= x"8000";
						else
							--Ciclo para calcular las lineas a sumar
--							while( parcial(15) = '0' and parcial > "0000000000000000") loop --parcial(15) = '0' and
--									--while positive and greater than 0
--							parcial := parcial - divisor;
--								counter := counter + '1';
--							end loop;


							for i in 1 to 20 loop
									--while positive and greater than 0
							parcial := parcial - divisor;
							counter := counter + '1';
							
								if ( parcial(15) = '1' or parcial = "0000000000000000") then
									exit;
								end if;
							end loop;
					
							if(parcial = x"0000") then --=x"0"
							-- if positive
								if(NUMBER(15) = '1' xor NUMBER2(15) = '1') then --give sign
								
									RESULT <= not(counter)+ '1';
									RESIDUE <= "0000000000000000";
									FINISH <= x"8000";
								else
									RESULT <= counter;
									RESIDUE <= "0000000000000000";
									FINISH <= x"8000";
								end if;
							else -- was negative , we did one more
								counter := counter - 1;
								parcial := parcial + divisor;
								if(NUMBER(15) = '1' xor NUMBER2(15) = '1') then
									RESULT <= not(counter) +'1';
									--RESIDUE <= not(parcial) + '1';
									FINISH <= x"8000";
								else
									RESULT <= counter;
									RESIDUE <= parcial;
									FINISH <= x"8000";
								end if;
								if (NUMBER(15) = '1') then
									RESIDUE <= not (parcial) +1;
								else 
									RESIDUE <= parcial;
								end if;
								divstate <= calcline;
							end if;
						end if;
						----------------------------------------------------------
					---------------------------------------------------------------
					end case;
			end if;
		end if;
   end process;
	
	
end Behavioral;

