library IEEE;
use IEEE.std_logic_1164.all;

entity BaudclkGenerator is

generic(
	numberOfClocks 	: integer;
	clockFreq 		: integer;
	baudRate 		: integer;
	UART_RX			: boolean								-- true for UART receiver module, false for UART transmitter module

);	
port(

	clk 		: in std_logic;
	reset 		: in std_logic;
	
	Start		: in std_logic;
	Ready		: out std_logic;
	BaudClk		: out std_logic


);
end entity;

architecture RTL of BaudclkGenerator is

constant Period 		: integer := clockFreq/baudRate;
constant halfPeriod 	: integer := clockFreq/(2*baudRate);

signal 	PeriodCounter 	: integer range 0 to Period;
signal 	ClocksLeft		: integer range 0 to numberOfClocks;


begin

PeriodProcess : process( clk, reset)
begin

	if reset = '1' then
	
		BaudClk <= '0';
		PeriodCounter <= 0;
		
	elsif rising_edge(clk) then
	
		if ClocksLeft > 0 then
		
			if PeriodCounter = Period then
			
				BaudClk <= '1';
				PeriodCounter <= 0;
			else
			
				BaudClk <= '0';
				PeriodCounter <= PeriodCounter + 1;
			end if;
		else
		
			BaudClk <= '0';
			
			if UART_RX = true then
			-- receiver mode, first baudclk pulse occurs after 1/2 bitperiod after asserting start port
				PeriodCounter <= halfPeriod;
			else 
			-- transmitter mode, first baudclk pulse occurs after 1 bitperiod after asserting start port
				PeriodCounter <= 0;

			end if;
		end if;
	end if;
end process;


CountingProcess : process( clk, reset)
begin

	if reset = '1' then
		
		ClocksLeft <= 0;

	elsif rising_edge(clk) then
	
		if Start = '1' then
		
			ClocksLeft <= numberOfClocks;
			
		elsif BaudClk = '1' then
			ClocksLeft <= ClocksLeft - 1;
		end if;
	end if;
end process;

ReadyProcess : process(clk, reset)
begin
	if reset = '1' then
	
		Ready <= '1';
	
	elsif rising_edge(clk) then
	
		if Start = '1' then
			Ready <= '0';
			
		elsif ClocksLeft = 0 then
			Ready <= '1';
		end if;
	end if;
end process;

end RTL;

