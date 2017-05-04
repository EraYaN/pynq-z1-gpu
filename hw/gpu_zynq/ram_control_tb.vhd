library IEEE;
use IEEE.std_logic_1164.ALL;

entity ram_control_tb is
end ram_control_tb;

architecture behaviour of ram_control_tb is
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

--input
signal clk, write_enable, vga_claim, decoder_claim, is_init: std_logic;
signal decoder_write, draw_write, draw_read, vga_read: std_logic;
--output
signal draw_can_access, decoder_can_access, vga_can_access: std_logic;


begin
clk <=			'1' after 0 ns,
			'0' after 10 ns when clk /= '0' else '1' after 10 ns;
write_enable <=			'0' after 0 ns,
			'1' after 320 ns;
vga_claim <=			'0' after 0 ns,
			'1' after 20 ns,
			'0' after 60 ns;
			
decoder_claim <=			'0' after 0 ns,
			'1' after 40 ns;
is_init <=              '0' after 0 ns,
			'1' after 320 ns; 
			

decoder_write <=			'0' after 0 ns,
			'1' after 160 ns;
			
draw_write <=           '0' after 0 ns,
			'1' after 80 ns,
			'0' after 160 ns,
			'1' after 240 ns;
			
draw_read <=			'0' after 0 ns,
			'1' after 40 ns,
			'0' after 80 ns,
			'1' after 120 ns,
			'0' after 160 ns,
			'1' after 200 ns,
			'0' after 240 ns,
			'1' after 280 ns;
			
vga_read <=			'0' after 0 ns,
			'1' after 20 ns,
			'0' after 40 ns,
			'1' after 60 ns,
			'0' after 80 ns,
			'1' after 100 ns,
			'0' after 120 ns,
			'1' after 140 ns,
			'0' after 160 ns,
			'1' after 180 ns,
			'0' after 200 ns,
			'1' after 220 ns,
			'0' after 240 ns,
			'1' after 260 ns,
			'0' after 280 ns,
			'1' after 300 ns;


lbl1: ramcontroller port map(
	clk		=> clk,
	write_enable		=> write_enable,
	vga_claim 		=> vga_claim,
	decoder_claim		=> decoder_claim,
	draw_write		=> draw_write,
	is_init		=> is_init,
	decoder_write		=> decoder_write,
	draw_read		=> draw_read,
	vga_read		=> vga_read,
	draw_can_access	=> draw_can_access,
	decoder_can_access	=> decoder_can_access,
	vga_can_access 	=> vga_can_access
	);
	

end behaviour;
