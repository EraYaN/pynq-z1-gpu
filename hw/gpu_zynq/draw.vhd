library IEEE;
use IEEE.std_logic_1164.ALL;
use work.parameter_def.ALL;

entity draw is
	port (
		--Clock/reset
		clk		: in	std_logic;	--Clock
		reset	: in	std_logic;	--Reset
		--Draw data
		id : in std_logic_vector(SizeSpriteID-1 downto 0); -- Sprite ID
		x			: in	std_logic_vector(SizeX-1 downto 0);				--Entity x coord
		w			: in	std_logic_vector(SizeX-1 downto 0);				--Entity width
		y			: in	std_logic_vector(SizeY-1 downto 0);				--Entity y coord
		h			: in	std_logic_vector(SizeY-1 downto 0);				--Entity height
		color		: in	std_logic_vector(SizeColor-1 downto 0);			--Entity Color
		en			: in	std_logic_vector(NumDrawModules-1 downto 0);	--Draw Module Enabled
		draw_ready	: out		std_logic;
		--Internal registers
		asb			: in		std_logic;	--Currently active screen buffer
		--RAM-controller interaction
		draw_write		: out	std_logic;
		draw_read		: out	std_logic;
		draw_can_access : in 	std_logic;
		--RAM interaction
		ramaddr	: out	std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata	: inout	std_logic_vector(SizeRAMData-1 downto 0)
	);
end entity draw;