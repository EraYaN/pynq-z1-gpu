library IEEE;
use IEEE.std_logic_1164.ALL;
use work.parameter_def.ALL;

entity draw_line_tb is
end draw_line_tb;

architecture behaviour of draw_line_tb is
component draw_line is
	port(
		clk   : in    std_logic;
		reset : in    std_logic;
		enable: in    std_logic;
		x0  : in    std_logic_vector(SizeX-1 downto 0);
		y0  : in    std_logic_vector(SizeY-1 downto 0);
		x1  : in    std_logic_vector(SizeX-1 downto 0);
		y1  : in    std_logic_vector(SizeY-1 downto 0);
		color : in std_logic_vector(SizeColor-1 downto 0);
		asb : in std_logic;
		done  : out   std_logic;
		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
		draw_write :buffer std_logic;
		draw_can_access : in std_logic
	);
end component;
	--signalen
	signal clk, reset, enable, asb, draw_can_acces: std_logic;
	signal x0, x1 : std_logic_vector(SizeX-1 downto 0);
	signal y0, y1 : std_logic_vector(SizeY-1 downto 0);
	signal color : std_logic_vector(SizeColor-1 downto 0);
	signal draw_write, done : std_logic;
	
	
begin
	clk <='1' after 0 ns,
	      '0' after 10 ns when clk /= '0' else '1' after 10 ns;
	reset <= '1' after 0 ns,
		   '0' after 40 ns;
	draw_can_acces <= '1' after 0 ns;
	color <= "101010" after 0 ns;
	asb <= '0' after 0 ns;
	x0   <= "00001010" after 0 ns;
	y0	<= "1010111" after 0 ns;
	x1	<= "10101010" after 0 ns;
	y1	<= "0001111" after 0 ns;

	process
	begin
		wait until reset = '0';
		wait until rising_edge(clk);
		enable <= '1';
		wait until done = '1';
		wait until rising_edge(clk);
		enable <= '0';
	end process;
	
	connect: draw_line port map(
	  	clk              => clk,   
		reset            => reset, 
		enable           => enable,
		x0                => x0,
		y0                => y0,
		x1                => x1,
		y1                => y1,
		color            => color,
		asb              => asb,  
		draw_write       => draw_write,
		draw_can_access  => draw_can_acces,
		done			=> done
		);
	  
end behaviour;