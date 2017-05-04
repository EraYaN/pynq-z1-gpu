library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.All;
use work.parameter_def.ALL;

entity draw_sprite_tb is
generic (
	CLOCKPERIOD : time := 160 ns;
	HCLOCKPERIOD : time := 80 ns
);
end draw_sprite_tb;

architecture behaviour of draw_sprite_tb is

component draw_sprite is
	port(
		clk : in std_logic;
		reset : in std_logic;
		enable: in std_logic;
		id : in std_logic_vector(SizeSpriteID-1 downto 0);
		x : in std_logic_vector(SizeX-1 downto 0);
		y : in std_logic_vector(SizeY-1 downto 0);
		w : in std_logic_vector(SizeX-1 downto 0);
		l : in std_logic_vector(SizeSpriteCounter-1 downto 0);
		color : in std_logic_vector(SizeColor-1 downto 0);
		asb : in std_logic;
		done : out std_logic;
		ramaddr :out std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata :inout std_logic_vector(SizeRAMData-1 downto 0);
		draw_write :out std_logic;
		draw_read :out std_logic;
		draw_can_access : in std_logic
	);
end component;
	
	--input signalen
	signal clk, reset, enable, asb, draw_can_access: std_logic;
	signal x, w : std_logic_vector(SizeX-1 downto 0);
	signal y, h : std_logic_vector(SizeY-1 downto 0);
	signal id : std_logic_vector(SizeSpriteID-1 downto 0);
	signal color : std_logic_vector(SizeColor-1 downto 0);
	
	--output signalen
	signal done, draw_write, draw_read : std_logic;
	signal ramaddr,startaddr : std_logic_vector(SizeRAMAddr-1 downto 0);
	signal ramdata : std_logic_vector(SizeRAMData-1 downto 0);
	

begin
	
	clk <= '1' after 0 ns,
	 '0' after HCLOCKPERIOD when clk /= '0' else '1' after HCLOCKPERIOD;
	ramdata <= "001010" WHEN draw_read = '1' ELSE (others => 'Z');
	
	asb <= '1';

	x <= std_logic_vector(to_unsigned(30,SizeX));
	w <= std_logic_vector(to_unsigned(6,SizeX));
	y <= std_logic_vector(to_unsigned(50,SizeY));
	h <= std_logic_vector(to_unsigned(8,SizeY));
	startaddr<=std_logic_vector(to_unsigned(120*256+64,SizeRAMAddr));
	id <= startaddr(SizeSpriteID-1 downto 0);
	color <= "101111";
process
	begin
		--setup
		reset <= '1';
		draw_can_access <= '1';
		enable <= '0';		
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		reset <= '0';
		wait until rising_edge(clk);
		enable <= '1';		
		wait until rising_edge(done);
		enable <= '0';
		wait;
	end process;

sprite: draw_sprite port map(
	clk=>clk,
	reset=>reset,
	enable=>enable,
	id=>id,
	x=>x,
	y=>y,
	w=>w,
	l=>h(SizeSpriteCounter-1 downto 0),
	color=>color,
	asb=>asb,
	done=>done,
	ramaddr=>ramaddr,
	ramdata=>ramdata,
	draw_write=>draw_write,
	draw_read=>draw_read,
	draw_can_access=>draw_can_access
); 

end behaviour;












