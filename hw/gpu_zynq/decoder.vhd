library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.parameter_def.all;

entity decoder is
	port (
		--Clock/reset
		clk		: in	std_logic;	--Clock
		reset	: in	std_logic;	--Reset
		--SPI-interface interaction
		spi_data_rx			: in	std_logic_vector(SizeSPIData-1 downto 0);	--Data In
		spi_data_available	: in	std_logic;									--Data Available in SPI interface, commence data sampling
		--Draw data
		draw_ready	: in	std_logic;
		x			: buffer	std_logic_vector(SizeX-1 downto 0);				--Entity x coord
		w			: buffer	std_logic_vector(SizeX-1 downto 0);				--Entity width
		y			: buffer	std_logic_vector(SizeY-1 downto 0);				--Entity y coord
		h			: buffer	std_logic_vector(SizeY-1 downto 0);				--Entity height
		color		: buffer	std_logic_vector(SizeColor-1 downto 0);			--Entity Color
		id			: buffer	std_logic_vector(SizeSpriteID-1 downto 0);		--Sprite ID
		en			: buffer	std_logic_vector(NumDrawModules-1 downto 0);	--Draw Module Enabled
		--Internal registers
		asb			: buffer	std_logic;	--Currently active screen buffer
		--Direct CPU interaction
		int_ready	: buffer	std_logic;	--Instruction processed signal
		spi_reset : out std_logic;
		--RAM Controller interaction
		decoder_can_access	: in std_logic;		--Can access RAM?
		decoder_write		: buffer std_logic;	--Intention to write to RAM
		decoder_claim		: out std_logic;	
		is_init				: buffer std_logic;		--Initializing?
		--RAM interaction
		ramaddr     :out   std_logic_vector(SizeRAMAddr-1 downto 0);
		ramdata     :out   std_logic_vector(SizeRAMData-1 downto 0);
		--VGA signals
		vgavsync : in std_logic
	);
end entity decoder;

architecture behaviour of decoder is
	type instruction is (i_none, i_switch, i_fill, i_pixel, i_rect, i_frect, i_line, i_sprite, i_lsprite);
	attribute enum_encoding : string;
	attribute enum_encoding of instruction : type is "0000 0001 0010 0011 0100 0101 0110 0111 1000";

	--state signals and regs
	signal packet_num, next_packet_num : unsigned(SizeNumPackets-1 downto 0); --current packet number
	signal current_instruction, next_instruction : instruction; --current instruction
	signal timeout_count, next_timeout_count : unsigned(SizeTimeoutCounter-1 downto 0);
	signal current_spi_data_available, prev_spi_data_available : std_logic;

	--output registers
	signal next_x, next_w : std_logic_vector(SizeX-1 downto 0);
	signal next_y, next_h : std_logic_vector(SizeY-1 downto 0);
	signal next_id : std_logic_vector(SizeSpriteID-1 downto 0);
	signal next_color : std_logic_vector(SizeColor-1 downto 0);
	signal next_en : std_logic_vector(NumDrawModules-1 downto 0);
	signal next_int_ready, next_is_init, next_asb : std_logic;
	signal next_ramdata : std_logic_vector(SizeRAMData-1 downto 0);

begin
	--"asynchronous" RAM interaction
	decoder_claim <= is_init;
	ramaddr <= id & h(SizeSpriteCounter-1 downto 0) when decoder_write = '1' else (others => 'Z');
	ramdata <= next_ramdata when decoder_write = '1' else (others => 'Z');

	--synchronizer + input buffer + output buffer + state change
	decode_seq: process (clk)	
	begin
		if rising_edge(clk) then
			if reset = '1' then
				--reset all registers
				packet_num <= (others => '0');
				timeout_count <= (others => '0');
				current_instruction <= i_none;
				current_spi_data_available <= '0';
				prev_spi_data_available <= '0';
				x <= (others => '0');
				y <= (others => '0');
				w <= (others => '0');
				h <= (others => '0');
				id <= (others => '0');
				color <= (others => '0');
				en <= (others => '0');
				asb <= '0';
				is_init <= '1';
				int_ready <= '0';
			else
				--update all registers
				packet_num <= next_packet_num;
				timeout_count <= next_timeout_count;
				current_instruction <= next_instruction;
				current_spi_data_available <= spi_data_available;
				prev_spi_data_available <= current_spi_data_available;
				x <= next_x;
				y <= next_y;
				w <= next_w;
				h <= next_h;
				id <= next_id;
				color <= next_color;
				en <= next_en;
				asb <= next_asb;
				is_init <= next_is_init;
				int_ready <= next_int_ready;
			end if;		
		end if;
	end process;

	decode_comb: process (x, y, w, h, id, color, en, asb, is_init, int_ready, draw_ready, current_spi_data_available, prev_spi_data_available, spi_data_rx, current_instruction, packet_num, decoder_can_access, timeout_count, vgavsync)
		variable done : std_logic;		
	begin
		--defaults for buffered signals
		next_x <= x;
		next_y <= y;
		next_w <= w;
		next_h <= h;
		next_id <= id;
		next_color <= color;
		next_en <= en;
		next_asb <= asb;
		next_is_init <= is_init;
		next_int_ready <= int_ready;
		next_instruction <= current_instruction;
		next_packet_num <= packet_num;
		next_timeout_count <= timeout_count;
		
		--defaults for non-buffered signals	
		next_ramdata <= (others => '0');
		spi_reset <= '0';
		decoder_write <= '0';

		--init variables
		done := '0';

		--action depending on state
		if (current_spi_data_available = '1' and prev_spi_data_available = '0') or current_instruction = i_switch then
			next_int_ready <= '0';
			next_timeout_count <= (others => '0');
			spi_reset <= '1';
			if current_instruction = i_none then
				if packet_num = 0 then
					--determine next instruction
					if spi_data_rx(SizeSPIData-1 downto InstrSize) = (SizeSPIData-InstrSize-1 downto 0 => '0') then
						if spi_data_rx(InstrSize-1 downto 0) = "000" then
							 next_instruction <= i_switch;
						elsif spi_data_rx(InstrSize-1 downto 0) = "001" then
							next_instruction <= i_fill;
						elsif spi_data_rx(InstrSize-1 downto 0) = "010" then 
							next_instruction <= i_pixel;
						elsif spi_data_rx(InstrSize-1 downto 0) = "011" then 
							next_instruction <= i_rect;
						elsif spi_data_rx(InstrSize-1 downto 0) = "100" then 
							next_instruction <= i_frect;
						elsif spi_data_rx(InstrSize-1 downto 0) = "101" then 
							next_instruction <= i_line;
						elsif spi_data_rx(InstrSize-1 downto 0) = "110" then 
							next_instruction <= i_sprite;
						elsif spi_data_rx(InstrSize-1 downto 0) = "111" then 
							next_instruction <= i_lsprite;
						else
							done := '1';
							next_int_ready <= '1';
						end if;
					else
						done := '1';
						next_int_ready <= '1';
					end if;
					
				else
					done := '1';
					next_int_ready <= '1';
				end if;

				if spi_data_rx(InstrSize-1 downto 0) /= "111" then
					next_is_init <= '0';
				end if;

			elsif current_instruction = i_switch then
				if vgavsync = '0' then
					next_asb <= not asb;
					done := '1';
					next_int_ready <= '1';
				end if;
			elsif current_instruction = i_fill then
				if packet_num = 1 then
					done := '1';
					next_color <= spi_data_rx(SizeRAMData-1 downto 0);
					next_x <= (others => '0');
					next_y <= (others => '0');
					next_w <= std_logic_vector(to_unsigned(ResolutionX-1,SizeX));
					next_h <= std_logic_vector(to_unsigned(ResolutionY-1,SizeY));
					next_en(2) <= '1';
				else
					--shit broke
					done := '1';
					next_int_ready <= '1';
				end if;
			elsif current_instruction = i_pixel then
				if packet_num = 1 then
					next_color <= spi_data_rx(SizeColor-1 downto 0);
				elsif packet_num = 2 then
					next_x <= spi_data_rx(SizeX-1 downto 0);
				elsif packet_num = 3 then
					next_y <= spi_data_rx(SizeY-1 downto 0);
					--done
					done := '1';
					next_en(0) <= '1';
				else
					--shit broke
					done := '1';
					next_int_ready <= '1';
				end if;

			elsif current_instruction = i_rect or current_instruction = i_frect or current_instruction = i_line then
				if packet_num = 1 then
					next_color <= spi_data_rx(SizeColor-1 downto 0);
				elsif packet_num = 2 then
					next_x <= spi_data_rx(SizeX-1 downto 0);
				elsif packet_num = 3 then
					next_y <= spi_data_rx(SizeY-1 downto 0);
				elsif packet_num = 4 then
					next_w <= spi_data_rx(SizeX-1 downto 0);
				elsif packet_num = 5 then
					next_h <= spi_data_rx(SizeY-1 downto 0);
					--done
					done := '1';
					if current_instruction = i_rect then
						next_en(1) <= '1';
					elsif current_instruction = i_frect then
						next_en(2) <= '1';
					elsif current_instruction = i_line then
						next_en(3) <= '1';
					end if;
				else
					--shit broke
					done := '1';
					next_int_ready <= '1';
				end if;
			elsif current_instruction = i_sprite then
				if packet_num = 1 then
					next_color <= spi_data_rx(SizeColor-1 downto 0);
				elsif packet_num = 2 then
					next_x <= spi_data_rx(SizeX-1 downto 0);
				elsif packet_num = 3 then
					next_y <= spi_data_rx(SizeY-1 downto 0);
				elsif packet_num = 4 then
					next_w <= spi_data_rx(SizeX-1 downto 0);
				elsif packet_num = 5 then
					next_h(SizeSpriteCounter-1 downto 0) <= spi_data_rx(SizeSPIData-1 downto SizeSPIData-SizeSpriteCounter);
					next_id(SizeSpriteID-1 downto SizeSpriteID-(SizeSpriteID-SizeSPIData)) <= spi_data_rx(SizeSPIData-SizeSpriteCounter-1 downto 0);
				elsif packet_num = 6 then
					next_id(SizeSpriteID-(SizeSpriteID-SizeSPIData)-1 downto 0) <= spi_data_rx(SizeSPIData-1 downto 0);
					--done
					done := '1';
					next_en(4) <= '1';
				else
					--shit broke
					done := '1';
					next_int_ready <= '1';
				end if;
			elsif current_instruction = i_lsprite and is_init = '1' then
				if packet_num = 1 then
					next_h <= (others => '0');
					next_x(SizeSpriteCounter-1 downto 0) <= spi_data_rx(SizeSPIData-1 downto SizeSPIData-SizeSpriteCounter); --save data length to x
					next_id(SizeSpriteID-1 downto SizeSpriteID-(SizeSpriteID-SizeSPIData)) <= spi_data_rx(SizeSpriteID-SizeSPIData-1 downto 0);
				elsif packet_num = 2 then
					next_id(SizeSpriteID-(SizeSpriteID-SizeSPIData)-1 downto 0) <= spi_data_rx(SizeSPIData-1 downto 0);
				elsif packet_num = 3 then
					if decoder_can_access = '1' then
						next_ramdata <= spi_data_rx(SizeRAMData-1 downto 0);
						decoder_write <= '1';

						if unsigned(h) /= unsigned(x)-1 then
							next_h <= std_logic_vector(unsigned(h) + 1);
						else
							--done
							done := '1';
							next_int_ready <= '1';
						end if;
					end if;
					
				else
					--shit broke
					done := '1';
					next_int_ready <= '1';
				end if;
			elsif current_instruction = i_none then
				--shit broke
				done := '1';
				next_int_ready <= '1';
			end if;

			if done = '0' and not (current_instruction = i_lsprite and packet_num = 3) and current_instruction /= i_switch then
				next_packet_num <= packet_num + 1;
			elsif done = '1' then
				next_packet_num <= to_unsigned(0,SizeNumPackets);
				next_instruction <= i_none;
				spi_reset <= '1';
			end if;

		elsif draw_ready = '1' then
			next_timeout_count <= (others => '0');
			next_en <= (others => '0');
			next_int_ready <= '1';
			next_packet_num <= to_unsigned(0,SizeNumPackets);
			next_instruction <= i_none;
		elsif packet_num /= 0 and current_instruction /= i_switch then
			if timeout_count < TimeoutCount then
				next_timeout_count <= timeout_count + 1;
			else
				next_timeout_count <= (others => '0');
				-- shit broke
				next_en <= (others => '0');
				next_packet_num <= (others => '0');
				next_instruction <= i_none;
				next_int_ready <= '1';
				spi_reset <= '1';
			end if;
		end if;
	end process;

end behaviour;
