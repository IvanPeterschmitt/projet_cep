library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        rs1         : in w32;
        alu_y       : in w32;
        IR          : in w32;
        slt         : out std_logic;
        jcond       : out std_logic
    );
end entity;

architecture RTL of CPU_CND is

    signal x, y, r : signed(32 downto 0);
    signal z, s, ext : std_logic;

begin
    ext <= (not IR(12) and not IR(6)) or (IR(6) and not IR(13));
    x <= rs1(31) & signed(rs1) when ext = '1' else '0' & signed(rs1);
    y <= alu_y(31) & signed(alu_y) when ext = '1' else '0' & signed(alu_y);
    r <= x - y;
    z <= '1' when r = to_signed(0, r'length) else '0';
    s <= '0' when r(32) = '0' else '1';
    jcond <= ((z xor IR(12)) and not IR(14)) or ((s xor IR(12)) and IR(14));
    slt <= s; 
end architecture;
