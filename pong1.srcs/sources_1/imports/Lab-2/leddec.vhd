LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY leddec IS
	PORT (
		dig : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		data : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
	);
END leddec;

ARCHITECTURE Behavioral OF leddec IS
    SIGNAL disp : STD_LOGIC_VECTOR(3 DOWNTO 0);
BEGIN
--    IF dig = "00" THEN
--        disp <= data(3 DOWNTO 0);
--    ELSIF dig = "01" THEN
--        disp <= data(7 DOWNTO 4);
--    ELSIF dig = "10" THEN
--        disp <= data(11 DOWNTO 8);
--    ELSIF dig = "11" THEN
--        disp <= data(15 DOWNTO 12);
--    END IF;
    disp <= data(3 DOWNTO 0) WHEN dig = "000" ELSE -- 00 first
            data(7 DOWNTO 4) WHEN dig = "001" ELSE -- 01 second
	        data(11 DOWNTO 8) WHEN dig = "010" ELSE -- 10 third
	        data(15 DOWNTO 12) WHEN dig = "011" ELSE
	        "0000";-- 11 fourth display
	-- Turn on segments corresponding to 4-bit data word
	seg <= "0000001" WHEN disp = "0000" ELSE -- 0
	       "1001111" WHEN disp = "0001" ELSE -- 1
	       "0010010" WHEN disp = "0010" ELSE -- 2
	       "0000110" WHEN disp = "0011" ELSE -- 3
	       "1001100" WHEN disp = "0100" ELSE -- 4
	       "0100100" WHEN disp = "0101" ELSE -- 5
	       "0100000" WHEN disp = "0110" ELSE -- 6
	       "0001111" WHEN disp = "0111" ELSE -- 7
	       "0000000" WHEN disp = "1000" ELSE -- 8
	       "0000100" WHEN disp = "1001" ELSE -- 9
	       "0001000" WHEN disp = "1010" ELSE -- A
	       "1100000" WHEN disp = "1011" ELSE -- B
	       "0110001" WHEN disp = "1100" ELSE -- C
	       "1000010" WHEN disp = "1101" ELSE -- D
	       "0110000" WHEN disp = "1110" ELSE -- E
	       "0111000" WHEN disp = "1111" ELSE -- F
	       "1111111";
	-- Turn on anode of 7-segment display addressed by 2-bit digit selector dig
	-- We only need four displays
	anode <= "11111110" WHEN dig = "000" ELSE -- 0
	         "11111101" WHEN dig = "001" ELSE -- 1
	         "11111011" WHEN dig = "010" ELSE -- 2
	         "11110111" WHEN dig = "011" ELSE -- 3
	         "11101111" WHEN dig = "100" ELSE -- 4
	         "11011111" WHEN dig = "101" ELSE -- 5 
	         "10111111" WHEN dig = "110" ELSE -- 6
	         "01111111" WHEN dig = "111" ELSE -- 7
	         "11111111";
END Behavioral;
