-- Standard libraries
library ieee;
use ieee.std_logic_1164.all;

-- Entity declaration for 7 segment display
entity seven_seg is
	port
	(
		inputBCD  		: in std_logic_vector(3 downto 0); -- 4 bits input
		outputHEX 		: out std_logic_vector(7 downto 0) -- 8 bits output
	);
end seven_seg;

-- Architecture block
architecture behav of seven_seg is
begin
										 
	process(inputBCD)
	begin
		
		-- commond anode connection
		-- 0 - segment is ON
		-- 1 - segment is OFF
		case inputBCD is
			when "0000" => outputHEX <= "11000000"; --0
			when "0001" => outputHEX <= "11111001"; --1
			when "0010" => outputHEX <= "10100100"; --2
			when "0011" => outputHEX <= "10110000"; --3
			when "0100" => outputHEX <= "10011001"; --4
			when "0101" => outputHEX <= "10010010"; --5
			when "0110" => outputHEX <= "10000010"; --6
			when "0111" => outputHEX <= "11111000"; --7
			when "1000" => outputHEX <= "10000000"; --8
			when "1001" => outputHEX <= "10010000"; --9
			when "1010" => outputHEX <= "10001000"; --A
			when "1011" => outputHEX <= "10000011"; --B
			when "1100" => outputHEX <= "11000110"; --C
			when "1101" => outputHEX <= "10100001"; --D
			when "1110" => outputHEX <= "10000110"; --E
			when "1111" => outputHEX <= "10001110"; --F
			when others => outputHEX <= "00000000";
		end case;
			
	end process;	
	
end behav;
