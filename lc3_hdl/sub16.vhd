library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity sub16 is
	Port(A,B : in STD_LOGIC_VECTOR (15 downto 0);
	R : out STD_LOGIC_VECTOR (15 downto 0);
	Z : out STD_LOGIC);
end sub16;

architecture Behavioral of sub16 is
signal scx : STD_LOGIC_VECTOR (15 downto 1);
constant low : STD_LOGIC := '0';

component fsub is
port	(sain,sbin,scin: in STD_LOGIC;
	sco,sso : out STD_LOGIC);
end component;

begin
	U1 : fsub port map  (sain=>A(0),  sbin=>B(0), scin=> low    ,sco => scx(1),  sso => R(0));
	U2 : fsub port map  (sain=>A(1),  sbin=>B(1), scin=> scx(1) ,sco => scx(2),  sso => R(1));
	U3 : fsub port map  (sain=>A(2),  sbin=>B(2), scin=> scx(2) ,sco => scx(3),  sso => R(2));
	U4 : fsub port map  (sain=>A(3),  sbin=>B(3), scin=> scx(3) ,sco => scx(4),  sso => R(3));
	U5 : fsub port map  (sain=>A(4),  sbin=>B(4), scin=> scx(4) ,sco => scx(5),  sso => R(4));
	U6 : fsub port map  (sain=>A(5),  sbin=>B(5), scin=> scx(5) ,sco => scx(6),  sso => R(5));
	U7 : fsub port map  (sain=>A(6),  sbin=>B(6), scin=> scx(6) ,sco => scx(7),  sso => R(6));
	U8 : fsub port map  (sain=>A(7),  sbin=>B(7), scin=> scx(7) ,sco => scx(8),  sso => R(7));
	U9 : fsub port map  (sain=>A(8),  sbin=>B(8), scin=> scx(8) ,sco => scx(9),  sso => R(8));
	U10 : fsub port map (sain=>A(9),  sbin=>B(9), scin=> scx(9) ,sco => scx(10), sso => R(9));
	U11 : fsub port map (sain=>A(10), sbin=>B(10),scin =>scx(10),sco => scx(11), sso => R(10));
	U12 : fsub port map (sain=>A(11), sbin=>B(11),scin =>scx(11),sco => scx(12), sso => R(11));
	U13 : fsub port map (sain=>A(12), sbin=>B(12),scin =>scx(12),sco => scx(13), sso => R(12));
		U14 : fsub port map (sain=>A(13), sbin=>B(13),scin =>scx(13),sco => scx(14), sso => R(13));
	U15 : fsub port map (sain=>A(14), sbin=>B(14),scin =>scx(14),sco => scx(15), sso => R(14));
	U16 : fsub port map (sain=>A(15), sbin=>B(15),scin =>scx(15),sco => Z      , sso => R(15));
end Behavioral;