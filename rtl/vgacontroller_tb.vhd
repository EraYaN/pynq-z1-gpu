LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.parameter_def.all;

entity vgacontroller_tb is
generic (
	CLOCKPERIOD : time := 160 ns;
	SPICLOCKPERIOD : time := 500 ns;
	HCLOCKPERIOD : time := 80 ns;
	HSPICLOCKPERIOD : time := 250 ns
);
end vgacontroller_tb;

architecture behaviour of vgacontroller_tb is
component vgacontroller
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

signal reset_n : std_logic;
signal clk,asb,vga_can_access :std_logic;
begin
clk		<= '1' after 0 ns,
			'0' after HCLOCKPERIOD when clk /= '0' else '1' after HCLOCKPERIOD;
vga: vgacontroller port map (
	clk=>clk,
	reset_n=>reset_n,	
	vga_can_access=>vga_can_access,
	asb=>asb
);
			
	process
	begin
		--setup
		reset_n <= '0';		
		asb<='1';
		vga_can_access <= '1';
		wait until rising_edge(clk);
		wait until rising_edge(clk);
		reset_n <= '1';		
		wait;
	end process;	
end behaviour;