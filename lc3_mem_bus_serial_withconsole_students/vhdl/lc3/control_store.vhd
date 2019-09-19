-- ***************************************************************************************
-- LC3 Processor
-- Digital Electronics Lab Course
-- 2019
-- Module: Control Store
-- ***************************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;

entity Control_Store is
architecture behavior of Control_Store is
  constant Ctrl_Store : bits49array := (
    "0"&"010"&"010010"&"00000000000"&"00000000"&"XXXXXXXXXXXXXXX"&"XX0XX",  -- 0
  signal Microinstruction      : bits49;
begin
  -- The following line takes bits from 'next_state',
  next_Microinstruction <= Ctrl_Store( conv_integer( next_state ));
    if Reset = '1' then
  IRD             <= Microinstruction( 48 );