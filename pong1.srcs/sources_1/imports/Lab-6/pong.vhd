LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY pong IS
    PORT (
        clk_in : IN STD_LOGIC; -- system clock
        VGA_red : OUT STD_LOGIC_VECTOR (3 DOWNTO 0); -- VGA outputs
        VGA_green : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_blue : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        VGA_hsync : OUT STD_LOGIC;
        VGA_vsync : OUT STD_LOGIC;
        ADC_CS : OUT STD_LOGIC; -- ADC signals
        ADC_SCLK : OUT STD_LOGIC;
        ADC_SDATA1 : IN STD_LOGIC;
        ADC_SDATA2 : IN STD_LOGIC;
        btn0 : IN STD_LOGIC; -- button to initiate serve
        speed : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
        anode : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); -- four digits
        seg : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)); -- 7 segment display 
END pong;

ARCHITECTURE Behavioral OF pong IS
    SIGNAL pxl_clk : STD_LOGIC := '0'; -- 25 MHz clock to VGA sync module
    -- internal signals to connect modules
    SIGNAL S_red, S_green, S_blue : STD_LOGIC; --_VECTOR (3 DOWNTO 0);
    SIGNAL S_vsync : STD_LOGIC;
    SIGNAL S_pixel_row, S_pixel_col : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL batpos : STD_LOGIC_VECTOR (10 DOWNTO 0); -- 9 downto 0
    SIGNAL serial_clk, sample_clk : STD_LOGIC;
    SIGNAL adout : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL count : STD_LOGIC_VECTOR (9 DOWNTO 0); -- counter to generate ADC clocks
    SIGNAL hitcount : STD_LOGIC_VECTOR (15 DOWNTO 0); -- 16 bits for hit counter
    SIGNAL mpx : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL counter : STD_LOGIC_VECTOR (18 DOWNTO 0); --19 bits: 16 for hitcount, 3 for mpx
    COMPONENT adc_if IS
        PORT (
            SCK : IN STD_LOGIC;
            SDATA1 : IN STD_LOGIC;
            SDATA2 : IN STD_LOGIC;
            CS : IN STD_LOGIC;
            data_1 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            data_2 : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT bat_n_ball IS
        PORT (
            v_sync : IN STD_LOGIC;
            pixel_row : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            pixel_col : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            bat_x : IN STD_LOGIC_VECTOR (10 DOWNTO 0);
            serve : IN STD_LOGIC;
            red : OUT STD_LOGIC;
            green : OUT STD_LOGIC;
            blue : OUT STD_LOGIC;
            speed : IN STD_LOGIC_VECTOR (10 DOWNTO 0); --speed controlled by switches
            hitcounter : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT vga_sync IS
        PORT (
            pixel_clk : IN STD_LOGIC;
            red_in    : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_in  : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_in   : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
            red_out   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            green_out : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            blue_out  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            hsync : OUT STD_LOGIC;
            vsync : OUT STD_LOGIC;
            pixel_row : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            pixel_col : OUT STD_LOGIC_VECTOR (10 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT clk_wiz_0 is
        PORT (
            clk_in1  : in std_logic;
            clk_out1 : out std_logic
        );
    END COMPONENT;
    COMPONENT leddec IS
        PORT (
            dig: IN STD_LOGIC_VECTOR(2 DOWNTO 0); -- mpx value
            data: IN STD_LOGIC_VECTOR(15 DOWNTO 0); -- counter
            anode : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); -- displays
            seg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    -- Process to generate clock signals
    ckp : PROCESS
    BEGIN
        WAIT UNTIL rising_edge(clk_in);
        count <= count + 1; -- counter to generate ADC timing signals
    END PROCESS;
    serial_clk <= NOT count(4); -- 1.5 MHz serial clock for ADC
    ADC_SCLK <= serial_clk;
    sample_clk <= count(9); -- sampling clock is low for 16 SCLKs
    ADC_CS <= sample_clk;
    -- Multiplies ADC output (0-4095) by 5/32 to give bat position (0-640)
    --batpos <= ('0' & adout(11 DOWNTO 3)) + adout(11 DOWNTO 5);
    batpos <= ("00" & adout(11 DOWNTO 3)) + adout(11 DOWNTO 4);
    -- 512 + 256 = 768
    adc : adc_if
    PORT MAP(-- instantiate ADC serial to parallel interface
        SCK => serial_clk, 
        CS => sample_clk, 
        SDATA1 => ADC_SDATA1, 
        SDATA2 => ADC_SDATA2, 
        data_1 => OPEN, 
        data_2 => adout 
    );
    add_bb : bat_n_ball
    PORT MAP(--instantiate bat and ball component
        v_sync => S_vsync, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        bat_x => batpos, 
        serve => btn0, 
        red => S_red, 
        green => S_green, 
        blue => S_blue,
        speed => speed,
        hitcounter => hitcount
    );
    vga_driver : vga_sync
    PORT MAP(--instantiate vga_sync component
        pixel_clk => pxl_clk, 
        red_in => S_red & "000", 
        green_in => S_green & "000", 
        blue_in => S_blue & "000", 
        red_out => VGA_red, 
        green_out => VGA_green, 
        blue_out => VGA_blue, 
        pixel_row => S_pixel_row, 
        pixel_col => S_pixel_col, 
        hsync => VGA_hsync, 
        vsync => S_vsync
    );
    VGA_vsync <= S_vsync; --connect output vsync
        
    clk_wiz_0_inst : clk_wiz_0
    port map (
      clk_in1 => clk_in,
      clk_out1 => pxl_clk
    );
    
--    if (hitcount(7 DOWNTO 3) > "0000") THEN
--        mpx <= "001";
--        if(hitcount(11 DOWNTO 8) > "0000") THEN
--            mpx <= "010";
--            if(hitcount(15 DOWNTO 12) > "0000") THEN
--            mpx <= "011";
--            end if;
--        end if;
--    end if;
    --mpx <= "000" WHEN (hitcount(3 DOWNTO 0) > "0000");
--    mpx_check : PROCESS
--    BEGIN
--        IF (rising_edge(clk_in)) THEN
--        mpx <= "000";
--        END IF;
--        IF (rising_edge(clk_in) AND (hitcount(7 DOWNTO 4) > "0000")) THEN
--        mpx <= "001";
--        END IF;
--        IF (rising_edge(clk_in) AND (hitcount(11 DOWNTO 8) > "0000")) THEN
--        mpx <= "010";
--        END IF;
--        IF (rising_edge(clk_in) AND (hitcount(15 DOWNTO 12) > "0000")) THEN
--        mpx <= "011";
--        END IF;
--    END PROCESS;

    displays : leddec
    PORT MAP(
        anode => anode, dig => mpx, seg => seg, data => hitcount
    );
    
        
END Behavioral;
