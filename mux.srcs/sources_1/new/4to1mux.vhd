----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/30/2024 01:06:14 PM
-- Design Name: 
-- Module Name: 4to1mux - whenmux
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity fourto1mux is
    Port ( D0 : in STD_LOGIC;
           D1 : in STD_LOGIC;
           D2 : in STD_LOGIC;
           D3 : in STD_LOGIC;
           SEL: in STD_LOGIC_VECTOR(1 downto 0);
           MX_OUT : out STD_LOGIC);
end fourto1mux;

architecture whenmux of fourto1mux is
begin
    MX_OUT <= D0 when (SEL(1) = '0' AND SEL(0) = '0') else
              D1 when (SEL="01") else
              D2 when (SEL="10") else
              D3 when (SEL="11") else
              '0';
end whenmux;
