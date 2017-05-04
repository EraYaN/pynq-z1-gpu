library IEEE;
use IEEE.std_logic_1164.ALL;
use work.parameter_def.ALL;

entity draw_rect_tb is
end draw_rect_tb;

architecture behaviour of draw_rect_tb is
component draw_rect is
	port(
	          clk                  : in    std_logic;
		       reset                : in    std_logic;
		       enable               : in    std_logic;
		       enablef              : in    std_logic;
		       x0                    : in    std_logic_vector(SizeX-1 downto 0);
		       y0                    : in    std_logic_vector(SizeY-1 downto 0);
		       x1                    : in    std_logic_vector(SizeX-1 downto 0);
		       y1                    : in    std_logic_vector(SizeY-1 downto 0);
		       color                : in    std_logic_vector(SizeColor-1 downto 0);
		       asb                  : in    std_logic;
		       done                 : out   std_logic;
		       ramaddr              : out   std_logic_vector(SizeRAMAddr-1 downto 0);
		       ramdata              : out    std_logic_vector(SizeRAMData-1 downto 0);
		       draw_write           : out    std_logic;
		       draw_can_access      : in    std_logic
		  );
	end component;
	
	--input signalen
	signal clk, reset, enable, enablef, asb, draw_can_access: std_logic;
	signal x, w 		   : std_logic_vector(SizeX-1 downto 0);
	signal y, h      : std_logic_vector(SizeY-1 downto 0);
	signal color			       : std_logic_vector(SizeColor-1 downto 0);
	
	--output signalen
	signal done, draw_write : std_logic;
	signal ramaddr : std_logic_vector(SizeRAMAddr-1 downto 0);
	signal ramdata : std_logic_vector(SizeRAMData-1 downto 0);
	

begin
	
	clk <=            '1' after 0 ns,
	                  '0' after 10 ns when clk /= '0' else '1' after 10 ns;
	
	reset <=          '1' after 0 ns, 
	 		 '0' after 50 ns;
		              --enablef testen
	
	enable <=         '1' after 0 ns, '0' after 400 ns;
	
	enablef <=        '0' after 0 ns, '1' after 500 ns;
		
	draw_can_access <= '1' after 0 ns;
				            
	
	color <=          "101010" after 0 ns;
	
	asb <=            '0' after 0 ns;
	
	x <=             "00000000" after 0 ns;

	
	y	<=             "0000000" after 0 ns;
	
	w	<=             "00000100" after 0 ns; 
	
	h	<=             "0000100" after 0 ns;

				
lbl: draw_rect port map(	       
           clk              => clk,                
		       reset            => reset,             
		       enable           => enable,     
		       enablef          => enablef,     
		       x0                => x,     
		       y0                => y,    
		       x1                => w,     
		       y1                => h,     
		       color            => color,     
		       asb              => asb,     
		       done             => done,     
		       ramaddr          => ramaddr,     
		       ramdata          => ramdata,     
		       draw_write       => draw_write,     
		       draw_can_access  => draw_can_access
		       );     

end behaviour;