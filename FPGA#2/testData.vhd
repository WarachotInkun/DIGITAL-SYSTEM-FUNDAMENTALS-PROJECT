library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Parallel_Data_Transmitter is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        data_out    : out STD_LOGIC_VECTOR(7 downto 0);
        o_en        : out STD_LOGIC;
        i_tig       : in  STD_LOGIC;
        i_bus       : in  STD_LOGIC_VECTOR(7 downto 0);
        i_clk_bus   : in  STD_LOGIC
    );
end Parallel_Data_Transmitter;

architecture Behavioral of Parallel_Data_Transmitter is
    constant HEIGHT : integer := 120;
    constant WIDTH : integer := 160;
    constant BUFFER_SIZE : integer := HEIGHT * WIDTH;  -- 19,200 bytes
    constant ADDR_BITS : integer := 15;  -- ceil(log2(19200)) = 15

    -- Dual-port RAM component declaration
    component dp_ram
    port (
        clka  : in std_logic;
        wea   : in std_logic;
        addra : in std_logic_vector(ADDR_BITS-1 downto 0);
        dina  : in std_logic_vector(7 downto 0);
        clkb  : in std_logic;
        addrb : in std_logic_vector(ADDR_BITS-1 downto 0);
        doutb : out std_logic_vector(7 downto 0)
    );
    end component;

    -- Signals for RAM control
    signal index   : unsigned(ADDR_BITS-1 downto 0) := (others => '0');
    signal i_index : unsigned(ADDR_BITS-1 downto 0) := (others => '0');
    signal toggle  : std_logic := '0';
    signal prev_i_tig : std_logic := '0';
    signal ram_out : std_logic_vector(7 downto 0);
    signal write_enable : std_logic;

begin
    -- Instantiate dual-port RAM
    ram_inst : dp_ram
    port map (
        clka  => i_clk_bus,
        wea   => '1',  -- Always enable writing for input process
        addra => std_logic_vector(i_index),
        dina  => i_bus,
        clkb  => clk,
        addrb => std_logic_vector(index),
        doutb => ram_out
    );

    -- Output process
    process(clk, reset)
    begin
        if reset = '1' then
            index <= (others => '0');
            toggle <= '0';
            prev_i_tig <= '0';
            data_out <= (others => '0');
            o_en <= '0';
        elsif rising_edge(clk) then
            if i_tig = '1' and prev_i_tig = '0' and toggle = '0' then
                toggle <= '1';
            end if;
            prev_i_tig <= i_tig;
            
            if toggle = '1' then
                data_out <= ram_out;
                o_en <= '1';
                if index = BUFFER_SIZE-1 then
                    index <= (others => '0');
                    toggle <= '0';
                else
                    index <= index + 1;
                end if;
            else
                o_en <= '0';
            end if;
        end if;
    end process;

    -- Input process
    process(i_clk_bus, reset)
    begin
        if reset = '1' then
            i_index <= (others => '0');
        elsif rising_edge(i_clk_bus) then
            if i_index = BUFFER_SIZE-1 then
                i_index <= (others => '0');
            else
                i_index <= i_index + 1;
            end if;
        end if;
    end process;

end Behavioral;