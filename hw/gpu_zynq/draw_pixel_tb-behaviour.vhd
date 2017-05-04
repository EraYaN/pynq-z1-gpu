library IEEE;
use IEEE.std_logic_1164.ALL;
use work.parameter_def.ALL;

architecture behaviour of draw_pixel_tb is
component draw_pixel is
	port(
		clk   : in    std_logic;
		reset : in    std_logic;
		enable: in    std_logic;
		x  : 	in    std_logic_vector(SizeX-1 downto 0);
		y  : 	in    std_logic_vector(SizeY-1 downto 0);
		color : in 	  std_logic_vector(SizeColor-1 downto 0);
		asb : 	in    std_logic;
		done  : out   std_logic;
		ramaddr : out std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata : out std_logic_vector(SizeRAMData-1 downto 0);
		draw_write: out std_logic;
		draw_can_access : in std_logic
	);
end component;
	--signalen
	signal clk, reset, enable, asb, draw_can_access: std_logic;
	signal x			   : std_logic_vector(SizeX-1 downto 0);
	signal y			   : std_logic_vector(SizeY-1 downto 0);
	signal color		   : std_logic_vector(SizeColor-1 downto 0);
	signal done, draw_write: std_logic;
	signal ramaddr 		   :std_logic_vector(SizeRAMAddr-1 downto 0);
	signal ramdata 		   :std_logic_vector(SizeRAMData-1 downto 0);
	
	
	
	
begin
	draw_pixel_tb: draw_pixel port map (clk, reset, enable, x, y, color, asb, done, ramaddr, ramdata, draw_write, draw_can_access);
	clk <='1' after 0 ns,
	'0' after 10 ns when clk /= '0' else '1' after 10 ns;	
process
begin
	 --initalize everything
	enable <= '0';
	asb <= '0';
	draw_can_access <= '0';
	reset <= '1';
	color <= "101101";	
	x <= "00000000";
	y <= "0000000";

	wait for 40 ns;
	reset<= '0';
	draw_can_access <= '1';
	wait until rising_edge(clk);	
	enable <= '1';
	x <= "10101010"; 
	y <= "1010111";
	wait until done='1' and rising_edge(clk);
	enable <= '0';
	wait until rising_edge(clk);
	enable <= '1';
	x <= "11100111"; 
	y <= "1111000";
	wait until done='1' and rising_edge(clk);
	enable <= '0';
	wait;	
end process;		
end behaviour;



























