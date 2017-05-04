LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.parameter_def.ALL;

entity ramcontroller is
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
end ramcontroller;