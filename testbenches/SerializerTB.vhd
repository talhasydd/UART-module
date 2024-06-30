library IEEE;
use IEEE.std_logic_1164.all;

entity serializerTB is

generic(

	width 			: integer := 8;
	default_state	: std_logic:= '1'
	
);

end entity;

architecture TB of serializerTB is

component serializer is

generic(

	width 			: integer;
	default_state	: std_logic
	
);

port(

	clk 		: in std_logic;
	reset 		: in std_logic;
	
	ShiftEN 	: in std_logic;
	Load 		: in std_logic;
	Din 		: in std_logic_vector(width-1 downto 0);
	Dout 		: out std_logic

);
end component;


signal clk 			: std_logic := '0';
signal reset 		: std_logic := '0';

signal Load			: std_logic;
signal Dout			: std_logic;
signal Din			: std_logic_vector(width-1 downto 0);
signal ShiftEN		: std_logic;


begin

	UUT : serializer

	generic map(

		width 			=> width,
		default_state	=> default_state
		
	)

	port map(

		clk 		=> clk,
		reset 		=> reset,
		
		ShiftEN 	=> ShiftEN,
		Load 		=> Load,
		Din 		=> Din,
		Dout 		=> Dout

	);



clk <= not clk after 5ns;


main: process
begin


	reset 	<= '1';
	ShiftEN <= '0';
	Load 	<= '0';
	Din		<= (others => '0');
	wait for 50ns;
	reset 	<= '0';
	wait for 50ns;
	
	wait until rising_edge(clk);				
	Load 	<= '1';
	Din		<= x"AA";
	
	wait until rising_edge(clk);	
	Load	<= '0';
	Din 	<= (others => '0');
	
	for i in 0 to 7 loop
		wait for 8.7us; 		--bit period
		wait until rising_edge(clk);				
		ShiftEN	<= '1';

		wait until rising_edge(clk);				
		ShiftEN	<= '0';
	end loop; 

	
	
	
	
wait;
end process;

end TB;

