library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

entity div16 is
	Port(clr,clk,start: in STD_LOGIC;
	A,B: in STD_LOGIC_VECTOR (15 downto 0);
	Q,R: out STD_LOGIC_VECTOR (15 downto 0));
end div16;

architecture Behavioral of div16 is
type state_type is (sx_in, sx_proc, sx_done);
signal state_now , state_next : state_type;
signal B_zero, M : std_logic;
signal X_now, X_next, Y_now, Y_next, Z_now,n_now,n_next : STD_LOGIC_VECTOR (15 downto 0);

component sub16 is
	Port (A,B : in STD_LOGIC_VECTOR (15 downto 0);
	R : out STD_LOGIC_VECTOR (15 downto 0);
	Z : out STD_LOGIC);
	
end component;

begin
U0 : sub16 port map(
A => X_now, B => Y_now,
R => Z_now, Z => M
);


process(clr,clk)
begin 
	if clr = '1' then
	X_now <= x"0000";
	Y_now <= x"0000";
	n_now <= x"0000";

elsif clk'event and clk = '1' then
	state_now <= state_next;
	X_now <= X_next;
	Y_now <= Y_next;
	n_now <= n_next;
end if;
end process;

B_zero <= B(15) or B(14) or B(13) or B(12) or B(11) or B(10) or B(9) or B(8) or B(7) or B(6) or B(5) or B(4) or B(3) or B(2) or B(1) or B(0);
process(start, A, B, state_now,X_now,Y_now,n_now,B_zero,M,Z_now)
begin
state_next <= state_now;
X_next <= X_now;
Y_next <= Y_now;
n_next <= n_now;

case state_now is 
	when sx_in =>
	Q <= x"0000";
	R <= x"0000";
	if start = '1' then 
		if B_zero = '1' then
		X_next <= A;
		Y_next <= B;
		n_next <= x"0000";
		state_next <= sx_proc;
		end if;
	
	end if;
	
	when sx_proc =>
	Q <= n_now;
	R <= X_now;
	if M = '1' then
		X_next <= X_now;
		n_next <= n_now;
		state_next <= sx_done;
		else
			X_next <= Z_now;
			n_next <= n_now + 1;
	end if;
	
	when sx_done =>
	
	Q <= n_now;
	R <= X_now;
	
	end case;
	


end process;

end Behavioral;
