library IEEE;
use IEEE.std_logic_1164.ALL;
use work.parameter_def.ALL;

architecture behaviour of decoder_tb is

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
			--RAM Controller interaction
			decoder_can_access	: in std_logic;		--Can access RAM?
			decoder_write		: out std_logic;	--Intention to write to RAM
			decoder_claim		: out std_logic;	
			is_init				: buffer std_logic;		--Initializing?
			--RAM interaction
			ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
			ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
			--VGA signals
			vgavsync : in std_logic
		);
	end component;

signal clk					: std_logic;
signal reset				: std_logic;
signal spi_data_rx			: std_logic_vector(SizeSPIData-1 downto 0);
signal spi_data_available	: std_logic;
signal draw_ready			: std_logic;
signal x					: std_logic_vector(SizeX-1 downto 0);
signal w					: std_logic_vector(SizeX-1 downto 0);
signal y					: std_logic_vector(SizeY-1 downto 0);
signal h					: std_logic_vector(SizeY-1 downto 0);
signal color				: std_logic_vector(SizeColor-1 downto 0);
signal id					: std_logic_vector(SizeSpriteID-1 downto 0);
signal en					: std_logic_vector(NumDrawModules-1 downto 0);
signal asb					: std_logic;
signal int_ready			: std_logic;
signal decoder_can_access	: std_logic;
signal decoder_write		: std_logic;
signal decoder_claim		: std_logic;	
signal is_init				: std_logic;
signal ramaddr				: std_logic_vector(SizeRAMAddr-1 downto 0);
signal ramdata				: std_logic_vector(SizeRAMData-1 downto 0);
signal vgavsync				: std_logic;

signal enable_spi			: std_logic;

begin

	decoder1: decoder 
		port map (
			clk=>clk,
			reset=>reset,
			spi_data_rx=>spi_data_rx, 
			spi_data_available=>spi_data_available, 
			draw_ready=>draw_ready,
			x=>x,
			w=>w,
			y=>y,
			h=>h,
			color=>color,
			id=>id,
			en=>en,
			asb=>asb,
			int_ready=>int_ready,
			decoder_can_access=>decoder_can_access,
			decoder_write=>decoder_write,
			decoder_claim=>decoder_claim,
			is_init=>is_init,
			ramaddr=>ramaddr,
			ramdata=>ramdata,
			vgavsync=>vgavsync
		);

	clk		<= '1' after 0 ns,
			'0' after 80 ns when clk /= '0' else '1' after 80 ns;
	reset	<= '1' after 0 ns,
			'0' after 320 ns;
	spi_data_available	<= '1' after 0 ns,
							'0' after 250 ns when (spi_data_available /= '0' ) else '1' after 500 ns when enable_spi = '1' else '0';
	decoder_can_access <= '1' after 0 ns;

	vgavsync <= '0';

	process
	begin
		enable_spi <= '0';
		spi_data_rx <= "00000000";
		draw_ready <= '0';
		
		wait until rising_edge(clk);
		wait until rising_edge(clk);

		enable_spi <= '1';
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00000111"; --load sprite
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00010001"; --data length of 4, address(16 downto 14) = 01
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "01010101"; --address(13 downto 6) = 01010101
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "10100101"; --data 0
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "11110000"; --data 1
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00001111"; --data 2
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00110000"; --data 3
		wait until falling_edge(spi_data_available);
		enable_spi <= '0';

		wait for 960 ns;

		-- enable_spi <= '1';
		-- wait until rising_edge(spi_data_available);
		-- spi_data_rx <= "00000001"; --perform fill
		-- wait until rising_edge(spi_data_available);
		-- spi_data_rx <= "00111111"; --color 111111
		-- wait until falling_edge(spi_data_available);
		-- enable_spi <= '0';

		-- wait for 960 ns;

		enable_spi <= '1';
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00000011"; --draw rect (011)
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00111111"; --color 111111
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "01010101"; --x
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "10101010"; --y
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "11111111"; --w
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "11001100"; --h
		wait until falling_edge(spi_data_available);
		enable_spi <= '0';

		wait for 960 ns;

		wait until rising_edge(clk);
		draw_ready <= '1';
		wait until rising_edge(clk);
		draw_ready <= '0';

		wait for 960 ns;

		enable_spi <= '1';
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00000000"; --switch screen buffer
		wait until falling_edge(spi_data_available);
		enable_spi <= '0';

		wait for 960 ns;

		enable_spi <= '1';
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00000101"; --draw line (101)
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00111111"; --color 111111
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "01010101"; --x0
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "10101010"; --y0
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "11111111"; --x1
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "11001100"; --y1
		wait until falling_edge(spi_data_available);
		enable_spi <= '0';
		
		wait for 960 ns;

		enable_spi <= '1';
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00000110"; --draw sprite (110)
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00111111"; --color 111111
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "01010101"; --x
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "10101010"; --y
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "11111111"; --w
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "11001100"; --data length + id
		wait until rising_edge(spi_data_available);
		spi_data_rx <= "00110011"; --id
		wait until falling_edge(spi_data_available);
		enable_spi <= '0';

		wait;

	end process;
end behaviour;