<?xml version="1.0" encoding="UTF-8"?>
<drawing version="7">
    <attr value="spartan6" name="DeviceFamilyName">
        <trait delete="all:0" />
        <trait editname="all:0" />
        <trait edittrait="all:0" />
    </attr>
    <netlist>
        <signal name="asdasd" />
        <signal name="data_out(7:0)" />
        <signal name="reset" />
        <signal name="ikljhfluiysdliy" />
        <signal name="clk" />
        <signal name="tig" />
        <signal name="led" />
        <signal name="sclk" />
        <signal name="write_cmd" />
        <signal name="write_cmd_to_arduino" />
        <signal name="tik_cmd" />
        <signal name="i_clk" />
        <signal name="i_bus(7:0)" />
        <port polarity="Output" name="data_out(7:0)" />
        <port polarity="Input" name="reset" />
        <port polarity="Input" name="clk" />
        <port polarity="Output" name="led" />
        <port polarity="Output" name="sclk" />
        <port polarity="Input" name="write_cmd" />
        <port polarity="Output" name="write_cmd_to_arduino" />
        <port polarity="Output" name="tik_cmd" />
        <port polarity="Input" name="i_clk" />
        <port polarity="Input" name="i_bus(7:0)" />
        <blockdef name="buf">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-32" y2="-32" x1="0" />
            <line x2="128" y1="-32" y2="-32" x1="224" />
            <line x2="128" y1="0" y2="-32" x1="64" />
            <line x2="64" y1="-32" y2="-64" x1="128" />
            <line x2="64" y1="-64" y2="0" x1="64" />
        </blockdef>
        <blockdef name="Clock_Divider">
            <timestamp>2024-11-11T16:5:24</timestamp>
            <rect width="256" x="64" y="-64" height="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
        </blockdef>
        <blockdef name="and2">
            <timestamp>2000-1-1T10:10:10</timestamp>
            <line x2="64" y1="-64" y2="-64" x1="0" />
            <line x2="64" y1="-128" y2="-128" x1="0" />
            <line x2="192" y1="-96" y2="-96" x1="256" />
            <arc ex="144" ey="-144" sx="144" sy="-48" r="48" cx="144" cy="-96" />
            <line x2="64" y1="-48" y2="-48" x1="144" />
            <line x2="144" y1="-144" y2="-144" x1="64" />
            <line x2="64" y1="-48" y2="-144" x1="64" />
        </blockdef>
        <blockdef name="Delay_Rising_Edge">
            <timestamp>2024-11-11T23:4:19</timestamp>
            <rect width="256" x="64" y="-128" height="128" />
            <line x2="0" y1="-96" y2="-96" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <line x2="384" y1="-96" y2="-96" x1="320" />
        </blockdef>
        <blockdef name="Parallel_Data_Transmitter">
            <timestamp>2024-11-12T4:17:47</timestamp>
            <line x2="0" y1="96" y2="96" x1="64" />
            <rect width="64" x="0" y="148" height="24" />
            <line x2="0" y1="160" y2="160" x1="64" />
            <line x2="0" y1="32" y2="32" x1="64" />
            <line x2="384" y1="32" y2="32" x1="320" />
            <line x2="0" y1="-160" y2="-160" x1="64" />
            <line x2="0" y1="-32" y2="-32" x1="64" />
            <rect width="64" x="320" y="-44" height="24" />
            <line x2="384" y1="-32" y2="-32" x1="320" />
            <rect width="256" x="64" y="-192" height="384" />
        </blockdef>
        <block symbolname="buf" name="XLXI_24">
            <blockpin signalname="asdasd" name="I" />
            <blockpin signalname="ikljhfluiysdliy" name="O" />
        </block>
        <block symbolname="Clock_Divider" name="XLXI_25">
            <blockpin signalname="clk" name="i_Clk" />
            <blockpin signalname="asdasd" name="o_Clk_Div" />
        </block>
        <block symbolname="and2" name="XLXI_29">
            <blockpin signalname="ikljhfluiysdliy" name="I0" />
            <blockpin signalname="led" name="I1" />
            <blockpin signalname="sclk" name="O" />
        </block>
        <block symbolname="buf" name="XLXI_31">
            <blockpin signalname="write_cmd" name="I" />
            <blockpin signalname="write_cmd_to_arduino" name="O" />
        </block>
        <block symbolname="buf" name="XLXI_32">
            <blockpin signalname="tig" name="I" />
            <blockpin signalname="tik_cmd" name="O" />
        </block>
        <block symbolname="Delay_Rising_Edge" name="XLXI_33">
            <blockpin signalname="clk" name="clk" />
            <blockpin signalname="write_cmd" name="signal_in" />
            <blockpin signalname="tig" name="signal_out" />
        </block>
        <block symbolname="Parallel_Data_Transmitter" name="XLXI_39">
            <blockpin signalname="asdasd" name="clk" />
            <blockpin signalname="reset" name="reset" />
            <blockpin signalname="tig" name="i_tig" />
            <blockpin signalname="i_clk" name="i_clk_bus" />
            <blockpin signalname="i_bus(7:0)" name="i_bus(7:0)" />
            <blockpin signalname="led" name="o_en" />
            <blockpin signalname="data_out(7:0)" name="data_out(7:0)" />
        </block>
    </netlist>
    <sheet sheetnum="1" width="3520" height="2720">
        <iomarker fontsize="28" x="1120" y="1024" name="reset" orien="R180" />
        <iomarker fontsize="28" x="1760" y="1024" name="data_out(7:0)" orien="R0" />
        <branch name="data_out(7:0)">
            <wire x2="1760" y1="1024" y2="1024" x1="1536" />
            <wire x2="1536" y1="1024" y2="1040" x1="1536" />
            <wire x2="1664" y1="1040" y2="1040" x1="1536" />
            <wire x2="1664" y1="752" y2="752" x1="1584" />
            <wire x2="1664" y1="752" y2="1040" x1="1664" />
        </branch>
        <branch name="reset">
            <wire x2="1152" y1="1024" y2="1024" x1="1120" />
            <wire x2="1136" y1="752" y2="1008" x1="1136" />
            <wire x2="1152" y1="1008" y2="1008" x1="1136" />
            <wire x2="1152" y1="1008" y2="1024" x1="1152" />
            <wire x2="1200" y1="752" y2="752" x1="1136" />
        </branch>
        <branch name="asdasd">
            <wire x2="976" y1="896" y2="896" x1="832" />
            <wire x2="1152" y1="896" y2="896" x1="976" />
            <wire x2="976" y1="896" y2="1216" x1="976" />
            <wire x2="1152" y1="1216" y2="1216" x1="976" />
            <wire x2="1200" y1="624" y2="624" x1="1152" />
            <wire x2="1152" y1="624" y2="896" x1="1152" />
        </branch>
        <branch name="clk">
            <wire x2="432" y1="896" y2="896" x1="272" />
            <wire x2="448" y1="896" y2="896" x1="432" />
            <wire x2="432" y1="896" y2="1376" x1="432" />
            <wire x2="560" y1="1376" y2="1376" x1="432" />
        </branch>
        <branch name="ikljhfluiysdliy">
            <wire x2="1568" y1="1216" y2="1216" x1="1376" />
        </branch>
        <instance x="1568" y="1280" name="XLXI_29" orien="R0" />
        <branch name="led">
            <wire x2="1536" y1="1056" y2="1088" x1="1536" />
            <wire x2="1552" y1="1088" y2="1088" x1="1536" />
            <wire x2="1552" y1="1088" y2="1152" x1="1552" />
            <wire x2="1568" y1="1152" y2="1152" x1="1552" />
            <wire x2="1744" y1="1088" y2="1088" x1="1552" />
            <wire x2="1648" y1="1056" y2="1056" x1="1536" />
            <wire x2="1648" y1="816" y2="816" x1="1584" />
            <wire x2="1648" y1="816" y2="1056" x1="1648" />
        </branch>
        <branch name="sclk">
            <wire x2="1856" y1="1184" y2="1184" x1="1824" />
        </branch>
        <iomarker fontsize="28" x="1856" y="1184" name="sclk" orien="R0" />
        <iomarker fontsize="28" x="1744" y="1088" name="led" orien="R0" />
        <instance x="448" y="928" name="XLXI_25" orien="R0">
        </instance>
        <iomarker fontsize="28" x="272" y="896" name="clk" orien="R180" />
        <instance x="1152" y="1248" name="XLXI_24" orien="R0" />
        <iomarker fontsize="28" x="304" y="1440" name="write_cmd" orien="R180" />
        <iomarker fontsize="28" x="1936" y="1648" name="write_cmd_to_arduino" orien="R0" />
        <branch name="write_cmd">
            <wire x2="528" y1="1440" y2="1440" x1="304" />
            <wire x2="560" y1="1440" y2="1440" x1="528" />
            <wire x2="528" y1="1440" y2="1648" x1="528" />
            <wire x2="1152" y1="1648" y2="1648" x1="528" />
        </branch>
        <branch name="write_cmd_to_arduino">
            <wire x2="1936" y1="1648" y2="1648" x1="1376" />
        </branch>
        <iomarker fontsize="28" x="1632" y="1376" name="tik_cmd" orien="R0" />
        <branch name="tig">
            <wire x2="1120" y1="1376" y2="1376" x1="944" />
            <wire x2="1216" y1="1376" y2="1376" x1="1120" />
            <wire x2="1152" y1="1088" y2="1088" x1="1120" />
            <wire x2="1168" y1="1088" y2="1088" x1="1152" />
            <wire x2="1120" y1="1088" y2="1376" x1="1120" />
            <wire x2="1168" y1="816" y2="1088" x1="1168" />
            <wire x2="1200" y1="816" y2="816" x1="1168" />
        </branch>
        <instance x="1216" y="1408" name="XLXI_32" orien="R0" />
        <branch name="tik_cmd">
            <wire x2="1632" y1="1376" y2="1376" x1="1440" />
        </branch>
        <instance x="1152" y="1680" name="XLXI_31" orien="R0" />
        <instance x="560" y="1472" name="XLXI_33" orien="R0">
        </instance>
        <branch name="i_clk">
            <wire x2="848" y1="496" y2="496" x1="448" />
            <wire x2="848" y1="496" y2="880" x1="848" />
            <wire x2="1200" y1="880" y2="880" x1="848" />
        </branch>
        <branch name="i_bus(7:0)">
            <wire x2="1184" y1="608" y2="608" x1="480" />
            <wire x2="1184" y1="608" y2="944" x1="1184" />
            <wire x2="1200" y1="944" y2="944" x1="1184" />
        </branch>
        <iomarker fontsize="28" x="448" y="496" name="i_clk" orien="R180" />
        <iomarker fontsize="28" x="480" y="608" name="i_bus(7:0)" orien="R180" />
        <instance x="1200" y="784" name="XLXI_39" orien="R0">
        </instance>
    </sheet>
</drawing>