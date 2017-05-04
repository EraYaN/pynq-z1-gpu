library ieee;
use ieee.std_logic_1164.all;
use work.parameter_def.all;

entity gpu is
	port(
		XI : in std_logic;
		XO : inout std_logic;
		reset : in std_logic;
		spi_clk : in std_logic;
		spi_mosi : in std_logic;
		int_ready : buffer std_logic;
		ramdata : inout std_logic_vector(SizeRAMData-1 downto 0);
		ramaddr : out std_logic_vector(SizeRAMAddr-1 downto 0);
		ramwe_n : out std_logic;
		vgahsync : out std_logic;
		vgavsync : out std_logic;
		vga_enabled : out std_logic
	);
end gpu;

architecture structural of gpu is
	component decoder is
		port (
		--Clock/reset
		clk		: in	std_logic;	--Clock
		reset	: in	std_logic;	--Reset
		--SPI-interface interaction
		spi_data_rx			: in	std_logic_vector(SizeSPIData-1 downto 0);	--Data In
		spi_data_available	: in	std_logic;									--Data Available in SPI interface, commence data sampling
		--Draw data
		draw_ready	: in	std_logic;
		x			: buffer	std_logic_vector(SizeX-1 downto 0);				--Entity x coord
		w			: buffer	std_logic_vector(SizeX-1 downto 0);				--Entity width
		y			: buffer	std_logic_vector(SizeY-1 downto 0);				--Entity y coord
		h			: buffer	std_logic_vector(SizeY-1 downto 0);				--Entity height
		color		: buffer	std_logic_vector(SizeColor-1 downto 0);			--Entity Color
		id			: buffer	std_logic_vector(SizeSpriteID-1 downto 0);		--Sprite ID
		en			: buffer	std_logic_vector(NumDrawModules-1 downto 0);	--Draw Module Enabled
		--Internal registers
		asb			: buffer	std_logic;	--Currently active screen buffer
		--Direct CPU interaction
		int_ready	: buffer	std_logic;	--Instruction processed signal
		spi_reset : out std_logic;
		--RAM Controller interaction
		decoder_can_access	: in std_logic;		--Can access RAM?
		decoder_write		: buffer std_logic;	--Intention to write to RAM
		decoder_claim		: out std_logic;	
		is_init				: buffer std_logic;		--Initializing?
		--RAM interaction
		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
		--VGA signals
		vgavsync : in std_logic
		);
	end component;

	component vgacontroller is
		PORT(
			clk :  IN   STD_LOGIC;  --pixel clock at frequency of VGA mode being used
			reset_n  :  IN   STD_LOGIC;  --active low asycnchronous reset
			vgahsync    :  OUT  STD_LOGIC;  --horiztonal sync pulse
			vgavsync    :  OUT  STD_LOGIC;  --vertical sync pulse
			vga_claim  :  OUT  STD_LOGIC;  --display enable ('1' = display time, '0' = blanking time)	 
			ramaddr  :  OUT  STD_LOGIC_VECTOR(SizeRAMAddr-1 downto 0);

			vga_read : OUT STD_LOGIC;
			vga_can_access : in std_logic;
			asb : IN STD_LOGIC
		); 	 
	end component;

	component spi is
		port (
			reset : in std_logic;
			spi_reset : in std_logic;
			clk : in std_logic;
			spi_clk : in std_logic;
			spi_mosi : in std_logic;
			spi_data_available : out std_logic;
			spi_data_rx : out std_logic_vector(SizeSPIData-1 downto 0)
		);
	end component;

	component ramcontroller is
		port (
			clk : in std_logic;
			--external
			write_enable : out std_logic;
			--internal
			vga_claim : in std_logic;
			decoder_claim : in std_logic;
			is_init : in std_logic;

			decoder_write : in std_logic;
			draw_write : in std_logic;
			draw_read : in std_logic;
			vga_read : in std_logic;

			draw_can_access : out std_logic;
			decoder_can_access : out std_logic;
			vga_can_access : out std_logic
		);
	end component;
	
	component draw is
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
	end component;

--	component draw_pixel
--	port(
--		clk   : in    std_logic;
--		reset : in    std_logic;
--		enable: in    std_logic;
--		x  : in    std_logic_vector(SizeX-1 downto 0);
--		y  : in    std_logic_vector(SizeY-1 downto 0);
--		color : in std_logic_vector(SizeColor-1 downto 0);
--		asb : in std_logic;
--		done  : out   std_logic;
--		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
--		ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
--		draw_write :out std_logic;
--		draw_can_access : in std_logic
--	);
--	end component;

--	component draw_rect
--	port(
--		clk   : in    std_logic;
--		reset : in    std_logic;
--		enable: in    std_logic;
--		enablef: in    std_logic;
--		x0  : in    std_logic_vector(SizeX-1 downto 0);
--		y0  : in    std_logic_vector(SizeY-1 downto 0);
--		x1 : in    std_logic_vector(SizeX-1 downto 0);
--		y1  : in    std_logic_vector(SizeY-1 downto 0);
--		color : in std_logic_vector(SizeColor-1 downto 0);
--		asb : in std_logic;
--		done  : out   std_logic;
--		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
--		ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
--		draw_write :out std_logic;
--		draw_can_access : in std_logic
--	);
--	end component;
	
--	component draw_line
--	port(
--		clk   : in    std_logic;
--		reset : in    std_logic;
--		enable: in    std_logic;
--		x0  : in    std_logic_vector(SizeX-1 downto 0);
--		y0  : in    std_logic_vector(SizeY-1 downto 0);
--		x1  : in    std_logic_vector(SizeX-1 downto 0);
--		y1  : in    std_logic_vector(SizeY-1 downto 0);
--		color : in std_logic_vector(SizeColor-1 downto 0);
--		asb : in std_logic;
--		done  : out   std_logic;
--		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
--		ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
--		draw_write :out std_logic;
--		draw_can_access : in std_logic
--	);
--	end component;
	
--	component draw_sprite is	
--	port(
--		clk   : in    std_logic;
--		reset : in    std_logic;
--		enable: in    std_logic;
--		id : in std_logic_vector(SizeSpriteID-1 downto 0);
--		x  : in    std_logic_vector(SizeX-1 downto 0);
--		y  : in    std_logic_vector(SizeY-1 downto 0);
--		w : in    std_logic_vector(SizeX-1 downto 0);
--		l  : in    std_logic_vector(SizeSpriteCounter-1 downto 0);
--		color : in std_logic_vector(SizeColor-1 downto 0);
--		asb : in std_logic;
--		done  : out   std_logic;
--		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
--		ramdata     :inout   std_logic_vector(SizeRAMData-1 downto 0);
--		draw_write :out std_logic;
--		draw_read :out std_logic;
--		draw_can_access : in std_logic
--	);
--	end component;

		--GLOBAL
	signal clk : std_logic;
	signal asb : std_logic;
	signal reset_n, sreset, ramwe: std_logic;
	signal vgavsync_int : std_logic;

	-- VGACONTROLLER <-> DRAW
	signal is_init : std_logic;

	-- DECODER <-> DRAW
	signal draw_ready : std_logic;
	signal x, w : std_logic_vector(SizeX-1 downto 0);
	signal y, h : std_logic_vector(SizeY-1 downto 0);
	signal color : std_logic_vector(SizeColor-1 downto 0);
	signal en : std_logic_vector(NumDrawModules-1 downto 0);
	signal id : std_logic_vector(SizeSpriteID-1 downto 0);
	signal spi_reset : std_logic;

	-- RAMCONTROLLER <->
	signal vga_claim : std_logic;
	signal decoder_claim : std_logic;
	signal draw_write : std_logic;
	signal draw_read : std_logic;
	signal decoder_write : std_logic;
	signal vga_read : std_logic;
	signal draw_can_access : std_logic;
	signal decoder_can_access : std_logic;
	signal vga_can_access : std_logic;
	signal write_enable,write_enable_n : std_logic;

	-- SPI <-> DECODER
	signal spi_data_available : std_logic;
	signal spi_data_rx : std_logic_vector(sizespidata-1 downto 0);

	-- DRAW
	signal pixel_done,fill_done,rect_done,line_done,sprite_done : std_logic;
	signal pixel_write,fill_write,rect_write,line_write,sprite_write : std_logic;
	signal sprite_read : std_logic;

begin
	reset_n <= not reset;
	ramwe_n <= not ramwe;
	vga_enabled<=vga_claim;
	draw_ready <= pixel_done or rect_done or line_done or sprite_done;
	draw_write <= pixel_write or rect_write or line_write or sprite_write;
	draw_read <= sprite_read;

	draw1: draw port map (
		clk=>clk,
		reset=>reset,
		id=>id,
		x=>x,
		w=>w,
		y=>y,
		h=>h,
		color=>color,
		en=>en,
		draw_ready=>draw_ready,
		asb=>asb,
		draw_write=>draw_write,
		draw_read=>draw_read,
		draw_can_access=>draw_can_access,
		ramaddr=>ramaddr,
		ramdata=>ramdata
	);
	
	--Module 0
--	pixel1: draw_pixel port map (
--		clk=>clk,
--		reset=>reset,
--		enable=>en(0),
--		x=>x,
--		y=>y,
--		color=>color,
--		asb=>asb,
--		done=>pixel_done,
--		ramaddr=>ramaddr,
--		ramdata=>ramdata,
--		draw_write=>pixel_write,
--		draw_can_access=>draw_can_access
--	);
--	--Module 1 and 2 (filled)
--	rect1: draw_rect port map (
--		clk=>clk,
--		reset=>reset,
--		enable=>en(1),
--		enablef=>en(2),
--		x0=>x,
--		y0=>y,
--		x1=>w,
--		y1=>h,
--		color=>color,
--		asb=>asb,
--		done=>rect_done,
--		ramaddr=>ramaddr,
--		ramdata=>ramdata,
--		draw_write=>rect_write,
--		draw_can_access=>draw_can_access
--	);
--	--Module 3
--	line1: draw_line port map (
--		clk=>clk,
--		reset=>reset,
--		enable=>en(3),
--		x0=>x,
--		y0=>y,
--		x1=>w,
--		y1=>h,
--		color=>color,
--		asb=>asb,
--		done=>line_done,
--		ramaddr=>ramaddr,
--		ramdata=>ramdata,
--		draw_write=>line_write,
--		draw_can_access=>draw_can_access
--	);
--	--Module 4
--	sprite1: draw_sprite port map (
--		clk=>clk,
--		reset=>reset,
--		enable=>en(4),
--		id=>id,
--		x=>x,
--		y=>y,
--		w=>w,
--		l=>h(SizeSpriteCounter-1 downto 0),
--		color=>color,
--		asb=>asb,
--		done=>sprite_done,
--		ramaddr=>ramaddr,
--		ramdata=>ramdata,
--		draw_write=>sprite_write,
--		draw_read=>sprite_read,
--		draw_can_access=>draw_can_access
--	);

	decoder1: decoder port map (
		clk=>clk,
		reset=>reset,
		spi_reset=>spi_reset,
		int_ready=>int_ready,
		spi_data_rx=>spi_data_rx,
		spi_data_available=>spi_data_available,
		draw_ready=>draw_ready,
		id=>id,
		x=>x,
		w=>w,
		y=>y,
		h=>h,
		color=>color,
		en=>en,
		asb=>asb,
		decoder_can_access=>decoder_can_access,
		decoder_write=>decoder_write,
		decoder_claim=>decoder_claim,
		is_init=>is_init,		--Initializing?
		ramdata=>ramdata,
		ramaddr=>ramaddr,
		vgavsync=>vgavsync_int
	);

	ramcontroller1: ramcontroller port map (
		clk=>clk,
		ramwe=>ramwe,
		vga_claim=>vga_claim,
		decoder_claim=>decoder_claim,
		is_init=>is_init,
		decoder_write=>decoder_wri,
		draw_write=>draw_write,
		draw_read=>draw_read,
		vga_read=>vga_read,
		draw_can_access=>draw_can_access,
		decoder_can_access=>decoder_can_access,
		vga_can_access=>vga_can_access
	);

	vgacontroller1: vgacontroller port map (
		clk=>clk,
		reset_n=>reset_n,
		vgahsync=>vgahsync,
		vgavsync_int=>vgavsync_int,
		vga_claim=>vga_claim,
		ramaddr=>ramaddr,
		vga_read=>vga_read,
		vga_can_access=>vga_can_access,
		asb=>asb
	);

	spi1: spi port map (
		clk=>clk,
		reset=>reset,
		spi_reset=>spi_reset,
		spi_clk=>spi_clk,
		spi_mosi=>spi_mosi,
		spi_data_available=>spi_data_available,
		spi_data_rx=>spi_data_rx	
	);
		
vgavsync<=vgavsync_int;
end structural;
















