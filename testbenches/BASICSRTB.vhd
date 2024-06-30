library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity BasicSRTB is
	
end entity;

architecture TB of BasicSRTB is

    signal clk     : std_logic := '0';
    signal reset   : std_logic := '0';
	signal shiftEN : std_logic;
    signal Din     : std_logic;
	signal Dout	   : std_logic_vector(7 downto 0);

component BasicSR is

	generic(
		chain_length 		: integer;
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


begin
    -- Instantiate the Unit Under Test (UUT)
    uut: BasicSR
      generic map(
		chain_length 		=>  8,
		direction			=> 'R'									-- L to the left, R to the right
	)
    port map(
	
        clk    		=> clk,
        reset   	=> reset,
        shiftEN 	=> shiftEN,
        Din     	=> Din,
		Dout		=> Dout
		
    );

    -- Clock process
clk <= not clk after 5ns;

    -- Stimulus process
    main: process
    begin
        -- Initialize inputs
        reset 	<= '1';
		shiftEN <= '0';
		Din 	<= '0';
        wait for 40 ns;
        reset 	<= '0';
        wait for 40 ns;

        -- RS232 transmitted here is 0x51 --> 0101 0001
      
		Din 	<= '1';
		wait for 4.3us;
        wait until rising_edge(clk);
		shiftEN <= '1';
		wait until rising_edge(clk);
        shiftEN <= '0';
		wait for 4.3us;
		
		for i in 0 to 2 loop
			Din 	<= '0';
			wait for 4.3us;
			wait until rising_edge(clk);
			shiftEN <= '1';
			wait until rising_edge(clk);
			shiftEN <= '0';
			wait for 4.3us;
		end loop;
		
		for i in 0 to 1 loop
			Din 	<= '1';
			wait for 4.3us;
			wait until rising_edge(clk);
			shiftEN <= '1';
			wait until rising_edge(clk);
			shiftEN <= '0';
			wait for 4.3us;
			
			Din 	<= '0';
			wait for 4.3us;
			wait until rising_edge(clk);
			shiftEN <= '1';
			wait until rising_edge(clk);
			shiftEN <= '0';
			wait for 4.3us;
		end loop;
        -- Finish simulation
        wait;
    end process;
end TB;
