library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FSMD_tb is
end FSMD_tb;

architecture Behavioral of FSMD_tb is

    -- Komponens deklaráció az FSMD-hez
    component FSMD
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            start : in STD_LOGIC;
            sclk : out STD_LOGIC;
            cs : out STD_LOGIC;
            mosi : in STD_LOGIC;
            miso: in STD_LOGIC;
            adat_be : in STD_LOGIC_VECTOR(15 downto 0);
            adat_ki: in STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;


    -- Jelek az FSMD modulhoz
    signal clk : STD_LOGIC := '0';
    signal reset : STD_LOGIC := '0';
    signal start : STD_LOGIC := '0';
    signal sclk : STD_LOGIC;
    signal cs : STD_LOGIC;
    signal mosi : STD_LOGIC;
    signal miso : STD_LOGIC;
    signal adat_be : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal adat_ki : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');

    -- Időzítés paraméterek
    constant clk_period : time := 10 ns;

begin

    -- FSMD komponens instanciálása
uut: FSMD
   Port map (
   clk => clk,
   reset => reset,
   start => start,
   sclk => sclk,
   cs => cs,
   mosi => mosi,
   miso => miso,
   adat_be => adat_be,
   adat_ki => adat_ki);

    -- Órajel generálása
    clk_process: process
    begin
        wait for clk_period;
        clk <= not clk;
    end process;
    
    stim_process : process
    begin
        reset <= '1';
        wait for clk_period*2;
        reset <= '0';
        
        start <= '1';
        -- példa adatra
        adat_be <= "0000000000001111";
        wait for clk_period*15;
        start <= '0';
        
    wait;
    end process;
    
    

end Behavioral;