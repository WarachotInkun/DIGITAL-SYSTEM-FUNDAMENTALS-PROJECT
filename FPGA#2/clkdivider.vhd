library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Clock_Divider is
    Port (
        i_Clk       : in  std_logic;  -- Input Clock: 20 MHz
        o_Clk_Div   : out std_logic   -- Output Clock: 40 kHz
    );
end Clock_Divider;

architecture Behavioral of Clock_Divider is
    signal r_Counter : unsigned(17 downto 0) := (others => '0');  -- 18-bit Counter for 200000 cycles
    signal r_Clk_Out : std_logic := '0';  -- Internal clock signal
begin

    process(i_Clk)
    begin
        if rising_edge(i_Clk) then
            if r_Counter = 199999 then  -- Compare to 200000 cycles (40 kHz output)
                r_Counter <= (others => '0');  -- Reset counter
                r_Clk_Out <= NOT r_Clk_Out;    -- Toggle clock output
            else
                r_Counter <= r_Counter + 1;    -- Increment counter
            end if;
        end if;
    end process;

    -- Assign internal clock to output
    o_Clk_Div <= r_Clk_Out;

end Behavioral;