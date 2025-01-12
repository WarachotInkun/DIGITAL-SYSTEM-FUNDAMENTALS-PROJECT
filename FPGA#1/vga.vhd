library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity vga_display is
    Port ( 
        -- System
        clk_25mhz : in STD_LOGIC;  -- 25MHz pixel clock
        rst : in STD_LOGIC;
		  btn : in STD_LOGIC;
  

        -- Frame buffer interface
        fb_addr : out STD_LOGIC_VECTOR(14 downto 0);
        fb_data : in STD_LOGIC_VECTOR(7 downto 0);
        
        -- VGA output
        vga_r : out STD_LOGIC_VECTOR(2 downto 0);
        vga_g : out STD_LOGIC_VECTOR(2 downto 0);
        vga_b : out STD_LOGIC_VECTOR(1 downto 0);
        vga_hsync : out STD_LOGIC;
        vga_vsync : out STD_LOGIC
    );
end vga_display;

architecture Behavioral of vga_display is


    -- VGA timing constants
    constant H_VISIBLE : integer := 640 ;
    constant H_FRONT_PORCH : integer := 16;
    constant H_SYNC_PULSE : integer := 96;
    constant H_BACK_PORCH : integer := 48;
    constant H_TOTAL : integer := 800;
    
    constant V_VISIBLE : integer := 480;
    constant V_FRONT_PORCH : integer := 10;
    constant V_SYNC_PULSE : integer := 2;
    constant V_BACK_PORCH : integer := 33;
    constant V_TOTAL : integer := 525;
    
    -- Counter signals
    signal h_count : integer range 0 to H_TOTAL-1 := 0;
    signal v_count : integer range 0 to V_TOTAL-1 := 0;
    
    -- Display position calculation
    signal x_pos : integer range 0 to 159 := 0;
    signal y_pos : integer range 0 to 119 := 0;
    signal is_visible : boolean := false;
	 signal count : STD_LOGIC_VECTOR(15 downto 0) := (others => '0') ;
    
begin
    -- Horizontal and vertical counters
    process(clk_25mhz)
    begin
        if rising_edge(clk_25mhz) then
            if h_count = H_TOTAL-1 then
                h_count <= 0;
                if v_count = V_TOTAL-1 then
                    v_count <= 0;
                else
                    v_count <= v_count + 1;
                end if;
            else
                h_count <= h_count + 1;
            end if;
        end if;
    end process;
    
    -- Generate sync signals
    process(clk_25mhz)
    begin
        if rising_edge(clk_25mhz) then
            -- Horizontal sync
            if (h_count >= (H_VISIBLE + H_FRONT_PORCH)) and 
               (h_count < (H_VISIBLE + H_FRONT_PORCH + H_SYNC_PULSE)) then
                vga_hsync <= '0';
            else
                vga_hsync <= '1';
            end if;
            
            -- Vertical sync
            if (v_count >= (V_VISIBLE + V_FRONT_PORCH)) and
               (v_count < (V_VISIBLE + V_FRONT_PORCH + V_SYNC_PULSE)) then
                vga_vsync <= '0';
            else
                vga_vsync <= '1';
            end if;
        end if;
    end process;
    
    -- Calculate display position and frame buffer address
    x_pos <= h_count/4 when h_count < H_VISIBLE else 0;
    y_pos <= v_count/4 when v_count < V_VISIBLE else 0;
    is_visible <= h_count < H_VISIBLE and v_count < V_VISIBLE;
    
    fb_addr <= std_logic_vector(to_unsigned((y_pos * 160) + x_pos, 15)) 
              when is_visible else (others => '0');

    
    -- Output pixel data
    process(clk_25mhz)
    begin
        if rising_edge(clk_25mhz) then
            if is_visible then
                vga_r <= fb_data(7 downto 5);
                vga_g <= fb_data(4 downto 2);
                vga_b <= fb_data(1 downto 0) ;
            else
                vga_r <= "000";
                vga_g <= "000";
                vga_b <= "00";
            end if;
        end if;
    end process;
  
end Behavioral; -- checkPoint