library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Delay_Rising_Edge is
    Port (
        clk : in STD_LOGIC;          -- สัญญาณนาฬิกา 20 MHz
        signal_in : in STD_LOGIC;    -- สัญญาณอินพุต
        signal_out : out STD_LOGIC   -- สัญญาณเอาท์พุตที่ rising edge หน่วงเวลา 2 วินาที
    );
end Delay_Rising_Edge;

architecture Behavioral of Delay_Rising_Edge is

    -- จำนวนรอบสำหรับหน่วงเวลา 2 วินาที (สำหรับ clk 20 MHz)
    constant DELAY_CYCLES : unsigned(25 downto 0) := to_unsigned(40_000_000 - 1, 26);

    -- ตัวนับเพื่อหน่วงเวลา
    signal counter : unsigned(25 downto 0) := (others => '0');

    -- สถานะการหน่วงเวลา
    signal delay_active : STD_LOGIC := '0';

    -- สถานะก่อนหน้าของ signal_in
    signal prev_signal_in : STD_LOGIC := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if signal_in = '1' and prev_signal_in = '0' then
                delay_active <= '1';
                counter <= (others => '0');
            end if;

           
            prev_signal_in <= signal_in;

           
            if delay_active = '1' then
                if counter < DELAY_CYCLES then
                    counter <= counter + 1;
                else
                    delay_active <= '0'; 
                end if;
            end if;
        end if;
    end process;

   
    signal_out <= '1' when delay_active = '1' else '0';

end Behavioral;