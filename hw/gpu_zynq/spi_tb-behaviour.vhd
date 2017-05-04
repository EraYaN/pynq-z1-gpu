library IEEE;
use IEEE.std_logic_1164.ALL;
USE work.parameter_def.ALL;

architecture behaviour of spi_tb is
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
signal reset, spi_reset : std_logic;
signal clk,spiclk,spiclk_en :std_logic;
signal spi_clk :  std_logic;
signal spi_mosi : std_logic;
--signal SPI_MISO : std_logic;
signal spi_data_available : std_logic;
--signal DataToTx : std_logic_vector(SizeSPIData-1 downto 0);
--signal DataToTxLoad: std_logic;
signal spi_data_rx : std_logic_vector(SizeSPIData-1 downto 0);
procedure sendByte( byte : in std_logic_vector(SizeSPIData-1 downto 0);
	signal mosi : out std_logic;
	signal spiclk_en : out std_logic) is
	variable first : boolean := TRUE;
	begin	
		wait until rising_edge(spiclk);
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
	spi1: spi port map (
	reset,
	spi_reset,
	clk,
	spi_clk,
	spi_mosi,
	spi_data_available,
	spi_data_rx);
	
	-- clock period: 1/6250000 = 160 ns
	clk		<= '1' after 0 ns,
			'0' after HCLOCKPERIOD when clk /= '0' else '1' after HCLOCKPERIOD;
	spiclk		<= '1' after 0 ns,
			'0' after HSPICLOCKPERIOD when spiclk /= '0' else '1' after HSPICLOCKPERIOD;
	
	spi_clk <= spiclk and spiclk_en;
	spi_reset <= '0' after 0 ns;
		
	process
	begin
		--setup
		reset <= '1';
		spi_mosi <= '0';
		spiclk_en <= '0';
		--DataToTX <= (others=>'0');
		--DataToTxLoad <= '0';
		wait until rising_edge(clk);
		reset <= '0';
		loop 
		wait until rising_edge(clk);
		sendByte("01001011",spi_mosi,spiclk_en);
		wait until rising_edge(clk);		
		sendByte(x"DF",spi_mosi,spiclk_en);
		end loop;
	end process;	
	
end behaviour;












