LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.parameter_def.ALL;

use IEEE.math_real.ceil;
use IEEE.math_real.log2;

entity spi is
	generic (
	 	c : integer := integer(ceil(log2(real(SizeSPIData))))
	);
	port (
		reset : in std_logic;
		spi_reset : in std_logic;
		clk : in std_logic;
		spi_clk : in std_logic;
		spi_mosi : in std_logic;
		spi_data_available : out std_logic;
		spi_data_rx : out std_logic_vector(SizeSPIData-1 downto 0)
	);
end spi;

architecture behaviour of spi is

		signal sclk_latched, sclk_old : std_logic;
		signal mosi_latched: std_logic;
		signal index: unsigned (c-1 downto 0);
		signal spi_rx_data : std_logic_vector(SizeSPIData-1 downto 0);
		signal timer : unsigned (5 downto 0);

begin

--Sync process
process(clk,spi_reset)

begin
	if spi_reset = '1' then
		index <= to_unsigned(0,c);
	elsif rising_edge(clk) then
		if (reset = '1') then
			spi_rx_data <= (others => '0');
			index <= to_unsigned(0,c);
			sclk_old <= '0';
			sclk_latched <= '0';
			spi_data_available <= '0';
			mosi_latched <= '0';
			timer <= to_unsigned(0,6);
		else
			sclk_latched <= spi_clk;
			sclk_old <= sclk_latched;
			spi_data_available <= '0';
			mosi_latched <= spi_mosi;

			if sclk_old = '0' and sclk_latched = '1' then
				spi_rx_data <= spi_rx_data(SizeSPIData-2 downto 0) & mosi_latched;
				if index = (SizeSPIData-1) then
					index <= to_unsigned(0,c);
				else
					index <= index+1;
				end if;
			elsif sclk_old = '1' and sclk_latched = '0' then
				if index = 0 then
					spi_data_available <= '1';
				end if;
			end if;

			if spi_clk = '0' then
				timer <= timer+1;
			else
				timer <= to_unsigned(0,6);
			end if;
			
			if timer > 60 then
				index <= to_unsigned(0,c);
			end if;
		end if;
	end if;
end process;

--Combinational assignments
spi_data_rx <= spi_rx_data;

end behaviour;
