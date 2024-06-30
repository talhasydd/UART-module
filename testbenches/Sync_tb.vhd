library ieee;
use ieee.std_logic_1164.all;

entity Sync_tb is
end entity;


architecture RTL of Sync_tb is

    component Sync is
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
    end component;
    
signal clk     : std_logic:= '0';
signal reset     : std_logic;
signal Async   : std_logic;
signal Synced  : std_logic;
        
begin

    clk <= not clk after 5ns;

    UUT : Sync
    generic map
    (
        IDLE_STATE  => '1'
    )
    port map
    (
        clk     => clk,
        reset   => reset,
        Async   => Async,
        Synced  => Synced
    );


    TestProcess:process
    begin
        reset <= '1';
        Async <= '1';
        wait for 100ns;
        reset <= '0';
        wait for 100ns;
        wait for 3ns;
        Async <= '0';
    
    
    
        wait;
    end process;


end RTL;