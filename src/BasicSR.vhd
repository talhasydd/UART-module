library IEEE;
use IEEE.std_logic_1164.all;

entity BasicSR is

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
end entity;

architecture RTL of BasicSR is

    signal SR  			: std_logic_vector(chain_length - 1 downto 0);
	
begin


	Dout <= SR;
	
	SHIFT_TO_THE_RIGHT : if direction = 'R' generate
	--Shift SR to the right, used when transmitted data LSB first
		process(clk, reset)
		begin
			if reset = '1' then
			
				SR <= (others => '0');
				
			elsif clk'event and clk = '1' then
				
				if shiftEN = '1' then
				
					SR <= Din & SR(SR'Left downto 1);						--transmitted LSB first, shifts to the right
				
				end if;
			end if;
		end process;	
	end generate;
	
	
	SHIFT_TO_THE_LEFT : if direction = 'L' generate
	--Shift SR to the left, used when transmitted data MSB first
	
		process(clk, reset)
		begin
			if reset = '1' then
			
				SR <= (others => '0');
				
			elsif clk'event and clk = '1' then
				
				if shiftEN = '1' then
				
					SR <= SR(SR'Left -1  downto 0) & Din;						--transmitted MSB first, shifts to the left
				
				end if;
			end if;
		end process;
	end generate;
	

end RTL;
