----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.12.2023 00:28:54
-- Design Name: 
-- Module Name: SevenSegment - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SevenSegment is
    Port ( clk : in STD_LOGIC;
           isAnode: in STD_LOGIC;
           digit0: in std_logic_vector (3 downto 0);
           digit1: in std_logic_vector (3 downto 0);
           digit2: in std_logic_vector (3 downto 0);
           digit3: in std_logic_vector (3 downto 0);
           SS_Cathode : out std_logic_vector (6 downto 0);
           SS_Anode: out std_logic_vector(3 downto 0));
end SevenSegment;

architecture Behavioral of SevenSegment is

    signal SSCase : integer range 0 to 3;
    constant SS_COUNT : integer := 100000;
    signal SSCounter : integer range 0 to SS_COUNT;
    signal digit : integer range 0 to 9;

    -- Random Number Generator Process
    begin
    SS_Anode <=  std_logic_vector(not to_unsigned(2**SSCase, 4)) when isAnode = '1' else std_logic_vector(to_unsigned(2**SSCase, 4));

    process(SSCase)
    begin
        case SSCase is
    when 0 =>  digit <= to_integer(unsigned(digit0));
    when 1 =>  digit <= to_integer(unsigned(digit1));
    when 2 =>  digit <= to_integer(unsigned(digit2));
    when 3 =>  digit <= to_integer(unsigned(digit3));        
     end case;
    end process;
   
    process(clk)
    begin
        
        if rising_edge(clk) then
             SSCounter <= SSCounter +1;
            if SSCounter = SS_COUNT then
                SSCase <= SSCase+1; 
                SSCounter <= 0;
            end if;
          
            
            
        end if;
    end process;


   process(digit)
    begin
        case digit is
            when 0 =>
                SS_Cathode <=  "0000001";
            when 1 =>
                SS_Cathode <=  "1001111";
            when 2 =>
                SS_Cathode <=  "0010010";
            when 3 =>
                SS_Cathode <=  "0000110";
            when 4 =>
                SS_Cathode <=  "1001100";
            when 5 =>
                SS_Cathode <=  "0100100";
            when 6 =>
                SS_Cathode <=  "0100000";
            when 7 =>
                SS_Cathode <=  "0001111";
            when 8 =>
                SS_Cathode <=  "0000000";
            when 9 =>
                SS_Cathode <=  "0000100";
        end case;
    end process;


end Behavioral;
