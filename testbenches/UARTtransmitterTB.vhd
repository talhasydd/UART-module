library IEEE;
use IEEE.std_logic_1164.all;

entity UARTTB is

generic(

	RS232_data_bits : integer := 8;
	clockFreq		: integer := 100000000;
	baudRate		: integer := 115200
);


end entity;

architecture TB of UARTTB is


signal 	clk 			: std_logic := '0';
signal	reset 			: std_logic := '0';
		
signal	TxStart 		: std_logic;
signal	TxData  		: std_logic_vector(RS232_data_bits - 1 downto 0);
signal	UART_tx_pin 	: std_logic;
signal	TxReady			: std_logic;
		
component UARTtransmitter is

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
		
	end component;

begin


Transmitter : UARTtransmitter

	generic map(

		RS232_data_bits => RS232_data_bits,
		clockFreq		=> clockFreq,
		baudRate		=> baudRate
	)

	port map(


		clk 			=> clk,
		reset 			=> reset,
		
		TxStart 		=> TxStart,
		TxData  		=> TxData,
		UART_tx_pin 	=> UART_tx_pin,
		TxReady			=> TxReady
		
		);

clk <= not clk after 5ns;



	main : process
	begin
		
		reset 	<= '1';
		TxStart <= '0';
		TxData 	<= (others => '0');
		wait for 40ns;
		reset 	<= '0';
		wait for 40ns;

		wait until rising_edge(clk);
		TxStart <= '1';
		TxData  <= x"AA";
		
		wait until rising_edge(clk);
		TxStart <= '0';
		TxData 	<= (others => '0');

		wait;
	end process;

end tb;
