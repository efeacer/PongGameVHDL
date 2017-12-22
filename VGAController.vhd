----------------------------------------------------------------------------------
-- Engineer: EFE ACER
-- Project Name: Pong Game
-- Brief: The top module of the project, receives its input from the board, generates
--        the outputs using its submodules and sends them to the monitor from the board. 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGAController is
  Port (clock, centerButton, upButton, leftButton, rightButton, downButton: in std_logic;
        difficultyControl: in std_logic_vector(1 downto 0);
        hSync, vSync: out std_logic;
        VGARed, VGAGreen, VGABlue: out std_logic_vector(3 downto 0));
end VGAController;

architecture Behavioral of VGAController is
--Decleration of the components
component ClockDivider is
    Port (clockIn: in std_logic;
          clockOut: out std_logic);
end component;  
component Sync is
    Port (clock, left, right, start: in std_logic;
          difficultyControl: in std_logic_vector(1 downto 0);
          hSync, vSync: out std_logic; 
          r, g, b: out std_logic_vector(3 downto 0));
end component;
--Intermediate carrier signal   
signal VGAClock: std_logic;   
begin
    --port-mappings
    Component1: ClockDivider 
                    port map(clockIn => clock,
                             clockOut => VGAClock);
    Component2: Sync
                    port map(clock => VGAClock,
                             left => leftButton,
                             right => rightButton,
                             start => centerButton,
                             difficultyControl => difficultyControl,
                             hSync => hSync,
                             vSync => vSync,
                             r => VGARed,
                             g => VGAGreen,
                             b => VGABlue);
end Behavioral;
