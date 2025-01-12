library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dp_ram is
    generic (
        DATA_WIDTH : integer := 8;
        ADDR_WIDTH : integer := 15
    );
    port (
        clka  : in std_logic;
        wea   : in std_logic;
        addra : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        dina  : in std_logic_vector(DATA_WIDTH-1 downto 0);
        clkb  : in std_logic;
        addrb : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        doutb : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end dp_ram;

architecture Behavioral of dp_ram is
    type ram_type is array (0 to 2**ADDR_WIDTH-1) 
        of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal ram : ram_type := (others => (others => '0'));
    attribute ram_style : string;
    attribute ram_style of ram : signal is "block";
begin
    -- Port A - Write
    process(clka)
    begin
        if rising_edge(clka) then
            if wea = '1' then
                ram(to_integer(unsigned(addra))) <= dina;
            end if;
        end if;
    end process;

    -- Port B - Read
    process(clkb)
    begin
        if rising_edge(clkb) then
            doutb <= ram(to_integer(unsigned(addrb)));
        end if;
    end process;
end architecture Behavioral;