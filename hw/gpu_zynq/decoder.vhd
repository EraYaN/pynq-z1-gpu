library IEEE;
use IEEE.std_logic_1164.all;
use work.parameter_def.all;

entity decoder is
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
end entity decoder;