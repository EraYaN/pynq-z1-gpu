LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.parameter_def.ALL;

entity gpu_tb is
generic (
	CLOCKPERIOD : time := 160 ns;
	SPICLOCKPERIOD : time := 500 ns;
	HCLOCKPERIOD : time := 80 ns;
	HSPICLOCKPERIOD : time := 250 ns
);
end gpu_tb;

architecture behaviour of gpu_tb is
component gpu is
	port(
		XI : in std_logic;
		XO : inout std_logic;
		reset : in std_logic;
		spi_clk : in std_logic;
		spi_mosi : in std_logic;
		int_ready : out std_logic;
		ramdata : inout std_logic_vector(SizeRAMData-1 downto 0);
		ramaddr : out std_logic_vector(SizeRAMAddr-1 downto 0);
		ramwe_n : out std_logic;
		vgahsync : out std_logic;
		vgavsync : out std_logic
	);
end component;

component sram IS
	port (      
		nCE: IN std_logic;  -- low-active Chip-Enable of the SRAM device; defaults to '1' (inactive)
		nOE: IN std_logic;  -- low-active Output-Enable of the SRAM device; defaults to '1' (inactive)
		nWE: IN std_logic;  -- low-active Write-Enable of the SRAM device; defaults to '1' (inactive)
		A:   IN std_logic_vector(SizeRAMAddr-1 downto 0); -- address bus of the SRAM device
		D:   INOUT std_logic_vector(SizeRAMData-1 downto 0);  -- bidirectional data bus to/from the SRAM device
		CE2: IN std_logic;  -- high-active Chip-Enable of the SRAM device; defaults to '1'  (active) 
		download: IN boolean;
		dump: IN boolean;
		dump_start: IN natural; 
		dump_end: IN natural
	);
end component;

signal reset : std_logic;
signal XO,XI : std_logic;
signal clk,spiclk,spiclk_en,write_enable_n,write_enable :std_logic;
signal spi_clk :  std_logic;
signal spi_mosi : std_logic;
signal ramaddr : std_logic_vector(SizeRAMAddr-1 downto 0);
signal ramdata : std_logic_vector(SizeRAMData-1 downto 0);
signal download, dump :boolean := FALSE;
signal int_ready:std_logic;
signal spibyte : integer :=0;

procedure sendByte( byte : in std_logic_vector(SizeSPIData-1 downto 0);
	signal mosi : out std_logic;
	signal spiclk_en : out std_logic;
	signal spibyte : inout integer) is
	variable first : boolean := TRUE;
	begin	
		wait until rising_edge(spiclk);
		spibyte<=spibyte+1;		
		for J in byte'range loop	
			wait until falling_edge(spiclk);
			
			mosi <= byte(J);
			if first then
				wait until rising_edge(spiclk);
				spiclk_en <= '1';
				first := false;
			end if;
			
		end loop; -- works for any size byte
		wait until falling_edge(spiclk);
		spiclk_en <= '0';
		mosi <= '1';
		wait for 600 ns;
end sendByte;

begin
write_enable<= NOT write_enable_n;
gpu1: gpu port map (
	XI=>XI,
	XO=>XO,
	reset=>reset,
	spi_clk=>spi_clk,
	spi_mosi=>spi_mosi,
	int_ready=>int_ready,
	ramaddr=>ramaddr,
	ramdata=>ramdata,
	ramwe_n=>write_enable_n
);
	
sr: sram port map (
	nCE=>reset,
	nOE=>write_enable,
	nWE=>write_enable_n,
	A=>ramaddr,
	D=>ramdata,
	CE2=>'1',
	download => download,
	dump=>dump,
	dump_start=>0,
	dump_end=>2 ** SizeRAMAddr -1
);
	-- clock period: 1/6250000 = 160 ns
	clk		<= '1' after 0 ns,
			'0' after HCLOCKPERIOD when clk /= '0' else '1' after HCLOCKPERIOD;
	spiclk		<= '1' after 0 ns,
			'0' after HSPICLOCKPERIOD when spiclk /= '0' else '1' after HSPICLOCKPERIOD;
	
	spi_clk <= spiclk and spiclk_en;
		XO<='Z';
		XI<=clk;
	process
	begin
		--setup
		reset <= '1';
		spi_mosi <= '1';
		spiclk_en <= '0';
		download <= FALSE;
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		reset <= '0';
		wait until rising_edge(clk);
		wait until rising_edge(clk);		
		sendByte("00000111",spi_mosi,spiclk_en, spibyte); -- sprite --byte 1
		sendByte("00100000",spi_mosi,spiclk_en, spibyte); -- sprite len (8) and 2MSB addr --byte 2
		sendByte("00000011",spi_mosi,spiclk_en, spibyte); -- sprite 8LSB addr = 3 --byte 3
		sendByte(not"00111111",spi_mosi,spiclk_en, spibyte); -- sprite data --byte 4
		sendByte(not"00100001",spi_mosi,spiclk_en, spibyte); -- sprite data --byte 5
		sendByte(not"00111101",spi_mosi,spiclk_en, spibyte); -- sprite data --byte 6
		sendByte(not"00111101",spi_mosi,spiclk_en, spibyte); -- sprite data --byte 7
		sendByte(not"00110001",spi_mosi,spiclk_en, spibyte); -- sprite data --byte 8
		sendByte(not"00111101",spi_mosi,spiclk_en, spibyte); -- sprite data --byte 9
		sendByte(not"00111101",spi_mosi,spiclk_en, spibyte); -- sprite data --byte 10
		sendByte(not"00100001",spi_mosi,spiclk_en, spibyte); -- sprite data --byte 11
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until int_ready = '1' and rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		sendByte("00000001",spi_mosi,spiclk_en, spibyte); -- fill --byte 12
		sendByte("00111111",spi_mosi,spiclk_en, spibyte); -- white  --byte 13
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until int_ready = '1' and rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		sendByte("00000100",spi_mosi,spiclk_en, spibyte); -- frect --byte 14
		sendByte("00101010",spi_mosi,spiclk_en, spibyte); -- grey  --byte 15
		sendByte("00101000",spi_mosi,spiclk_en, spibyte); -- X0 = 40 --byte 16
		sendByte("00110010",spi_mosi,spiclk_en, spibyte); -- Y0 = 50 --byte 17
		sendByte("01111000",spi_mosi,spiclk_en, spibyte); -- X1 = 120 --byte 18
		sendByte("01010000",spi_mosi,spiclk_en, spibyte); -- Y1 = 80 --byte 19
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until int_ready = '1' and rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);	
		sendByte("00000011",spi_mosi,spiclk_en, spibyte); -- rect --byte 20
		sendByte("00000000",spi_mosi,spiclk_en, spibyte); -- black  --byte 21
		sendByte("00101000",spi_mosi,spiclk_en, spibyte); -- X0 = 40 --byte 22
		sendByte("00110010",spi_mosi,spiclk_en, spibyte); -- Y0 = 50 --byte 23
		sendByte("01111000",spi_mosi,spiclk_en, spibyte); -- X1 = 120 --byte 24
		sendByte("01010000",spi_mosi,spiclk_en, spibyte); -- Y1 = 80 --byte 25
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until int_ready = '1' and rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);		
		sendByte("00000000",spi_mosi,spiclk_en, spibyte); -- switch screenbuffers --byte 26
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until int_ready = '1' and rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);		
		sendByte("00000001",spi_mosi,spiclk_en, spibyte); -- fill with 0000 (black)	--byte 27		
		sendByte("00000000",spi_mosi,spiclk_en, spibyte); -- black  --byte 28
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until int_ready = '1' and rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);		
		sendByte("00000010",spi_mosi,spiclk_en, spibyte); -- line --byte 29
		sendByte("00111111",spi_mosi,spiclk_en, spibyte); -- white --byte 30
		sendByte("00101000",spi_mosi,spiclk_en, spibyte); -- X0 = 40 --byte 31
		sendByte("00110010",spi_mosi,spiclk_en, spibyte); -- Y0 = 50 --byte 32
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until int_ready = '1' and rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);		
		sendByte("00000110",spi_mosi,spiclk_en, spibyte); -- sprite --byte 33
		sendByte("00010101",spi_mosi,spiclk_en, spibyte); -- greyish --byte 34
		sendByte("00001000",spi_mosi,spiclk_en, spibyte); -- X = 16 --byte 35
		sendByte("00001000",spi_mosi,spiclk_en, spibyte); -- Y = 16 --byte 36
		sendByte("00000110",spi_mosi,spiclk_en, spibyte); -- W = 6 --byte 37
		sendByte("00100000",spi_mosi,spiclk_en, spibyte); -- sprite len (8) and 2MSB addr --byte 38
		sendByte("00000011",spi_mosi,spiclk_en, spibyte); -- sprite 8LSB addr --byte 39
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		wait until int_ready = '1' and rising_edge(clk);
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		--finish
		dump <= TRUE;
		wait until rising_edge(clk);
		dump <= FALSE;
		wait until rising_edge(clk);
		wait;
	end process;	
	
end behaviour;

























