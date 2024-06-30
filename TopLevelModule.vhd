library IEEE;
use IEEE.std_logic_1164.all;

entity TopLevelModule is

generic 
(
    RS232_data_bits : integer := 8;
    clockFreq    	: integer := 100000000;
    baudRate       	: integer := 115200
);
port
(
    clk             : in std_logic;
    reset           : in std_logic;
    
    -- RS232 ports which connect to the PC's COMM port
    rs232_rx_pin    : in std_logic;
    rs232_tx_pin    : out std_logic
);

end entity;


architecture RTL of TopLevelModule is 


	component UARTtransmitter is

		generic
		(
			RS232_data_bits : integer;
			clockFreq		: integer;
			baudRate		: integer
		);

		port
		(
			clk 			: in std_logic;
			reset 			: in std_logic;
			
			TxStart 		: in std_logic;
			TxData  		: in std_logic_vector(RS232_data_bits - 1 downto 0);
			UART_tx_pin 	: out std_logic;
			TxReady			: out std_logic
			
			);
			
	end component;

	component UARTreceiver is
		generic 
		(
			dataWidth      	: integer;
			clockFreq    	: integer;
			baudRate       	: integer
		);
		port
		(
			clk         : in std_logic;
			reset       : in std_logic;
			RS232_Rx    : in std_logic; -- Serial asynchronous signal transmitted by the COMM port of PC.
			RxIRQClear  : in std_logic; -- to clear interrupt
			RxIRQ       : out std_logic; -- tells us when new data is available on the Rxdata port.
			RxData      : out std_logic_vector(dataWidth - 1 downto 0)
		);
	end component;


type SMType is (IDLE, START_TRANSMITTER);
 
    signal SMVariable   : SMType;
    signal TxStart      : std_logic;
    signal TxReady      : std_logic;
    signal RxIRQ        : std_logic;
    signal RxData       : std_logic_vector(RS232_data_bits - 1 downto 0);
	
begin


UARTtx : UARTtransmitter

	generic map 
	(
		RS232_data_bits => RS232_data_bits,
		clockFreq		=> clockFreq,
		baudRate		=> baudRate
	)

	port map 
	(
		clk 			=> clk,
		reset 			=> reset,
		
		TxStart 		=> TxStart,
		TxData  		=> RxData,
		UART_tx_pin 	=> rs232_tx_pin,
		TxReady			=> TxReady
		
		);


UARTrx : UARTreceiver 

	generic map
	(
		dataWidth      	=> RS232_data_bits,
		clockFreq    	=> clockFreq,
		baudRate       	=> baudRate
	)
	port map
	(
		clk         => clk,
		reset       => reset,
		RS232_Rx    => rs232_rx_pin,
		RxIRQClear  => TxStart,
		RxIRQ       => RxIRQ,
		RxData      => RxData
	);



    StateMachineProcess:process(reset, clk)
    begin
        if reset = '1' then
            SMVariable <= IDLE;
            TxStart <= '0';
        elsif rising_edge(clk) then
        
            case SMVariable is
                
                when IDLE =>
                    if RxIRQ = '1' and TxReady = '1' then
                        SMVariable <= START_TRANSMITTER;
                        TxStart <= '1';
                    end if;
                    
                when START_TRANSMITTER =>
                    TxStart <= '0';
                    SMVariable <= IDLE;
                    
                when others =>
                    SMVariable <= IDLE;
                    
            end case;
            
        end if;
    end process;

end RTL;