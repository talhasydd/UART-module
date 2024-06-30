library IEEE;
use IEEE.std_logic_1164.all;

entity testbench is


end entity;

architecture TB of testbench is

component BaudclkGenerator is

	generic(
		numberOfClocks 	: integer;
		clockFreq 		: integer;
		baudRate 		: integer
	);	
	port(

		clk 		: in std_logic;
		reset 		: in std_logic;
		
		Start		: in std_logic;
		Ready		: out std_logic;
		BaudClk		: out std_logic


	);
end component;

signal clk : std_logic := '0';
signal reset, Start, Ready, BaudClk : std_logic;

begin

	UUT: BaudclkGenerator

	generic map (
		numberOfClocks 	=> 10,
		clockFreq 		=> 100000000,
		baudRate 		=> 115200
	)	
	port map (

		clk 		=> clk,				-- port on the left-hand side, signals on the right
		reset 		=> reset,
		
		Start		=> Start,
		Ready		=> Ready,
		BaudClk		=> BaudClk


	);
	
clk <= not clk after 5ns;


process
begin

	reset <= '1';
	Start <= '0';
	wait for 50ns;
	reset <= '0';
	
	
	wait until rising_edge(clk);
	Start <= '1';
	wait until rising_edge(clk);
	Start <= '0';
	

	
	wait;					-- stops process from looping around since there is no sensitivity list
end process;

end TB;