----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date: 07.12.2024 11:02:53
-- Design Name:
-- Module Name: FSMD - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------


library IEEE;library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSMD is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           start : in STD_LOGIC;
           sclk: out STD_LOGIC;
           cs: out STD_LOGIC;
           
           miso: in STD_LOGIC;
           mosi: in STD_LOGIC;
           adat_be: in STD_LOGIC_VECTOR(0 to 15);
           adat_ki: in STD_LOGIC_VECTOR(0 to 15)
           );
end FSMD;

architecture Behavioral of FSMD is

type allapot_tipus is (RDY,INIT1,W1,INIT2,W2,INIT3,W3,INIT4,W4,INIT5,W5,INIT6,Vege);

signal akt_all, kov_all: allapot_tipus;
signal Rk, Rk_Next: std_logic_vector(4 downto 0); --küls? ciklus számláló (16 tól dekrementálódik)
signal Ri, Ri_next: std_logic_vector(6 downto 0); -- bels? ciklus számláló
signal M1, M2, M3: std_logic_vector(6 downto 0);
signal Reg_be, Reg_be_next: std_logic_vector(15 downto 0);
signal Reg_ki, Reg_ki_next: std_logic_vector(15 downto 0);
signal Reg_status: std_logic;

begin

AR: process(clk,reset)
    begin
    if (reset='1') then
        akt_all <= RDY;
    elsif (clk'event and clk='1') then
        akt_all <= kov_all;
    end if;
end process AR;

KAL: process(akt_all,start,Ri,Rk)
        begin
        case akt_all is
        when RDY =>
            if start='1' then
                kov_all <= INIT1;
            else
                kov_all <= RDY;
            end if;
        when INIT1 =>
            kov_all <= W1;
        when W1 =>
            if Ri>0 then
                kov_all <= W1;
            else
                kov_all <= INIT2;
            end if;
        when INIT2 =>
            kov_all <= W2;
        when W2 =>
            if Ri>0 then
                kov_all <=W2;
            else
                kov_all <= INIT3;
            end if;
        when INIT3 =>
            kov_all <= W3;
        when W3 =>
            if Ri>0 then
                kov_all <= W3;
            else
                kov_all <= INIT4;
            end if;
        when INIT4 =>
            kov_all <= W4;
        when W4 =>
            if Ri>0 then
                kov_all <= W4;
            else
                kov_all <= INIT5;
            end if;
        when INIT5 =>  -- itt ellen?rzi, hogy az Rk>0, ha igen akkor visszaugrassza a W3-ba
            if Rk>0 then
                kov_all <= W3;
            else
                kov_all <= INIT6;
            end if;
        when INIT6 =>
            kov_all <= W5;
        when W5 =>
            if Ri>0 then
                kov_all <= W5;
            else
                kov_all <= Vege;
            end if;
        when Vege =>
            kov_all <= RDY;
         when others =>
            kov_all <= RDY;
        end case;
end process;

RK_reg: process(clk)
    begin
    if clk'event and clk='1' then
        Rk <= Rk_next;
    end if;
end process;

with akt_all select
        Rk_next<=Rk when RDY,
                 "10000" when INIT1, --16
                 Rk when W1,
                 Rk when INIT2,
                 Rk when W2,
                 Rk when INIT3,
                 Rk when W3,
                 Rk when INIT4,
                 Rk when W4,
                 Rk - 1 when INIT5,
                 Rk when W5,
                 Rk when INIT6,
                 Rk when Vege;
               
Ri_reg: process(clk)
    begin
    if clk'event and clk='1' then
        Ri <= Ri_next;
    end if;
end process;
                 
with akt_all select
        Ri_next<=Ri when RDY,
                 M1 when INIT1,
                 Ri-1 when W1,
                 M2 when INIT2,
                 Ri-1 when W2,
                 M3 when INIT3,
                 Ri-1 when W3,
                 M3 when INIT4, -- a magas és alacsony állapot is M3 ideig tart
                 Ri-1 when W4,
                 M3 when INIT5,
                 Ri-1 when W5,
                 M2 when INIT6,
                 Ri-1 when Vege;
                 
Register_be: process(clk)
    begin
    if clk'event and clk='1' then
        Reg_be <= Reg_be_next;
    end if;
end process;

with akt_all select
    Reg_be_next <= Reg_be when RDY,
                 Reg_be when INIT1,
                 Reg_be when W1,
                 Reg_be when INIT2,
                 Reg_be when W2,
                 Reg_be when INIT3,
                 Reg_be when W3,
                 miso & Reg_be(14 downto 0) when INIT4,
                 Reg_be when W4,
                 Reg_be when INIT5,
                 Reg_be when W5,
                 Reg_be when INIT6,
                 Reg_be when Vege;
                 
Register_ki: process(clk)
    begin
    if clk'event and clk='1' then
        Reg_ki <= Reg_ki_next;
    end if;
end process;

with akt_all select
    Reg_ki_next <= Reg_ki when RDY,
                 Reg_ki when INIT1,
                 Reg_ki when W1,
                 Reg_ki when INIT2,
                 Reg_ki when W2,
                 Reg_ki when INIT3,
                 Reg_ki when W3,
                 Reg_ki when INIT4,
                 Reg_ki when W4,
                 mosi & Reg_ki(15 downto 1)  when INIT5,
                 Reg_ki when W5,
                 Reg_ki when INIT6,
                 Reg_ki when Vege;


-- chip select
with akt_all select
cs <= '1' when RDY,
    '1' when INIT1,
    '1' when W1,
    '0' when INIT2,
    '0' when W2,
    '0' when INIT3,
    '0' when W3,
    '0' when INIT4,
    '0' when W4,
    '0' when INIT5,
    '0' when INIT6,
    '0' when W5,
    '1' when vege;

-- serial clock --megfordítottam
with akt_all select
sclk <= '0' when RDY,
    '0' when INIT1,
    '0' when W1,
    '0' when INIT2,
    '0' when W2,
    '0' when INIT3,
    '1' when W3,
    '1' when INIT4,
    '0' when W4,
    '0' when INIT5,
    '1' when INIT6,
    '1' when W5,
    '0' when vege;
   
-- a reg status azt jelzi, hogy mikor lesz vege
with akt_all select
Reg_status <=  '1' when RDY,
        '0' when INIT1,
        '0' when W1,
        '0' when INIT2,
        '0' when W2,
        '0' when INIT3,
        '0' when W3,
        '0' when INIT4,
        '0' when W4,
        '0' when INIT5,
        '0' when INIT6,
        '0' when W5,
        '1' when vege;

end Behavioral;