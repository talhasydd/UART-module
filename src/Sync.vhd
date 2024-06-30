library ieee;
use ieee.std_logic_1164.all;

entity Sync is
generic 
(
    IDLE_STATE  : std_logic
);
port
(
    clk     : in std_logic;
    reset     : in std_logic;
    Async   : in std_logic;
    Synced  : out std_logic
);
end entity;


architecture RTL of Sync is

    signal SR : std_logic_vector(1 downto 0);
    
begin

    Synced <= SR(1);
    
    SynchornisationProcess:process(reset, clk)
    begin
        if reset = '1' then
            SR <= (others => IDLE_STATE);
        elsif rising_edge(clk) then
            SR(0) <= Async;
            SR(1) <= SR(0);
        end if;
    end process;

end RTL;