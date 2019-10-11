library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsub is
	Port(
		sain,sbin,scin : in STD_LOGIC;
		sso,sco: out STD_LOGIC
		);
end fsub;

architecture Behavioral of fsub is
	begin
	sso <= sain xor sbin xor scin;
	sco <= (not sain and sbin) or (scin and (not sain xor sbin));
end Behavioral;