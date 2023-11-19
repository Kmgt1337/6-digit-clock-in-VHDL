-- Standard libraries
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity declaration for 6 digit clock
entity clock is
	port
	( 
		clk  	          : in std_logic; -- clock signal
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
		output3			 : out std_logic_vector(7 downto 0); -- minutes decimal
		output4 			 : out std_logic_vector(7 downto 0); -- hours unit
		output5 			 : out std_logic_vector(7 downto 0)  -- hours decimal
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

constant CLK_LIMIT     : integer := 50000000; -- 50 MHz clock signal (!!change this to 1 for simulation!!)
constant SECONDS_LIMIT : integer := 59;       -- max seconds
constant MINUTES_LIMIT : integer := 59;		 -- max minutes
constant HOURS_LIMIT   : integer := 23;		 -- max hours
constant CHANGE_PARAM  : integer := 8;			 -- parameter used for changing h/m/s by one eight times in a second

-- outputs for seconds
signal in_hex0 : std_logic_vector(3 downto 0); -- unit
signal in_hex1 : std_logic_vector(3 downto 0); -- decimal

-- outputs for minutes
signal in_hex2 : std_logic_vector(3 downto 0); -- unit
signal in_hex3 : std_logic_vector(3 downto 0); -- decimal

-- outputs for hours
signal in_hex4 : std_logic_vector(3 downto 0); -- unit
signal in_hex5 : std_logic_vector(3 downto 0); -- decimal

-- counters, 12:00:00 is default
signal cnt_seconds : integer := 0;
signal cnt_minutes : integer := 0;
signal cnt_hours   : integer := 12;

-- counters for seconds, used to assign it to the outputs
signal cnt_unity_seconds   : std_logic_vector(3 downto 0);
signal cnt_decimal_seconds : std_logic_vector(3 downto 0);

-- counters for minutes, used to assign it to the outputs
signal cnt_unity_minutes   : std_logic_vector(3 downto 0);
signal cnt_decimal_minutes : std_logic_vector(3 downto 0);

-- counters for hours, used to assign it to the outputs
signal cnt_unity_hours   : std_logic_vector(3 downto 0);
signal cnt_decimal_hours : std_logic_vector(3 downto 0);

-- auxiliary counters used to get exactly 1 second. For clock 50 Mhz we get 1 second when clk_cnt = CLK_LIMIT

-- seconds
signal clk_cnt0 : integer := 1; -- for normal couting
signal clk_cnt1 : integer := 1; -- for setting

-- minutes
signal clk_cnt2 : integer := 1; -- for normal couting
signal clk_cnt3 : integer := 1; -- for setting

-- hours
signal clk_cnt4 : integer := 1; -- for normal counting
signal clk_cnt5 : integer := 1; -- for setting

begin

	-- setting LED outputs
	setLedSeconds <= setSeconds;
	setLedMinutes <= setMinutes;
	setLedHours   <= setHours;
	
	-- creating decimal 2 digit output for seconds
	in_hex0 <= cnt_unity_seconds(3) & cnt_unity_seconds(2) & cnt_unity_seconds(1) & cnt_unity_seconds(0); -- unit
	in_hex1 <= cnt_decimal_seconds(3) & cnt_decimal_seconds(2) & cnt_decimal_seconds(1) & cnt_decimal_seconds(0); -- decimal
	
	-- creating decimal 2 digit output for minutes
	in_hex2 <= cnt_unity_minutes(3) & cnt_unity_minutes(2) & cnt_unity_minutes(1) & cnt_unity_minutes(0); -- unit
	in_hex3 <= cnt_decimal_minutes(3) & cnt_decimal_minutes(2) & cnt_decimal_minutes(1) & cnt_decimal_minutes(0); -- decimal
	
	-- creating decimal 2 digit output for hours
	in_hex4 <= cnt_unity_hours(3) & cnt_unity_hours(2) & cnt_unity_hours(1) & cnt_unity_hours(0); -- unit
	in_hex5 <= cnt_decimal_hours(3) & cnt_decimal_hours(2) & cnt_decimal_hours(1) & cnt_decimal_hours(0); -- decimal
	
	-- instances of 7 segment display compoments
	
	-- seconds
	seven0 : seven_seg port map(in_hex0, output0); -- unit
	seven1 : seven_seg port map(in_hex1, output1); -- decimal
	
	-- minuts
	seven2 : seven_seg port map(in_hex2, output2); -- unit
	seven3 : seven_seg port map(in_hex3, output3); -- decimal
	
	-- hours
	seven4 : seven_seg port map(in_hex4, output4); -- unit
	seven5 : seven_seg port map(in_hex5, output5); -- decimal
	
	-- main process
	process(clk, setSeconds, chup, chdown)
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
		
		-- Conversion from hexadecimal format to decimal format
		-- We get unit by performing modulo 10 on counter
		-- We get decimal by performing division by 10 on counter
		
		-- seconds
		cnt_unity_seconds <= std_logic_vector(to_unsigned((cnt_seconds mod 10), cnt_unity_seconds'length)); -- unit
		cnt_decimal_seconds <= std_logic_vector(to_unsigned((cnt_seconds / 10), cnt_decimal_seconds'length)); -- decimal
		
		-- minutes
		cnt_unity_minutes <= std_logic_vector(to_unsigned((cnt_minutes mod 10), cnt_unity_minutes'length)); -- unit
		cnt_decimal_minutes <= std_logic_vector(to_unsigned((cnt_minutes / 10), cnt_decimal_minutes'length)); -- decimal
		
		-- hours
		cnt_unity_hours <= std_logic_vector(to_unsigned((cnt_hours mod 10), cnt_unity_hours'length)); -- unit
		cnt_decimal_hours <= std_logic_vector(to_unsigned((cnt_hours / 10), cnt_decimal_hours'length)); -- decimal
		
	end process;
	
end behav;
