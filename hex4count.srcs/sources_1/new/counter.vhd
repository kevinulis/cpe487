-- counter.vhd --

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY counter IS
	PORT (
		clk : IN STD_LOGIC;
		RESET : IN STD_LOGIC;
		count : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- NEED REVISE! 16 bits
		mpx : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)); -- NEW ONE ADD! send signal to select displays
		--btn: IN STD_LOGIC;
END counter;

ARCHITECTURE Behavioral OF counter IS
	SIGNAL cnt : STD_LOGIC_VECTOR (38 DOWNTO 0); -- 39-bit counter
	type state_type is (A, B, C, D, E, F);
	SIGNAL PS, NS : state_type;
	SIGNAL inp : STD_LOGIC;
	SIGNAL bool : STD_LOGIC;
	--SIGNAL A, B, C, D, E, F : STD_LOGIC;
	SIGNAL outp : STD_LOGIC;
BEGIN
    --cnt <= "000000000000000000000000000000000000000";
    clockAndReset: process(clk, RESET)
     begin
     	if (RESET = '1') then PS <= A;
     	--elsif (RESET = '1') then count <= "0000000000000000";
         elsif (rising_edge(clk)) then PS <= NS;
         end if;
   	end process clockAndReset;
	mainProcess: PROCESS (clk, inp, outp)
	BEGIN
	inp <= cnt (29); -- input is the MSB of the counter
	--outp <= '0';-- Pre assign output
	--if clk'EVENT AND clk = '1' then PS <= NS;
	--end if;
	case PS is
	when A =>
	   if (inp='1')then outp <= '0'; NS<=B;
	    --set output to zero
	    -- If input is zero, loop to A
	   else NS <= A; -- input is one, go to B state
	   end if;
	when B =>
	   if (inp='1')then outp <= '0'; NS<=C;
	   else NS <= A; -- input is one, go to C state
	   end if;
	when C =>
	   if (inp='1')then outp <= '0'; NS<=D;
	   else NS <= A; -- input is one, go to D state
	   end if;
	when D =>
	   if (inp='1')then outp <= '0'; NS<=E;
	   else NS <= A; -- input is one, go to E state
	   end if;
	when E =>
	   if (inp='0')then outp <= '0'; NS<=F; -- input is zero, bit is flipped, go to F state
	   else NS <= E; -- input is one, loop to E state
	   end if;
	when F =>
	   outp <= '1'; --set output to zero
	   bool <= (outp XOR bool);
	   --cnt <= "000000000000000000000000000000000000000";
	   if (inp='0')then NS<=A; -- If input is zero, go back to A
	   else NS <= B; -- input is one, go to B state
	   end if;
	when others =>
	   outp <= '0';
	   NS <= A;
	   --bool <= '0';
	end case;
	   
	--IF clk'EVENT AND clk = '1' THEN -- on rising edge of clock
	IF (rising_edge(clk)) THEN
		IF bool='0' then cnt <= cnt + 1; -- increment counter
		--ELSIF bool='1' then cnt <= cnt - 1; -- DECREMENT counter
		ELSE cnt <= cnt - 1; -- DECREMENT counter
		END IF;
	END IF;
	
	END PROCESS mainProcess;
	count <= cnt (38 DOWNTO 23); -- 16 bits
	mpx <= cnt (19 DOWNTO 17); -- 3 bits
END Behavioral;
