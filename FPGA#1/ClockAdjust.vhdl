library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;
library UNISIM;
use UNISIM.Vcomponents.ALL;

entity dcm_clock is
    generic (
        CLKFX_MULTIPLY : integer := 5;  -- Default for 25MHz (5/4 * 20MHz)
        CLKFX_DIVIDE : integer := 4
    );
    port ( 
        i_Clk : in    std_logic; 
        o_Clk : out   std_logic
    );
end dcm_clock;

architecture BEHAVIORAL of dcm_clock is
    signal XLXN_3 : std_logic;
begin
    XLXI_1 : DCM_CLKGEN
        generic map( 
            CLKFX_MULTIPLY => CLKFX_MULTIPLY,  -- multiplication value
            CLKFX_DIVIDE => CLKFX_DIVIDE,      -- division value
            CLKIN_PERIOD => 50.0               -- 20MHz input clock period in ns
        )
        port map (
            CLKIN => i_Clk,
            FREEZEDCM => XLXN_3,
            PROGCLK => XLXN_3,
            PROGDATA => XLXN_3,
            PROGEN => XLXN_3,
            RST => XLXN_3,
            CLKFX => o_Clk,
            CLKFXDV => open,
            CLKFX180 => open,
            LOCKED => open,
            PROGDONE => open,
            STATUS => open
        );
   
    XLXI_2 : GND
        port map (G => XLXN_3);
   
end BEHAVIORAL;