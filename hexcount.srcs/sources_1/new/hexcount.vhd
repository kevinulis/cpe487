LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY hexcount IS
	PORT (
		clk_100MHz : IN STD_LOGIC;
		dig1 : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END hexcount;

ARCHITECTURE Behavioral OF hexcount IS
	COMPONENT counter IS
		PORT (
			clk : IN STD_LOGIC;
			count : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
			dig3 : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT leddec IS
		PORT (
			dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			data : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
		);
	END COMPONENT;
	SIGNAL S : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL D : STD_LOGIC_VECTOR (2 DOWNTO 0);
BEGIN
	C1 : counter
	PORT MAP(clk => clk_100MHz, count => S, dig3 => D);
	L1 : leddec
	PORT MAP(dig => D, data => S, anode => anode, seg => seg);
END Behavioral;
