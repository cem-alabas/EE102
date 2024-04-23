library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity distance is
  Port (fpgaclk: in std_logic;
        echo: in std_logic;
        trig: buffer std_logic;
        data: out std_logic
        );
end distance;

architecture Behavioral of distance is

signal echooo: integer:=0;

begin
process(fpgaclk, echo)
variable constanta,constantb, constantc:integer:=0;
variable y :std_logic:='0';
begin   


if rising_edge(fpgaclk) then
if(constanta=0) then
    trig<='1';
    
elsif(constanta=10000) then
    trig<='0';
    y:='1';
elsif(constanta=10000000) then
    constanta:=0;
    trig<='1';
end if;
constanta:=constanta+1;

if(echo = '1') then
    constantb:=constantb+1;
end if;
    
if(echo = '0' and y='1') then 
    echooo<= constantb;
    constantb:=0;
    y:='0';
end if;
        
        
if  (echooo < 280000)then
    data <= '1';
    
else
    data <= '0';
end if;
end if;


end process;
end Behavioral;

