library ieee;
use ieee.std_logic_1164.all;

entity UARTreceiver is
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
end entity;


architecture RTL of UARTreceiver is

	   
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
    
   component BaudclkGenerator is

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
    
   
	component BasicSR is

	generic(
		chain_length		: integer;
		direction			: character									-- L to the left, R to the right
	);
    port(
	
        clk     : in std_logic;
        reset   : in std_logic;
        shiftEN : in std_logic;
        Din     : in std_logic;
		Dout	: out std_logic_vector(chain_length - 1 downto 0)
		
    );
	end component;
    
    type SMDataType is (IDLE, COLLECT_RS232_DATA, ASSERT_IRQ);
    
    signal SMStateVariable          : SMDataType;
    signal RS232_Rx_Synced          : std_logic;
    signal Start                    : std_logic;
    signal Baudclk                  : std_logic;
    signal Ready                    : std_logic;
    signal FallingEdge              : std_logic;
    signal RS232_Rx_Synced_Delay    : std_logic;
 
begin

    Sync_Rx : Sync
    generic map
    (
        IDLE_STATE  => '1'
    )
    port map
    (
        clk     => clk,
        reset   => reset,
        Async   => RS232_Rx,
        Synced  => RS232_Rx_Synced
    );

    
    BaudclkGenerator_Rx : BaudclkGenerator
    generic map
    (
        numberOfClocks   => dataWidth + 1,
        clockFreq        => clockFreq,
        baudRate         => baudRate,
        UART_RX          => true
    )
    port map
    (
        clk     => clk,
        reset   => reset,
        
        Start   => Start,
        Baudclk => Baudclk,
        Ready   => Ready
    );

    
    ShiftRegister_Rx : BasicSR
    generic map
    (
        chain_length    => dataWidth,
        direction 		=> 'R' 				-- 'L' generates a shift to the left. 'R' generates a shift to the right
    )
    port map
    (
        clk     => clk,
        reset   => reset,
        
        ShiftEn => Baudclk,
        Din     => RS232_Rx_Synced,
        Dout    => RxData
    );


    FallingEdgeDetect:process(reset,clk)	--high to low transition on the receive line which indicates arrival of new data.
    begin
        if reset = '1' then
            FallingEdge <= '0';
            RS232_Rx_Synced_Delay <= '1';
        elsif rising_edge(clk) then
            RS232_Rx_Synced_Delay <= RS232_Rx_Synced;
            
            if RS232_Rx_Synced = '0' and RS232_Rx_Synced_Delay = '1' then
                FallingEdge <= '1';
            else
                FallingEdge <= '0';
            end if;
        end if;
    end process;
    
    
    RxStateMachine:process(reset,clk)
    begin
        if reset = '1' then
            Start <= '0';
            RxIRQ <= '0';
            SMStateVariable <= IDLE;
        elsif rising_edge(clk) then
        
            if RxIRQClear = '1' then
                RxIRQ <= '0';
            end if;
        
            case SMStateVariable is
                
                when IDLE =>
                    if FallingEdge = '1' then
                        Start <= '1';
                    else
                        Start <= '0';
                    end if;
                    
                    if Ready = '0' then
                        SMStateVariable <= COLLECT_RS232_DATA;
                    end if;
                    
                when COLLECT_RS232_DATA =>
                    Start <= '0';
                    if Ready = '1' then
                        SMStateVariable <= ASSERT_IRQ;
                    end if;
                    
                when ASSERT_IRQ =>
                    RxIRQ <= '1';
                    SMStateVariable <= IDLE;
                    
                when others => 
                    SMStateVariable <= IDLE;
                    
            end case;
            
        end if;
    end process;
    
end rtl;