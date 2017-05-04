library IEEE;
use IEEE.std_logic_1164.ALL;

PACKAGE parameter_def IS
	constant InstrSize : INTEGER;
	constant SizeNumPackets : INTEGER;
	constant SizeSpriteID : INTEGER;
	constant SizeSpriteCounter : INTEGER;
	constant TimeoutCount : INTEGER;
	constant SizeTimeoutCounter : INTEGER;
	constant NumDrawModules : INTEGER;
	constant SizeX : INTEGER;
	constant SizeY : INTEGER;
	constant NumStateReg : INTEGER;
	constant SizeRAMData : INTEGER;
	constant SizeRAMAddr : INTEGER;
	constant SizeColor : INTEGER;
	constant SizeSPIData : INTEGER;
	constant ResolutionX : INTEGER;
	constant ResolutionY : INTEGER;
END parameter_def;

PACKAGE BODY parameter_def IS
	constant InstrSize : INTEGER := 3; --bits
	constant SizeNumPackets : INTEGER := 3; -- aantal bits voor counter, log2(7 bytes) => 3 bits
	constant SizeSpriteID : INTEGER := 10;
	constant SizeSpriteCounter : INTEGER := 6;
	constant TimeoutCount : INTEGER := 2**7-1; --aantal ticks voor timeout
	constant SizeTimeoutCounter : INTEGER := 7; --aantal bits voor timeout counter
	constant NumDrawModules : INTEGER := 5; 
	constant SizeX : INTEGER := 8;
	constant SizeY : INTEGER := 7;
	constant NumStateReg : INTEGER := 1;
	constant SizeRAMData : INTEGER := 6;
	constant SizeRAMAddr : INTEGER := 16;
	constant SizeColor : INTEGER := 6;
	constant SizeSPIData : INTEGER := 8;
	constant ResolutionX : INTEGER := 160;
	constant ResolutionY : INTEGER := 120;
END parameter_def;





