library IEEE;
use IEEE.std_logic_1164.ALL;
use IEEE.numeric_std.All;
use work.parameter_def.ALL;

architecture behaviour of draw_rect is
signal cx : unsigned(SizeX-1 downto 0);
signal cy : unsigned(SizeY-1 downto 0);
signal ramaddr_tmp: std_logic_vector(SizeRAMAddr-1 downto 0);
--signal ramdata_tmp: std_logic_vector(SizeRAMData-1 downto 0);
signal cx_tmp: unsigned(SizeX-1 downto 0);
signal cy_tmp: unsigned(SizeY-1 downto 0);
--signal draw_write_tmp : std_logic;
signal almost_done,almost_done_tmp : std_logic;
signal started, started_tmp : std_logic;
signal oe : std_logic;
begin
draw_rect_seq: process (clk)	
	begin
		if rising_edge(clk) then
			--ramaddr<=ramaddr_tmp;
			--ramdata<=ramdata_tmp;
			cx<=cx_tmp;
			cy<=cy_tmp;
			--draw_write <= draw_write_tmp;
			almost_done<=almost_done_tmp;
			started <= started_tmp;
		end if;
	end process;
	ramaddr <= ramaddr_tmp WHEN oe = '1' ELSE (others => 'Z');
	ramdata <= color WHEN oe = '1' ELSE (others => 'Z');
	--ramaddr <= ramaddr_tmp WHEN oe = '1' ELSE (others => '0');
	--ramdata <= color WHEN oe = '1' ELSE (others => '0');
	ramaddr_tmp <= std_logic_vector((NOT asb) & cy & cx);	
draw_rect_combi: process (reset, enable, enablef, draw_can_access, x0, y0, x1, y1, almost_done, cx, cy, started)	
	begin
			if reset = '0' and (enable = '1' or enablef = '1') then 
				if draw_can_access = '1' then -- RAM is free to access
					if started = '1' then
						if almost_done = '1' then
							done <= '1';
							draw_write <= '0';
							cx_tmp <= (others => '0');
							cy_tmp <= (others => '0');
							--ramaddr_tmp <= (others => 'Z');
							--ramdata_tmp <= (others => 'Z');
							oe <= '0';
							almost_done_tmp <= '0';
							started_tmp <= '0';
						else 
							if cx <= unsigned(x0) and cy <= unsigned(y0) then		
								almost_done_tmp <= '1';
								else
								almost_done_tmp <= '0';
							end if;
							done <= '0';
							if cx = unsigned(x0) then
								cy_tmp <= cy-1;	
								cx_tmp <= unsigned(x1);
							else
								if enable /= '1' and enablef = '1' then
									--filled
									cx_tmp <= cx-1;
								else
									--not filled
									if cy = unsigned(y0) or cy = unsigned(y1) then
										cx_tmp <= cx-1;
									else
										cx_tmp <= unsigned(x0);
									end if;
								end if;
								cy_tmp <= cy;
							end if;
							--ramaddr_tmp <= std_logic_vector((NOT asb) & cy & cx); --combineer signalen
							--ramdata_tmp <= color; -- zet data op de bus
							oe <= '1';
							draw_write <= '1'; -- vertel de controller dat je wil schrijven						
						end if;
						started_tmp <= '1';
					else
						cx_tmp <= unsigned(x1);
						cy_tmp <= unsigned(y1);						
						oe <= '0';
						draw_write <= '0';
						done <= '0';
						almost_done_tmp <= '0';
						started_tmp <= '1';
					end if;
				else
					cx_tmp <= cx;
					cy_tmp <= cy;
					oe <= '0';
					draw_write <= '0';
					done <= '0';
					almost_done_tmp <= '0';
					started_tmp <= started;
				end if;
			else 
				cx_tmp <= (others => '0');--unsigned(x)+unsigned(w);
				cy_tmp <= (others => '0');--unsigned(y)+unsigned(h);
				oe <= '0';
				draw_write <= '0';
				done <= '0';
				almost_done_tmp <= '0';
				started_tmp <= '0';
			end if;
	end process;
end behaviour;









