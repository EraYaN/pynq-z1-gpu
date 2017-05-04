library IEEE;
use IEEE.std_logic_1164.ALL;
use work.parameter_def.ALL;

architecture behaviour of draw_pixel is
signal busy : std_logic; -- used as a "state"
signal ramaddr_tmp: std_logic_vector(SizeRAMAddr-1 downto 0);
signal ramdata_tmp: std_logic_vector(SizeRAMData-1 downto 0);
signal busy_tmp : std_logic;
signal oe : std_logic;
begin
draw_pixel_seq:	process (clk)
	begin
		if rising_edge(clk) then			
			busy <= busy_tmp;
		end if;
	end process;

	ramaddr <= ramaddr_tmp WHEN oe = '1' ELSE (others => 'Z');
	ramdata <= color WHEN oe = '1' ELSE (others => 'Z');
	ramaddr_tmp <= std_logic_vector((NOT asb) & y & x);	

draw_pixel_combi:	process(reset, enable, draw_can_access, busy)
	begin
		if reset = '0' and enable = '1' and draw_can_access = '1' then -- RAM is free to access			
			if busy = '0' then --we are not busy							
				oe <= '1';
				draw_write<= '1'; -- vertel de controller dat je wil schrijven
				done <= '0'; -- not done yet
				busy_tmp <= '1'; -- we are now busy
			else --we are busy		
				oe <= '0';				
				done <= '1'; -- we are done now
				busy_tmp <= '0'; -- we are not busy anymore
				draw_write <= '0';
			end if;
		else
			done <= '0';
			draw_write <= '0';
			busy_tmp <= '0';
			oe <= '0';	
		end if;
	end process;
end behaviour;

