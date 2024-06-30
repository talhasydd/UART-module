library IEEE;
use IEEE.std_logic_1164.all;

entity serializer is

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
end entity;

architecture RTL of serializer is

signal shiftRegister : std_logic_vector(width-1 downto 0);

begin

Dout <= shiftRegister(0);

serializer : process(clk, reset)
begin
	if reset = '1' then
	
		shiftRegister <= (others => default_state);

	elsif rising_edge(clk) then
	
		if Load = '1' then
		
			shiftRegister <= Din;
		
		elsif ShiftEN = '1' then
		
			shiftRegister <= default_state & shiftRegister(shiftRegister'left downto 1);
			
		end if;
	end if;
end process;	

end RTL;