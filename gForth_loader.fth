\ gForth loader
\ Copright (c) 2024 Rob Probin
\ Written 20 December 2024 by Rob Probin
\ MIT license

: upper ( c1 -- c2 ) toupper ;
: cls    cr cr cr cr cr ;

include caves130.fth

\ if you want debug this, you can comment 'run' out
run
