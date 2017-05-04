LIBRARY ieee;
USE ieee.std_logic_1164.all;
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