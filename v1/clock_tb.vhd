library ieee;
use ieee.std_logic_1164.all;

entity clock_tb is
end clock_tb;

architecture simulation of clock_tb is

component clock is
	port
	(
		clk  	        : in std_logic;
		setSeconds      : in std_logic;
		setMinutes      : in std_logic;
		setHours        : in std_logic;
		chup            : in std_logic;
		chdown          : in std_logic;
		setLedSeconds   : out std_logic;
		setLedMinutes   : out std_logic;
		setLedHours     : out std_logic;
		output0         : out std_logic_vector(7 downto 0);
		output1         : out std_logic_vector(7 downto 0);
		output2         : out std_logic_vector(7 downto 0);
		output3		: out std_logic_vector(7 downto 0);
		output4 	: out std_logic_vector(7 downto 0);
		output5 	: out std_logic_vector(7 downto 0)
	);
end component;

signal clk, setSeconds, setMinutes, setHours, setLedMinutes, setLedSeconds, setLedHours : std_logic := '0';
signal chup, chdown : std_logic := '1';
signal output0, output1, output2, output3, output4, output5 : std_logic_vector(7 downto 0);

begin
	uut : clock port map(clk, setSeconds, setMinutes, setHours, chup, chdown, setLedSeconds, setLedMinutes, setLedHours, output0, output1, output2, output3, output4, output5);

	clk <= not clk after 1 ns;

end simulation;
