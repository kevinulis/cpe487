LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY counter IS
	PORT (
		clk : IN STD_LOGIC;
		dig3 : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		count : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END counter;

ARCHITECTURE Behavioral OF counter IS
	SIGNAL cnt : STD_LOGIC_VECTOR (28 DOWNTO 0); -- 29 bit counter
	SIGNAL dig : STD_LOGIC_VECTOR (2 DOWNTO 0);
BEGIN
	PROCESS (clk)
	BEGIN
		IF clk'EVENT AND clk = '1' THEN -- on rising edge of clock
			cnt <= cnt + 2; -- increment counter
		END IF;
		IF cnt (28 DOWNTO 0) = "00000000000000000000000000000" AND clk'EVENT AND clk = '1' THEN 
	    dig <= dig + 1;
	    END IF;
	END PROCESS;
	count <= cnt (28 DOWNTO 25);
	dig3 <= dig;
END Behavioral;
