library ieee;
use ieee.std_logic_1164.all;

entity UARTreceiverTB is
end entity;


architecture TB of UARTreceiverTB is

    component UART_rx is
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
        RxIRQClear  : in std_logic;
        RxIRQ       : out std_logic;
        RxData      : out std_logic_vector(dataWidth - 1 downto 0)
    );
    end component;

signal clk         : std_logic := '0';
signal reset       : std_logic;
signal RS232_Rx    : std_logic;
signal RxIRQClear  : std_logic;
signal RxIRQ       : std_logic;
signal RxData      : std_logic_vector(7 downto 0);

signal PCData      : std_logic_vector(7 downto 0) := x"AA";

begin

    clk <= not clk after 5ns;
    
    UUT : UART_rx
    generic map
    (
        dataWidth    => 8,
        clockFreq    => 50000000,
        baudRate     => 115200
    ) 
    port map
    (
        clk         => clk,
        reset       => reset,
        RS232_Rx    => RS232_Rx,
        RxIRQClear  => RxIRQClear,
        RxIRQ       => RxIRQ,
        RxData      => RxData
    );
    
    
    TestProcess:process
    begin
        reset <= '1';
        RS232_Rx <= '1';
        RxIRQClear <= '0';
        wait for 100ns;
        reset <= '0';
        wait for 100ns;
        
        -- Transmit Start Bit
        RS232_Rx <= '0';
        wait for 8.7us;
        
        -- Transmit Data Bits LSB first
        RS232_Rx <= PCData(0);
        wait for 8.7us;							-- waiting for 1 bit period.
        RS232_Rx <= PCData(1);
        wait for 8.7us;
        RS232_Rx <= PCData(2);
        wait for 8.7us;
        RS232_Rx <= PCData(3);
        wait for 8.7us;
        RS232_Rx <= PCData(4);
        wait for 8.7us;
        RS232_Rx <= PCData(5);
        wait for 8.7us;
        RS232_Rx <= PCData(6);
        wait for 8.7us;
        RS232_Rx <= PCData(7);
        wait for 8.7us;
        
        -- Transmit Stop Bit
        RS232_Rx <= '1';
        wait for 8.7us;
        
        wait for 50ns;
        
        wait until rising_edge(clk);
        RxIRQClear <= '1';
        wait until rising_edge(clk);
        RxIRQClear <= '0';
        
        wait;
    end process;
    
    
end TB;