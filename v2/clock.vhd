-- Standard libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration for 6 digit clock
entity clock is
	port
	( 
		clk  	        : in std_logic; -- clock signal
		setSeconds      : in std_logic; -- used for setting seconds
		setMinutes      : in std_logic; -- used for setting minutes
		setHours        : in std_logic; -- used for setting hours
		chup            : in std_logic; -- used for setting h/m/s up by one
		chdown          : in std_logic; -- used for setting h/m/s down by one
		setLedSeconds   : out std_logic; -- display that "setSeconds" is active
		setLedMinutes   : out std_logic; -- display that "setMinutes" is active
		setLedHours     : out std_logic; -- display that "setHours" is active
		
		-- outputs for 7 segment displays
		output0         : out std_logic_vector(7 downto 0); -- seconds unit
		output1         : out std_logic_vector(7 downto 0); -- seconds decimal
		output2         : out std_logic_vector(7 downto 0); -- minutes unit
		output3		: out std_logic_vector(7 downto 0); -- minutes decimal
		output4 	: out std_logic_vector(7 downto 0); -- hours unit
		output5 	: out std_logic_vector(7 downto 0)  -- hours decimal
	);
end clock;

-- Architecture block
architecture behav of clock is

-- component for 7 segment display decoder
component seven_seg is
	port
	(
		inputBCD  		: in std_logic_vector(3 downto 0);
		outputHEX 		: out std_logic_vector(7 downto 0)
	);
end component;

-- function that converts 8 bit binary input to 8 bit BCD output 
function to_bcd ( bin : std_logic_vector(7 downto 0) ) return std_logic_vector is
	variable i : integer:=0;
	variable bcd : std_logic_vector(7 downto 0) := (others => '0');
	variable bint : std_logic_vector(7 downto 0) := bin;

	begin
	for i in 0 to 7 loop  -- repeating 8 times.
		bcd(7 downto 1) := bcd(6 downto 0);  --shifting the bits.
		bcd(0) := bint(7);
		bint(7 downto 1) := bint(6 downto 0);
		bint(0) :='0';


		if(i < 7 and bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
			bcd(3 downto 0) := bcd(3 downto 0) + "0011";
		end if;

		if(i < 7 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
			bcd(7 downto 4) := bcd(7 downto 4) + "0011";
		end if;
	end loop;
	
	return bcd;
	
end to_bcd;

-- constants
constant CLK_LIMIT     : integer := 50000000; -- 50 MHz clock signal (!!change this to 1 for simulation!!)
constant SECONDS_LIMIT : integer := 59;       -- max seconds
constant MINUTES_LIMIT : integer := 59;		 -- max minutes
constant HOURS_LIMIT   : integer := 23;		 -- max hours
constant CHANGE_PARAM  : integer := 8;			 -- parameter used for changing h/m/s by one eight times in a second

-- counters, 12:00:00 is default
signal cnt_seconds : integer := 0;
signal cnt_minutes : integer := 0;
signal cnt_hours   : integer := 12;

-- seconds
signal clk_cnt0 : integer := 1; -- for normal couting
signal clk_cnt1 : integer := 1; -- for setting

-- minutes
signal clk_cnt2 : integer := 1; -- for normal couting
signal clk_cnt3 : integer := 1; -- for setting

-- auxiliary inputs and outputs to display hours, minutes and seconds on displays

-- seconds
signal temp_in_s : std_logic_vector(7 downto 0);
signal temp_out_s : std_logic_vector(7 downto 0);

-- minutes
signal temp_in_m : std_logic_vector(7 downto 0);
signal temp_out_m : std_logic_vector(7 downto 0);

-- hours
signal temp_in_h : std_logic_vector(7 downto 0);
signal temp_out_h : std_logic_vector(7 downto 0);

-- begin architecture
begin

	-- setting LED outputs
	setLedSeconds <= setSeconds;
	setLedMinutes <= setMinutes;
	setLedHours   <= setHours;
	
	-- convert from binary to bcd
	temp_out_s <= to_bcd(temp_in_s);
	temp_out_m <= to_bcd(temp_in_m);
	temp_out_h <= to_bcd(temp_in_h);

	-- instances of 7 segment display compoments
	
	-- seconds
	seven0 : seven_seg port map(temp_out_s(3 downto 0), output0); -- unit
	seven1 : seven_seg port map(temp_out_s(7 downto 4), output1); -- decimal

	-- minuts
	seven2 : seven_seg port map(temp_out_m(3 downto 0), output2); -- unit
	seven3 : seven_seg port map(temp_out_m(7 downto 4), output3); -- decimal
	
	-- hours
	seven4 : seven_seg port map(temp_out_h(3 downto 0), output4); -- unit
	seven5 : seven_seg port map(temp_out_h(7 downto 4), output5); -- decimal
			
	-- main process
	process(clk, setSeconds, chup, chdown, cnt_seconds, cnt_minutes, cnt_hours)
	begin
	
		if rising_edge(clk) then
			if setSeconds = '0' and setMinutes = '0' and setHours = '0' then -- no setting
				if clk_cnt0 = CLK_LIMIT then -- when exactly 1 second pass
					cnt_seconds <= cnt_seconds + 1; -- up one second
					clk_cnt0 <= 1; -- reset auxiliary counter
				else
					clk_cnt0 <= clk_cnt0 + 1; -- count up auxiliary counter
				end if;
			elsif setSeconds = '1' then -- setting seconds
				if clk_cnt1 = CLK_LIMIT / CHANGE_PARAM then -- changing CHANGE_PARAM times in 1 second. For example when CHANGE_PARAM = 8 we can change seconds 8 times in 1 second
					clk_cnt1 <= 1; -- reset auxiliary counter
					-- changing up by one
					if chup = '0' then
						if cnt_seconds = SECONDS_LIMIT then
							cnt_seconds <= 0;
						else
							cnt_seconds <= cnt_seconds + 1;
						end if;
					end if;
					-- changing down by one
					if chdown = '0' then
						if cnt_seconds = 0 then
							cnt_seconds <= SECONDS_LIMIT;
						else
							cnt_seconds <= cnt_seconds - 1;
						end if;
					end if;
				else		
					clk_cnt1 <= clk_cnt1 + 1; -- count up auxiliary counter
				end if;
			elsif setMinutes = '1' then -- setting minutes
				if clk_cnt2 = CLK_LIMIT / CHANGE_PARAM then
					clk_cnt2 <= 1;
					if chup = '0' then
						if cnt_minutes = MINUTES_LIMIT then
							cnt_minutes <= 0;
						else
							cnt_minutes <= cnt_minutes + 1;
						end if;
					end if;
					if chdown = '0' then
						if cnt_minutes = 0 then
							cnt_minutes <= MINUTES_LIMIT;
						else
							cnt_minutes <= cnt_minutes - 1;
						end if;
					end if;
				else		
					clk_cnt2 <= clk_cnt2 + 1;
				end if;
			elsif setHours = '1' then -- setting hours
				if clk_cnt3 = CLK_LIMIT / CHANGE_PARAM then
					clk_cnt3 <= 1;
					if chup = '0' then
						if cnt_hours = HOURS_LIMIT then
							cnt_hours <= 0;
						else
							cnt_hours <= cnt_hours + 1;
						end if;
					end if;
					if chdown = '0' then
						if cnt_hours = 0 then
							cnt_hours <= HOURS_LIMIT;
						else
							cnt_hours <= cnt_hours - 1;
						end if;
					end if;
				else		
					clk_cnt3 <= clk_cnt3 + 1;
				end if;
			end if;
			
			-- checking if seconds counter reached limit
			if cnt_seconds > SECONDS_LIMIT then
				cnt_minutes <= cnt_minutes + 1; -- minutes up by one
				cnt_seconds <= 0; -- reset seconds
			end if;
			
			-- checking if seconds counter reached limit
			if cnt_minutes > MINUTES_LIMIT then
				cnt_hours <= cnt_hours + 1; -- hours up by one
				cnt_minutes <= 0; -- reset minutes
				cnt_seconds <= 0; -- reset seconds
			end if;
				
			-- checking if hours counter reached limit
			if cnt_hours > HOURS_LIMIT then
				-- reset all numbers
				cnt_hours <= 0; 
				cnt_minutes <= 0;
				cnt_seconds <= 0;
			end if;
				
		end if;
		
		temp_in_s <= std_logic_vector(to_unsigned(cnt_seconds, temp_in_s'length));
		temp_in_m <= std_logic_vector(to_unsigned(cnt_minutes, temp_in_m'length));
		temp_in_h <= std_logic_vector(to_unsigned(cnt_hours, temp_in_h'length));	
		
	end process;
	
end behav;