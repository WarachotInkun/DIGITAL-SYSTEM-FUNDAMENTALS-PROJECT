library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity camera_system is
    Port ( 
        -- System
        clk : in STD_LOGIC;   -- 20MHz input clock
        rst : in STD_LOGIC;   -- cap BTN(Blue Btn)
        del : in STD_LOGIC;   -- del BTN(red Btn)
        save : in STD_LOGIC;  -- save BTN(green Btn)
        btn : in STD_LOGIC; 

        -- OV7670 interface
        cam_pclk : in STD_LOGIC;
        cam_href : in STD_LOGIC;
        cam_vsync : in STD_LOGIC;
        cam_data : in STD_LOGIC_VECTOR(7 downto 0);
        cam_sioc : out STD_LOGIC;
        cam_siod : inout STD_LOGIC;
        cam_reset : out STD_LOGIC;
        cam_pwdn : out STD_LOGIC;
        cam_xclk : out STD_LOGIC;
        
        -- VGA output
        vga_r : out STD_LOGIC_VECTOR(2 downto 0);
        vga_g : out STD_LOGIC_VECTOR(2 downto 0);
        vga_b : out STD_LOGIC_VECTOR(1 downto 0);
        vga_hsync : out STD_LOGIC;
        vga_vsync : out STD_LOGIC;
        
        --Bus Output
        o_bus_clk : out STD_LOGIC;
        o_bus_data : out STD_LOGIC_VECTOR(7 downto 0);
        o_led : out STD_LOGIC;
		  o_tig : out STD_LOGIC
    );
end camera_system;

architecture Behavioral of camera_system is
    -- Clock signals
    signal clk_25mhz : STD_LOGIC;
    signal clk_50mhz : STD_LOGIC;
    signal clk_200khz : STD_LOGIC := '1';

    -- Frame buffer signals
    signal fb_addr : STD_LOGIC_VECTOR(14 downto 0);
    signal fb_data : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Camera controller status
    signal config_finished : STD_LOGIC;
    signal rst_toggle : STD_LOGIC := '0';
    
    -- Button control signals
    signal save_toggle : STD_LOGIC := '0';
    signal rst_prev, del_prev, save_prev : STD_LOGIC := '0';
    
    -- Bus data Transfer
    signal bus_addr : STD_LOGIC_VECTOR(14 downto 0);
    signal bus_data : STD_LOGIC_VECTOR(7 downto 0);
    
    -- Transfer control signals
    signal start : STD_LOGIC := '0';
    signal index : integer range 0 to 19199 := 0;  -- Buffer_size - 1
    signal s_t,p_t : STD_LOGIC  := '0';
  
    -- Constants
    constant BUFFER_SIZE : integer := 19200;
	 signal counter : integer range 0 to 100 := 0;
	 
	 --hold 5sec
	 signal timer_count : integer range 0 to 500000 := 0;  
    signal timer_enable : STD_LOGIC := '0';

    
begin

	-- clock 200k 
	process (clk)
	begin
					if rising_edge(clk) then 
							counter <= counter + 1;
						  if counter = 100 then
									clk_200khz <= not clk_200khz ;   
									counter <= 0;
						  end if;
					end if;
					
		end process;
		
		
    -- Button control process
    process(clk)
    begin

        if rising_edge(clk) then
            -- Store previous values
            rst_prev <= rst;
            del_prev <= del;
				
            -- Check for rst button press
            if rst = '1' and rst_prev = '0' and rst_toggle = '0' and save_toggle = '0' then
                rst_toggle <= '1';
            end if;
            
            -- Check for del button press
            if del = '1' and del_prev = '0' and rst_toggle = '1' and save_toggle = '0' then
                rst_toggle <= '0';
            end if;
				if s_t = '1' and p_t = '0' and rst_toggle = '1'  then
                rst_toggle <= '0';
            end if;
            p_t      <= s_t;

        end if;
    end process;
    


    
    -- Data transfer process
    process(clk_200khz)
    begin
        if rising_edge(clk_200khz) then
            save_prev <= save;
            s_t <= '0';
            
            if save = '1' and save_prev = '0' and rst_toggle = '1' then
                save_toggle <= '1';
            end if;
            
            if save_toggle = '1' then
                if start = '0' then
                    if index < BUFFER_SIZE - 1 then 
                        start <= '1';
                        bus_addr <= std_logic_vector(to_unsigned(index, 15));
                        o_bus_data <= bus_data;
                    end if;
                else
                    if index < BUFFER_SIZE - 1 then
                        index <= index + 1;
                        bus_addr <= std_logic_vector(to_unsigned(index, 15));
                        o_bus_data <= bus_data;
                    else
                        -- start 5sec
                        if timer_count = 0 then
                            timer_enable <= '1';
                            o_bus_data <= "00000000";
                        end if;
                        
                        if timer_enable = '1' then
                            if timer_count < 500000 then 
                                timer_count <= timer_count + 1;
                            else
                                -- stop 5sec
                                timer_count <= 0;
                                timer_enable <= '0';
                                start <= '0';
                                index <= 0;
                                save_toggle <= '0';
                                s_t <= '1';
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    o_bus_clk <= clk_200khz when (save_toggle = '1' and index < BUFFER_SIZE - 1) else '0';
    o_led <= save_toggle;
	 o_tig <= timer_enable;

    -- Clock generators
    clk_gen: entity work.dcm_clock
        generic map(
            CLKFX_MULTIPLY => 5,
            CLKFX_DIVIDE => 4
        )
        port map(
            i_Clk => clk,
            o_Clk => clk_25mhz
        );

    clk_gen2: entity work.dcm_clock
        generic map(
            CLKFX_MULTIPLY => 97,
            CLKFX_DIVIDE => 40
        )
        port map(
            i_Clk => clk,
            o_Clk => clk_50mhz
        );


        
    -- Camera controller
    camera_ctrl: entity work.ov7670_controller
        port map(
            clk => clk_50mhz,
            rst => rst,
            sioc => cam_sioc,
            siod => cam_siod,
            reset => cam_reset,
            pwdn => cam_pwdn,
            xclk => cam_xclk,
            config_finished => config_finished
        );
    
    -- Frame buffer
    frame_buff: entity work.frame_buffer
        port map(
            clk => clk,
            rst => rst_toggle,
            cam_pclk => cam_pclk,
            cam_href => cam_href,
            cam_vsync => cam_vsync,
            cam_data => cam_data,
            vga_clk => clk_25mhz,
            vga_addr => fb_addr,
            vga_data => fb_data,
            bus_clk => clk_200khz,
            bus_addr => bus_addr,
            bus_data => bus_data
        );
    
    -- VGA display controller
    vga_ctrl: entity work.vga_display
        port map(
            clk_25mhz => clk_25mhz,
            rst => rst,
            btn => btn,
            fb_addr => fb_addr,
            fb_data => fb_data,
            vga_r => vga_r,
            vga_g => vga_g,
            vga_b => vga_b,
            vga_hsync => vga_hsync,
            vga_vsync => vga_vsync
        );

end Behavioral;