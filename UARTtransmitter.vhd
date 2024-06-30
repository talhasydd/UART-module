library IEEE;
use IEEE.std_logic_1164.all;

entity UARTtransmitter is

generic(

	RS232_data_bits : integer;
	clockFreq		: integer;
	baudRate		: integer
);

port(


	clk 			: in std_logic;
	reset 			: in std_logic;
	
	TxStart 		: in std_logic;
	TxData  		: in std_logic_vector(RS232_data_bits - 1 downto 0);
	UART_tx_pin 	: out std_logic;
	TxReady			: out std_logic
	
	);
	
end entity;

architecture RTL of UARTtransmitter is 


signal TxPacket : std_logic_vector(RS232_data_bits+1 downto 0);
signal BaudClk  : std_logic;



component serializer is									-- declare serializer component

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

component BaudclkGenerator is							-- declare BaudClk component

	generic(
		numberOfClocks 	: integer;
		clockFreq 		: integer;
		baudRate 		: integer;
		UART_RX			: boolean;

	);	
	
	port(

		clk 		: in std_logic;
		reset 		: in std_logic;
		
		Start		: in std_logic;
		Ready		: out std_logic;
		BaudClk		: out std_logic


	);
	end component;

begin

TxPacket <= '1' & TxData & '0';

	UART_serializer : serializer								-- instantiate component

	generic map(

		width 			=> RS232_data_bits + 2,
		default_state	=> '1'
		
	)

	port map(

		clk 		=> clk,
		reset 		=> reset,
		
		ShiftEN 	=> BaudClk,									-- shift enable driven by BaudClk
		Load 		=> TxStart,
		Din 		=> TxPacket,
		Dout 		=> UART_tx_pin

	);


	UART_BaudCLK : BaudclkGenerator								-- instantiate component

	generic map(
		numberOfClocks 	 => RS232_data_bits + 2,
		clockFreq 		 => clockFreq,
		baudRate 		 => baudRate,
		UART_RX          => false
	)	
	port map(

		clk 		=> clk,				-- port on the left-hand side, signals on the right
		reset 		=> reset,
		
		Start		=> TxStart,
		Ready		=> TxReady,
		BaudClk		=> BaudClk

	);



end RTL;