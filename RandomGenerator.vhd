library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;

entity RandomGenerator is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
           button : in STD_LOGIC; -- Button input
           random4Digit: out std_logic_vector (3 downto 0));
           
end RandomGenerator;

architecture Behavioral of RandomGenerator is

    signal lfsr : STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal last_button_state : STD_LOGIC := '0';


    -- Random Number Generator Process
    begin
    
    random4Digit <= lfsr;
    
    
    process(clk, reset)
    variable button_pressed : boolean;

    begin
        
        if reset = '1' then
            lfsr <= "0000";
        elsif rising_edge(clk) then
           
            -- Check for button press (edge detection)
            button_pressed := (button = '1' and last_button_state = '0');
            
            
                
            last_button_state <= button;
            
            if last_button_state = '1' and button = '0' and lfsr <= "0000" then
                lfsr <= "0001";
            end if;
            -- Update LFSR either on button press or periodically
            if button_pressed then
                
                lfsr(3 downto 1) <= lfsr(2 downto 0);
                lfsr(0) <= lfsr(3) xor lfsr(2);
                
                
            end if;
        end if;
    end process;

    
end Behavioral;
