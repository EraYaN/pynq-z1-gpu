library IEEE;
use IEEE.std_logic_1164.ALL;
use work.parameter_def.ALL;

entity draw_sprite is
	generic (
		SizeDCounter : integer := 3;
		DCounterMax : integer := SizeColor;
		DCounterStart : integer := SizeColor
	);
	port(
		clk   : in    std_logic;
		reset : in    std_logic;
		enable: in    std_logic;
		id : in std_logic_vector(SizeSpriteID-1 downto 0);
		x  : in    std_logic_vector(SizeX-1 downto 0);
		y  : in    std_logic_vector(SizeY-1 downto 0);
		w : in    std_logic_vector(SizeX-1 downto 0);
		l  : in    std_logic_vector(SizeSpriteCounter-1 downto 0);
		color : in std_logic_vector(SizeColor-1 downto 0);
		asb : in std_logic;
		done  : out   std_logic;
		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata     :inout   std_logic_vector(SizeRAMData-1 downto 0);
		draw_write :out std_logic;
		draw_read :out std_logic;
		draw_can_access : in std_logic
	);
end draw_sprite;


