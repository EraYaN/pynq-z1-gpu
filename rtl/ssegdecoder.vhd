library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- Naar: SN74LS247 van commentaar van "imode" op "http://vhdlguru.blogspot.nl/2010/03/vhdl-code-for-bcd-to-7-segment-display.html"
entity ssegdecoder is
	port(		
		bin_input : in STD_LOGIC_VECTOR (15 downto 0);		
		segments : out STD_LOGIC_VECTOR (27 downto 0)-- "DP,G,F,E,D,C,B,A"				
	);
end ssegdecoder;

architecture Behavioral of ssegdecoder is
signal hex0,hex1,hex2,hex3 : std_logic_vector(6 downto 0);
alias bin3 is bin_input(15 downto 12);
alias bin2 is bin_input(11 downto 8);
alias bin1 is bin_input(7 downto 4);
alias bin0 is bin_input(3 downto 0);
begin
hex3 <=
	"0111111" when bin3 = "0000" else -- 0
	"0000110" when bin3 = "0001" else -- 1
	"1011011" when bin3 = "0010" else -- 2
	"1001111" when bin3 = "0011" else -- 3
	"1100110" when bin3 = "0100" else -- 4
	"1101101" when bin3 = "0101" else -- 5
	"1111101" when bin3 = "0110" else -- 6
	"0000111" when bin3 = "0111" else -- 7
	"1111111" when bin3 = "1000" else -- 8
	"1101111" when bin3 = "1001" else -- 9
	"1110111" when bin3 = "1010" else -- 10 (A)
	"1111100" when bin3 = "1011" else -- 11 (b)
	"0111001" when bin3 = "1100" else -- 12 (C)
	"1011110" when bin3 = "1101" else -- 13 (d)
	"1111001" when bin3 = "1110" else -- 14 (E)
	"1110001" when bin3 = "1111" else -- 15 (F)
	"0000000";
hex2 <=
	"0111111" when bin2 = "0000" else -- 0
	"0000110" when bin2 = "0001" else -- 1
	"1011011" when bin2 = "0010" else -- 2
	"1001111" when bin2 = "0011" else -- 3
	"1100110" when bin2 = "0100" else -- 4
	"1101101" when bin2 = "0101" else -- 5
	"1111101" when bin2 = "0110" else -- 6
	"0000111" when bin2 = "0111" else -- 7
	"1111111" when bin2 = "1000" else -- 8
	"1101111" when bin2 = "1001" else -- 9
	"1110111" when bin2 = "1010" else -- 10 (A)
	"1111100" when bin2 = "1011" else -- 11 (b)
	"0111001" when bin2 = "1100" else -- 12 (C)
	"1011110" when bin2 = "1101" else -- 13 (d)
	"1111001" when bin2 = "1110" else -- 14 (E)
	"1110001" when bin2 = "1111" else -- 15 (F)
	"0000000";

hex1 <=
	"0111111" when bin1 = "0000" else -- 0
	"0000110" when bin1 = "0001" else -- 1
	"1011011" when bin1 = "0010" else -- 2
	"1001111" when bin1 = "0011" else -- 3
	"1100110" when bin1 = "0100" else -- 4
	"1101101" when bin1 = "0101" else -- 5
	"1111101" when bin1 = "0110" else -- 6
	"0000111" when bin1 = "0111" else -- 7
	"1111111" when bin1 = "1000" else -- 8
	"1101111" when bin1 = "1001" else -- 9
	"1110111" when bin1 = "1010" else -- 10 (A)
	"1111100" when bin1 = "1011" else -- 11 (b)
	"0111001" when bin1 = "1100" else -- 12 (C)
	"1011110" when bin1 = "1101" else -- 13 (d)
	"1111001" when bin1 = "1110" else -- 14 (E)
	"1110001" when bin1 = "1111" else -- 15 (F)
	"0000000";

hex0 <=
	"0111111" when bin0 = "0000" else -- 0
	"0000110" when bin0 = "0001" else -- 1
	"1011011" when bin0 = "0010" else -- 2
	"1001111" when bin0 = "0011" else -- 3
	"1100110" when bin0 = "0100" else -- 4
	"1101101" when bin0 = "0101" else -- 5
	"1111101" when bin0 = "0110" else -- 6
	"0000111" when bin0 = "0111" else -- 7
	"1111111" when bin0 = "1000" else -- 8
	"1101111" when bin0 = "1001" else -- 9
	"1110111" when bin0 = "1010" else -- 10 (A)
	"1111100" when bin0 = "1011" else -- 11 (b)
	"0111001" when bin0 = "1100" else -- 12 (C)
	"1011110" when bin0 = "1101" else -- 13 (d)
	"1111001" when bin0 = "1110" else -- 14 (E)
	"1110001" when bin0 = "1111" else -- 15 (F)
	"0000000";
	
segments <= NOT (hex3 & hex2 & hex1 & hex0);
end Behavioral;