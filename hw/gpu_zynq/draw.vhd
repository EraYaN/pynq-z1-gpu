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

architecture structural of draw is
	component draw_pixel
	port(
		clk   : in    std_logic;
		reset : in    std_logic;
		enable: in    std_logic;
		x  : in    std_logic_vector(SizeX-1 downto 0);
		y  : in    std_logic_vector(SizeY-1 downto 0);
		color : in std_logic_vector(SizeColor-1 downto 0);
		asb : in std_logic;
		done  : out   std_logic;
		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
		draw_write :out std_logic;
		draw_can_access : in std_logic
	);
	end component;

	component draw_rect
	port(
		clk   : in    std_logic;
		reset : in    std_logic;
		enable: in    std_logic;
		enablef: in    std_logic;
		x0  : in    std_logic_vector(SizeX-1 downto 0);
		y0  : in    std_logic_vector(SizeY-1 downto 0);
		x1 : in    std_logic_vector(SizeX-1 downto 0);
		y1  : in    std_logic_vector(SizeY-1 downto 0);
		color : in std_logic_vector(SizeColor-1 downto 0);
		asb : in std_logic;
		done  : out   std_logic;
		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
		draw_write :out std_logic;
		draw_can_access : in std_logic
	);
	end component;
	
	component draw_line
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
		draw_write :out std_logic;
		draw_can_access : in std_logic
	);
	end component;
	
	component draw_sprite is	
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
	end component;

	signal pixel_done,fill_done,rect_done,line_done,sprite_done : std_logic;
	signal pixel_write,fill_write,rect_write,line_write,sprite_write : std_logic;
	signal sprite_read : std_logic;
begin
	draw_ready <= pixel_done or rect_done or line_done or sprite_done;
	draw_write <= pixel_write or rect_write or line_write or sprite_write;
	draw_read <= sprite_read;
	-- pixel_done <= '0';
	-- rect_done <= '0';
	-- pixel_write <= '0';
	-- rect_write<='0';
	-- line_done <= '0';
	-- line_write <= '0';
	-- Module 0
	-- fill1: draw_fill port map (
		-- clk=>clk,
		-- reset=>reset,
		-- enable=>en(0),
		-- color=>color,
		-- asb=>asb,
		-- done=>fill_done,
		-- ramaddr=>ramaddr,
		-- ramdata=>ramdata,
		-- draw_write=>fill_write,
		-- draw_can_access=>draw_can_access
	-- );
	--Module 0
	pixel1: draw_pixel port map (
		clk=>clk,
		reset=>reset,
		enable=>en(0),
		x=>x,
		y=>y,
		color=>color,
		asb=>asb,
		done=>pixel_done,
		ramaddr=>ramaddr,
		ramdata=>ramdata,
		draw_write=>pixel_write,
		draw_can_access=>draw_can_access
	);
	--Module 1 and 2 (filled)
	rect1: draw_rect port map (
		clk=>clk,
		reset=>reset,
		enable=>en(1),
		enablef=>en(2),
		x0=>x,
		y0=>y,
		x1=>w,
		y1=>h,
		color=>color,
		asb=>asb,
		done=>rect_done,
		ramaddr=>ramaddr,
		ramdata=>ramdata,
		draw_write=>rect_write,
		draw_can_access=>draw_can_access
	);
	--Module 3
	line1: draw_line port map (
		clk=>clk,
		reset=>reset,
		enable=>en(3),
		x0=>x,
		y0=>y,
		x1=>w,
		y1=>h,
		color=>color,
		asb=>asb,
		done=>line_done,
		ramaddr=>ramaddr,
		ramdata=>ramdata,
		draw_write=>line_write,
		draw_can_access=>draw_can_access
	);
	--Module 4
	sprite1: draw_sprite port map (
		clk=>clk,
		reset=>reset,
		enable=>en(4),
		id=>id,
		x=>x,
		y=>y,
		w=>w,
		l=>h(SizeSpriteCounter-1 downto 0),
		color=>color,
		asb=>asb,
		done=>sprite_done,
		ramaddr=>ramaddr,
		ramdata=>ramdata,
		draw_write=>sprite_write,
		draw_read=>sprite_read,
		draw_can_access=>draw_can_access
	);
end structural;