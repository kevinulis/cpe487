LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY bat_n_ball IS
    PORT (
        v_sync : IN STD_LOGIC;
        pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
        bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0); -- current bat x position
        serve : IN STD_LOGIC; -- initiates serve
        red : OUT STD_LOGIC;
        green : OUT STD_LOGIC;
        blue : OUT STD_LOGIC;
        speed : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        hitcounter : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) -- counter is within bat_n_ball.vhd, outputs to other files
    );
END bat_n_ball;

ARCHITECTURE Behavioral OF bat_n_ball IS
    CONSTANT bsize : INTEGER := 8; -- ball size in pixels
    --CONSTANT bat_w : INTEGER := 20; -- bat width in pixels
    CONSTANT bat_w : INTEGER := 60; -- bat width in pixels
    SIGNAL bat_width : INTEGER := bat_w;
    CONSTANT bat_h : INTEGER := 3; -- bat height in pixels
    -- distance ball moves each frame
    --CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR (6, 11);
    CONSTANT ball_speed : STD_LOGIC_VECTOR (10 DOWNTO 0) := speed;
    SIGNAL ball_on : STD_LOGIC; -- indicates whether ball is at current pixel position
    SIGNAL bat_on : STD_LOGIC; -- indicates whether bat at over current pixel position
    SIGNAL game_on : STD_LOGIC := '0'; -- indicates whether ball is in play
    -- current ball position - intitialized to center of screen
    SIGNAL ball_x : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(400, 11);
    SIGNAL ball_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(300, 11);
    -- bat vertical position
    CONSTANT bat_y : STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(500, 11);
    -- current ball motion - initialized to (+ ball_speed) pixels/frame in both X and Y directions
    SIGNAL ball_x_motion, ball_y_motion : STD_LOGIC_VECTOR(10 DOWNTO 0) := ball_speed;
    
    SIGNAL bounces : STD_LOGIC_VECTOR (15 DOWNTO 0); -- counter for architecture
    SIGNAL count_ready : STD_LOGIC := '0';
BEGIN
    red <= NOT bat_on; -- color setup for red ball and cyan bat on white background
    green <= NOT ball_on;
    blue <= NOT ball_on;
    -- process to draw round ball
    -- set ball_on if current pixel address is covered by ball position
    balldraw : PROCESS (ball_x, ball_y, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF pixel_col <= ball_x THEN -- vx = |ball_x - pixel_col|
            vx := ball_x - pixel_col;
        ELSE
            vx := pixel_col - ball_x;
        END IF;
        IF pixel_row <= ball_y THEN -- vy = |ball_y - pixel_row|
            vy := ball_y - pixel_row;
        ELSE
            vy := pixel_row - ball_y;
        END IF;
        IF ((vx * vx) + (vy * vy)) < (bsize * bsize) THEN -- test if radial distance < bsize
            ball_on <= game_on;
        ELSE
            ball_on <= '0';
        END IF;
    END PROCESS;
    -- process to draw bat
    -- set bat_on if current pixel address is covered by bat position
    batdraw : PROCESS (bat_x, pixel_row, pixel_col) IS
        VARIABLE vx, vy : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    BEGIN
        IF ((pixel_col >= bat_x - bat_width) OR (bat_x <= bat_width)) AND
         pixel_col <= bat_x + bat_width AND
             pixel_row >= bat_y - bat_h AND
             pixel_row <= bat_y + bat_h THEN
                bat_on <= '1';
        ELSE
            bat_on <= '0';
        END IF;
    END PROCESS;
    -- process to move ball once every frame (i.e., once every vsync pulse)
    mball : PROCESS
        VARIABLE temp : STD_LOGIC_VECTOR (11 DOWNTO 0);
    BEGIN
        WAIT UNTIL rising_edge(v_sync);
        IF serve = '1' AND game_on = '0' THEN -- test for new serve
            game_on <= '1';
            bat_width <= bat_w;
            ball_y_motion <= (NOT ball_speed) + 2; -- set vspeed to (- ball_speed) pixels
            ball_x_motion <= ball_speed + 1; -- MINIMUM SPEED IS 1
            bounces <= "0000000000000001";
            hitcounter <= "0000000000000000";
            count_ready <= '0';
        ELSIF ball_y <= bsize THEN -- bounce off top wall
            ball_y_motion <= ball_speed; -- set vspeed to (+ ball_speed) pixels
            count_ready <= '0';
        ELSIF ball_y + bsize >= 600 THEN -- if ball meets bottom wall
            ball_y_motion <= (NOT ball_speed) + 1; -- set vspeed to (- ball_speed) pixels
            game_on <= '0'; -- and make ball disappear
        END IF;
        -- allow for bounce off left or right of screen
        IF ball_x + bsize >= 800 THEN -- bounce off right wall
            ball_x_motion <= (NOT ball_speed) + 1; -- set hspeed to (- ball_speed) pixels
            count_ready <= '0';
        ELSIF ball_x <= bsize THEN -- bounce off left wall
            ball_x_motion <= ball_speed; -- set hspeed to (+ ball_speed) pixels
            count_ready <= '0';
        END IF;
        -- allow for bounce off bat
        IF (ball_x + bsize/2) >= (bat_x - bat_width) AND
         (ball_x - bsize/2) <= (bat_x + bat_width) AND
             (ball_y + bsize/2) >= (bat_y - bat_h) AND
             (ball_y - bsize/2) <= (bat_y + bat_h) AND
             (count_ready = '0') THEN
                ball_y_motion <= (NOT ball_speed) + 2; -- set vspeed to (- ball_speed) pixels
                bat_width <= bat_width - 1; -- make bat width smaller each hit
                bounces <= bounces + 1;
                hitcounter <= bounces;
                count_ready <= '1';
        END IF;
        -- compute next ball vertical position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_y is close to zero and ball_y_motion is negative
        temp := ('0' & ball_y) + (ball_y_motion(10) & ball_y_motion);
        IF game_on = '0' THEN
            ball_y <= CONV_STD_LOGIC_VECTOR(440, 11);
        ELSIF temp(11) = '1' THEN
            ball_y <= (OTHERS => '0');
        ELSE ball_y <= temp(10 DOWNTO 0); -- 9 downto 0
        END IF;
        -- compute next ball horizontal position
        -- variable temp adds one more bit to calculation to fix unsigned underflow problems
        -- when ball_x is close to zero and ball_x_motion is negative
        temp := ('0' & ball_x) + (ball_x_motion(10) & ball_x_motion);
        IF temp(11) = '1' THEN
            ball_x <= (OTHERS => '0');
        ELSE ball_x <= temp(10 DOWNTO 0);
        END IF;
    END PROCESS;
END Behavioral;
