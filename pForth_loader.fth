\ pForth loader
\ Copright (c) 2024 Rob Probin
\ Written 20 December 2024 by Rob Probin
\ GPLv3 license

\ convert a character to support case
: upper ( c1 -- c2 ) 
    \ if( c1 >= 'a' && c1 <= 'z')
    \ return c1 - ('a' - 'A');
    dup [CHAR] a [CHAR] z 1+ within if
        [CHAR] a - [CHAR] A +
    then
;
\ rename map - map is pForth word to run
: memory map ;

include caves130.fth

\ if you want debug this, you can comment 'run' out, and include
\ from inside pForth rather than from load this file on the command line
run
