library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity frame_buffer is
    Port ( 
        -- System
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- Camera interface (write port)
        cam_pclk : in STD_LOGIC;
        cam_href : in STD_LOGIC;
        cam_vsync : in STD_LOGIC;
        cam_data : in STD_LOGIC_VECTOR(7 downto 0);
        
        -- VGA interface (read port)
        vga_clk : in STD_LOGIC;
        vga_addr : in STD_LOGIC_VECTOR(14 downto 0);
        vga_data : out STD_LOGIC_VECTOR(7 downto 0);
		  
		 --bus data interface
        bus_clk : in STD_LOGIC;
        bus_addr : in STD_LOGIC_VECTOR(14 downto 0);
        bus_data : out STD_LOGIC_VECTOR(7 downto 0)
    );
end frame_buffer;

architecture Behavioral of frame_buffer is
    -- Constants
    constant FRAME_WIDTH : integer := 160;
    constant FRAME_HEIGHT : integer := 120;
    constant BUFFER_SIZE : integer := FRAME_WIDTH * FRAME_HEIGHT;
    constant CAMERA_WIDTH : integer := 640;
    constant CAMERA_HEIGHT : integer := 480;
    
    -- Frame buffer memory
    type ram_type is array (0 to BUFFER_SIZE-1) of STD_LOGIC_VECTOR(7 downto 0);
    signal frame_mem : ram_type := (others => (others => '0'));
    
    -- Write control signals
    signal write_addr : unsigned(14 downto 0) := (others => '0');
    signal byte_count : std_logic := '0';
    signal rgb565_pixel : STD_LOGIC_VECTOR(15 downto 0);
    
    -- Pixel position counters
    signal x_counter : unsigned(9 downto 0) := (others => '0');
    signal y_counter : unsigned(9 downto 0) := (others => '0');
    
    signal prev_vsync : std_logic := '0';
    signal green_isas : STD_LOGIC_VECTOR(2 downto 0):= "000";
    
begin
    -- Write process (camera domain)
    process(cam_pclk)
    begin
          if rst = '1' then
                -- Reset counters at start of frame
                write_addr <= (others => '0');
                byte_count <= '0';
                x_counter <= (others => '0');
                y_counter <= (others => '0');
	 
        elsif rising_edge(cam_pclk) then
            prev_vsync <= cam_vsync;
            
            if cam_vsync = '1' then
                -- Reset counters at start of frame
                write_addr <= (others => '0');
                byte_count <= '0';
                x_counter <= (others => '0');
                y_counter <= (others => '0');
                
            elsif cam_href = '1' then
                if byte_count = '0' then
                    -- First byte (high byte)
                    rgb565_pixel(15 downto 8) <= cam_data;
                    green_isas <= cam_data(7 downto 5);
                    byte_count <= '1';
                else
                    -- Second byte (low byte)
                    rgb565_pixel(7 downto 0) <= cam_data;
                    byte_count <= '0';
                    
                    -- Store downsampled pixel
                    if (x_counter(1 downto 0) = "00" and y_counter(1 downto 0) = "00") then
                        frame_mem(to_integer(write_addr)) <=
                            rgb565_pixel(15 downto 13) &  -- Red
                            green_isas &                  -- Green
                            cam_data(4 downto 3);         -- Blue
                            
                        if write_addr < BUFFER_SIZE-1 then
                            write_addr <= write_addr + 1;
                        end if;
                    end if;
                    
                    -- Update position counters
                    if x_counter = CAMERA_WIDTH - 1 then
                        x_counter <= (others => '0');
                        if y_counter < CAMERA_HEIGHT - 1 then
                            y_counter <= y_counter + 1;
                        end if;
                    else
                        x_counter <= x_counter + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
    -- Read process (VGA domain)
    process(vga_clk)
    begin
        if rising_edge(vga_clk) then
            vga_data <= frame_mem(to_integer(unsigned(vga_addr)));
        end if;
    end process;
	 
	 -- Read process (Data tranfer domain)
    process(bus_clk)
    begin
        if rising_edge(bus_clk) then
            bus_data <= frame_mem(to_integer(unsigned(bus_addr)));
        end if;
    end process;


end Behavioral; -- Best