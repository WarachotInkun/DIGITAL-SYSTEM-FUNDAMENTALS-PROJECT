library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clock_delay is
    Port ( clk_in  : in  STD_LOGIC;  -- Input clock
           clk_out : out STD_LOGIC); -- 1/4 delayed clock output
end clock_delay;

architecture Behavioral of clock_delay is
    signal counter : unsigned(1 downto 0) := "00";  -- 2-bit counter to divide clock
    signal temp_clk : STD_LOGIC := '0';
begin
    process(clk_in)
    begin
        if rising_edge(clk_in) then
            counter <= counter + 1;
            if counter = "00" then
                temp_clk <= '1';
            elsif counter = "01" then
                temp_clk <= '0';
            end if;
        end if;
    end process;

    -- Output delayed clock (1/4 phase shift)
    clk_out <= temp_clk;

end Behavioral;