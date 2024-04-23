
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SystemTop is
    Port ( clk: in std_logic;
        
        check: in std_logic;
        echoEntrance: in std_logic;
        trigEntrance: buffer std_logic;
        echoExit: in std_logic;
        trigExit: buffer std_logic;
        reset : in STD_LOGIC;
        code_switches : in std_logic_vector (3 downto 0);
        SS_Cathode_1 : out std_logic_vector (6 downto 0);
        SS_Anode_1: out std_logic_vector(3 downto 0);
        SS_Cathode_2 : out std_logic_vector (6 downto 0);
        SS_Anode_2: out std_logic_vector(3 downto 0);
        redLed: out STD_LOGIC;
        greenLed: out STD_LOGIC;
        exitLed: out STD_LOGIC;
        enterLed: out STD_LOGIC;
        buzzer: out STD_LOGIC;
        servo: out STD_LOGIC);
end SystemTop;

architecture Behavioral of SystemTop is

    signal increment_people_count : STD_LOGIC;
    signal object_detected_entrance : STD_LOGIC;
    signal decrement_people_count : STD_LOGIC;
    signal object_detected_exit : STD_LOGIC;
    signal random_gen_activator  : STD_LOGIC;
    signal is_checked : STD_LOGIC;
    signal buzzer_active : STD_LOGIC;
    signal random_4_bit :  std_logic_vector(3 downto 0);
    signal random_4_bit_0 :  std_logic_vector(3 downto 0);
    signal random_4_bit_1 :  std_logic_vector(3 downto 0);
    signal random_4_bit_2 :  std_logic_vector(3 downto 0);
    signal random_4_bit_3 :  std_logic_vector(3 downto 0);
    signal servoPos :  std_logic_vector(6 downto 0);
    constant BUZZER_WAIT_CYCLE : integer := 300000000;
    constant SERVO_WAIT_CYCLE : integer := 500000000;
    signal buzzer_counter : integer range 0 to BUZZER_WAIT_CYCLE;
    signal servo_counter : integer range 0 to SERVO_WAIT_CYCLE;
    signal people_counter : integer range 0 to 9999;
    signal  people_counter_0 :  std_logic_vector(3 downto 0);
    signal  people_counter_1 :  std_logic_vector(3 downto 0);
    signal  people_counter_2 :  std_logic_vector(3 downto 0);
    signal  people_counter_3 :  std_logic_vector(3 downto 0);
     signal last_enter_state : STD_LOGIC := '0';
     signal last_exit_state : STD_LOGIC := '0';

    constant PEOPLE_COUNTER_START_WAIT_CYCLE : integer := 50000000;
    signal people_counter_start_wait_counter : integer range 0 to PEOPLE_COUNTER_START_WAIT_CYCLE;
begin

    MotionSensorEntranceInst : entity work.distance
        Port map (
            fpgaclk => clk,
            trig => trigEntrance,
            echo => echoEntrance,
            data => object_detected_entrance 
        );
        
         MotionSensorExitInst : entity work.distance
        Port map (
            fpgaclk => clk,
            trig => trigExit,
            echo => echoExit,
            data => object_detected_exit
        );
        
     ServoInst : entity work.servo_pwm_clk64kHz
        Port map (
            clk => clk,
            reset => reset,
            pos => servoPos,
            servo => servo
        );
        
     
    RandomGenInst : entity work.RandomGenerator
        Port map (
            clk => clk,
            reset => reset,
            button => random_gen_activator ,
            random4Digit => random_4_bit
        );
        
    RandomDisplayInst : entity work.SevenSegment
        Port map (
           clk => clk,
           isAnode => '1',
           digit0 => random_4_bit_0,
           digit1 => random_4_bit_1,
           digit2 => random_4_bit_2,
           digit3 => random_4_bit_3,
           SS_Cathode =>  SS_Cathode_1,
           SS_Anode => SS_Anode_1

        );
        
    
PeopleCountDisplayInt : entity work.SevenSegment
        Port map (
           clk => clk,
           isAnode => '0',
           digit0 => people_counter_0 ,
           digit1 => people_counter_1,
           digit2 => people_counter_2,
           digit3 => people_counter_3,
           SS_Cathode =>  SS_Cathode_2,
           SS_Anode => SS_Anode_2
        );
     
       
    
    random_4_bit_0 <= (3 downto 1 => '0', 0 => random_4_bit(0));
    random_4_bit_1 <= (3 downto 1 => '0', 0 => random_4_bit(1));
    random_4_bit_2 <= (3 downto 1 => '0', 0 => random_4_bit(2));
    random_4_bit_3 <= (3 downto 1 => '0', 0 => random_4_bit(3));
    people_counter_0 <= std_logic_vector(to_unsigned(people_counter mod 10, 4));
    people_counter_1 <= std_logic_vector(to_unsigned(people_counter/10 mod 10, 4));
    people_counter_2 <= std_logic_vector(to_unsigned(people_counter/100 mod 10, 4));
    people_counter_3 <= std_logic_vector(to_unsigned(people_counter/1000 mod 10, 4));
    buzzer <= buzzer_active;
    redLed <= '1' when people_counter >= 5 else '0';
    greenLed <= '1' when people_counter < 5 else '0';
    random_gen_activator <= object_detected_entrance  when people_counter < 5 else '0';
        
        enterLed <= object_detected_entrance;
         exitLed <= object_detected_exit;
    
      

        process(clk)
         variable enter_action : boolean;
         variable exit_action : boolean;
         
        
    begin
        
        if rising_edge(clk) then
            
            enter_action := (object_detected_entrance = '1' and last_enter_state = '0');
            last_enter_state <= object_detected_entrance;
            
            exit_action := (object_detected_exit = '1' and last_exit_state = '0');
            last_exit_state <= object_detected_exit;
            
            if(enter_action) then
                 people_counter <= people_counter + 1;
            end if;
            
            if(exit_action) then
                if ( people_counter > 0) then
                 people_counter <= people_counter - 1; end if;
            end if;
            
     
            if (buzzer_active  = '1') then
                buzzer_counter <= buzzer_counter + 1;
                if (buzzer_counter = BUZZER_WAIT_CYCLE) then
                    buzzer_active <= '0';
                end if;    
            else
                if (is_checked = '0' and check = '1') then
                    is_checked <= '1';
                    
                    
                    if ((random_4_bit xor code_switches) = "0000" and (people_counter < 5) ) then
                        servoPos <= "1000000";
                        servo_counter <= 0;
                    else  
                        buzzer_active <= '1';
                        buzzer_counter <= 0;
                    end if; 
                
                
                elsif (is_checked = '1' and check = '0') then
                    is_checked <= '0';
                end if;
            end if;
             
            if (servoPos = "1000000") then
                    servo_counter <= servo_counter + 1;
                if (servo_counter = SERVO_WAIT_CYCLE) then
                    servoPos <= "0000000";
                    end if;  
                end if;
            end if;
 
    end process;

end Behavioral;

