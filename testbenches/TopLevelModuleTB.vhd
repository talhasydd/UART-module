library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TopLevelModule_tb is
generic 
(
    RS232_data_bits : integer := 8
);
end entity;


architecture RTL of TopLevelModule_tb is

    component TopLevelModule is
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
    end component;
    
signal clk                  : std_logic := '0';
signal reset                : std_logic;
signal rs232_rx_pin         : std_logic;
signal rs232_tx_pin         : std_logic;
signal TransmittedData      : std_logic_vector(RS232_data_bits - 1 downto 0);
signal DataTransmittedToPC  : std_logic_vector(RS232_data_bits - 1 downto 0);
        
begin
    
    clk <= not clk after 5ns;
    
    UUT : TopLevelModule
    generic map
    (
        RS232_data_bits 	=> RS232_data_bits,
        clockFreq   	 	=> 100000000,
        baudRate       		=> 115200
    )
    port map
    (
        clk             => clk,
        reset         	=> reset,
        
        -- RS232 ports which connect to the PC's COMM port
        rs232_rx_pin    => rs232_rx_pin,
        rs232_tx_pin    => rs232_tx_pin
    );

    
    SerialToParallel:process
    begin
        -- Waiting for the start bit
        wait until falling_edge(rs232_tx_pin);
        
        -- Waits until the middle of the start bit
        wait for 4.3us;
        
        for i in 1 to RS232_data_bits loop
            -- Waits until the middle of the next bit
            wait for 8.7us;
            -- Capture the value of the next bit into TransmittedData
            TransmittedData(i-1) <= rs232_tx_pin;
        end loop;
        
        -- Last wait is to wait until the stop bit has been transmitted
        wait for 8.7us;
        DataTransmittedToPC <= TransmittedData;
    end process;
    
    TestProcess:process
    
        variable TransmitDataVector : std_logic_vector(RS232_data_bits - 1 downto 0);
        
        procedure TRANSMIT_CHARACTER
        (
            constant TransmitData : in integer
        ) is
        begin
			-- converting constant std_logic_vector type
            TransmitDataVector := std_logic_vector(to_unsigned(TransmitData, RS232_data_bits));
			
            -- Transmit Start Bit
            rs232_rx_pin <= '0';
            wait for 8.7us;
            
            -- Transmit Data Bits LSB first
            for i in 1 to RS232_data_bits loop
                rs232_rx_pin <= TransmitDataVector(i-1);
                wait for 8.7us;
            end loop;
            
            -- Transmit Stop Bit
            rs232_rx_pin <= '1';
            wait for 8.7us;
        end procedure;
    
    begin
        reset <= '1';
        rs232_rx_pin <= '1';
        wait for 100ns;
        reset <= '0';
        wait for 100ns;
        
        --trasnmitting 256 different characters to the UUT);
        for i in 0 to 10 loop
            TRANSMIT_CHARACTER(i);
            wait for 20us;
        end loop;
        
        
        wait;
    end process;
    
end RTL;