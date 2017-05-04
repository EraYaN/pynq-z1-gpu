library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.parameter_def.all;

architecture behaviour of draw_line is

	signal setup, next_setup : std_logic;
	signal cx, next_cx : signed(SizeX-1 downto 0); --current x
	signal cy, next_cy : signed(SizeY-1 downto 0); --current y	
	signal err, next_err : signed(SizeX+1 downto 0);
	signal dx : signed(SizeX downto 0);
	signal dy : signed(SizeY downto 0);
	signal sx, sy : signed(1 downto 0);

	signal next_ramaddr : std_logic_vector(SizeRAMAddr-1 downto 0);

begin
	--combinatorial RAM interaction
	ramaddr <= next_ramaddr WHEN draw_write = '1' ELSE (others => 'Z');
	ramdata <= color WHEN draw_write = '1' ELSE (others => 'Z');
	next_ramaddr <= std_logic_vector((NOT asb) & cy & cx);

	--values that are constant throughout the draw process
	dx <= abs(signed(resize(unsigned(x1), dx'length) - resize(unsigned(x0), dx'length)));
	dy <= abs(signed(resize(unsigned(y1), dy'length) - resize(unsigned(y0), dy'length)));
	sx <= to_signed(1, sx'length) when x0 < x1 else
			to_signed(-1, sx'length);
	sy <= to_signed(1, sy'length) when y0 < y1 else
			to_signed(-1, sy'length);

	--sequential logic (statereg)
	draw_line_seq: process (clk)		
	begin
		if rising_edge(clk) then
			if reset = '1' then
				setup <= '0';
				cx <= (others => '0');
				cy <= (others => '0');
				err <= (others => '0');
			else
				setup <= next_setup;
				cx <= next_cx;
				cy <= next_cy;
				err <= next_err;
			end if;
		end if;
	end process;	

	--combinatorial logic (draw logic and arithmetic)
	draw_line_comb: process (enable, draw_can_access, x0, x1, y0, y1, cx, cy, sx, sy, dx, dy, err, setup)

	begin

		if enable = '1'then
			if draw_can_access = '1' then
				if setup = '1' then
					done <= '0';
					draw_write <= '0';
					next_cx <= signed(x0);
					next_cy <= signed(y0);					
					next_err <= resize(dx - dy, next_err'length);
					next_setup <= '0';
				else
					next_cx <= cx;
					next_cy <= cy;
					next_err <= err;

					--draw next pixel
					draw_write <= '1';

					--are we done?
					if cx = signed(x1) and cy = signed(y1) then
						done <= '1';
						next_setup <= '1';
					else
						done <= '0';
						next_setup <= '0';
						if (err & '0') > -dy and (err & '0') < dx then
							next_err <= err - dy + dx;
							next_cx <= cx + sx;
							next_cy <= cy + sy;
						else 
							if (err & '0') > -dy then
								next_err <= err - dy;
								next_cx <= cx + sx;
							elsif (err & '0') < dx then
								next_err <= err + dx;
								next_cy <= cy + sy;
							end if;
						end if;
					end if;						
				end if;
			else
				next_setup <= setup;
				next_cx <= cx;
				next_cy <= cy;
				next_err <= err;
				done <= '0';
				draw_write <= '0';
			end if;
		else
			next_setup <= '1';
			next_cx <= (others => '0');
			next_cy <= (others => '0');
			next_err <= (others => '0');
			done <= '0';
			draw_write <= '0';
		end if;
	end process;
end behaviour;