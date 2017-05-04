LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.parameter_def.ALL;
architecture behaviour of ramcontroller is
begin
	ramcontroller_combi: process (clk, vga_claim,decoder_claim,is_init,decoder_write,draw_write,draw_read,vga_read)
	begin
	if(is_init='0') then
		draw_can_access <= NOT vga_claim AND NOT decoder_claim;	
		vga_can_access <= '1';
		decoder_can_access <= NOT vga_claim;
		write_enable <= transport ((decoder_write OR draw_write) AND NOT vga_read AND NOT draw_read AND clk) after 2 ns;		
	else
		write_enable <= transport (decoder_write AND clk) after 2 ns;
		decoder_can_access <= '1';
		draw_can_access <= '0';
		vga_can_access <= '0';
	end if;
	end process;
end behaviour;


