library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ov7670_controller is
    Port ( 
       
        clk   : in    STD_LOGIC;  
        rst   : in    STD_LOGIC;  
        
        -- OV7670 interface
        sioc  : out   STD_LOGIC;  
        siod  : inout STD_LOGIC; 
        reset : out   STD_LOGIC;  
        pwdn  : out   STD_LOGIC; 
        xclk  : out   STD_LOGIC;  
        
        -- Status
        config_finished : out STD_LOGIC
    );
end ov7670_controller;

architecture Behavioral of ov7670_controller is
    -- SCCB state machine
    type sccb_state_type is (IDLE, START, SEND_ADDR, SEND_DATA, STOP);
    signal state : sccb_state_type := IDLE;
    
    -- Configuration ROM
    type reg_data is array (0 to 5) of std_logic_vector(15 downto 0);
    constant init_reg : reg_data := (
       -- Register address & value pairs
        x"1280", 
		  x"1101",
		  x"1204",
		  x"3e00",
		  x"40d4",
		  x"ffff"
    );
    
    signal reg_index : integer := 0;
    signal sccb_ready : std_logic := '0';
    
begin
    -- Camera control signals
    reset <= '1';  
    pwdn  <= '0'; 
    xclk  <= clk; 
    
    -- SCCB configuration process
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
            sioc <= '1';
            siod <= 'Z';
            reg_index <= 0;
            config_finished <= '0';
            
        elsif rising_edge(clk) then
            case state is
                when IDLE =>
                    sioc <= '1';
                    siod <= 'Z';
                    if reg_index < init_reg'length then
                        state <= START;
                    else
                        config_finished <= '1';
                    end if;
                    
                when START =>
                    sioc <= '1';
                    siod <= '0';
                    state <= SEND_ADDR;
                    
                when SEND_ADDR =>
                    -- Send device address and register address
                    sioc <= '0';
                    siod <= init_reg(reg_index)(15);
                    state <= SEND_DATA;
                    
                when SEND_DATA =>
                    -- Send register data
                    sioc <= '0';
                    siod <= init_reg(reg_index)(7);
                    state <= STOP;
                    
                when STOP =>
                    sioc <= '1';
                    siod <= '1';
                    reg_index <= reg_index + 1;
                    state <= IDLE;
            end case;
        end if;
    end process;
    
end Behavioral;