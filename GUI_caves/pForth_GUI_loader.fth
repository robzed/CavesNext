\ gForth loader
\ Copright (c) 2024 Rob Probin
\ Written 20 December 2024 by Rob Probin
\ GPLv3 license
\
\ Requires SDL libraries SDL2, SDL_image, SDL_mixer, and SDL_ttf
\ and https://github.com/ProgrammingRainbow/Beginners-Guide-to-SDL2-in-Gforth
\ Put the SDL folder inside this folder under the name SDL2. 
\ SDL2 bindings for Gforht are kindly Zlib licenses - so no worries.

\ convert a character to support case
: upper ( c1 -- c2 ) 
    \ if( c1 >= 'a' && c1 <= 'z')
    \ return c1 - ('a' - 'A');
    dup [CHAR] a [CHAR] z 1+ within if
        [CHAR] a - [CHAR] A +
    then
;
\ rename map - map is pForth word to view dictionary space
: memory map ;

: load-font ( "name" -- fontaddr )
;

: set-font ( fontaddr -- )
;

: ~type ( c-addr u -- )
    type
;

: ~." ( "string" -- )
    s" 2dup type ." type
;

: ~emit ( c -- )
    emit
;

: ~cr
    cr
;

: ~key ( -- key )
    key
;
: ~accept 
    accept
;

include speccy_emu.fth
\ include caves130_GUI.fth

: game.update
;

: game.draw
    clear-screen
;

variable loopc
0 value game_start_time

\ : game_core
\ ;

: run
    0 loopc !
    S" Caves" platform-open

    SDL_GetTicks64 to game_start_time
    false to quit_flag
    begin
        do-event-loop
        game.update
        game.draw
        show_screen
        
        frame-delay
        \ ." Running " loopc @ . cr
        loopc @ 1+ loopc !
    key? quit_flag or until

    ." Exiting (loop count = " loopc @ . ." ) " cr
    ." Average frame time = " SDL_GetTicks64 game_start_time - loopc @ / . ." ms" cr
    .frame_stats
    depth if ." ============ WARNING Stack not empty =========" cr then

    platform-close
;

\ run

\ load with:
\ /Users/rob/Current_Projects/pForth/pforth_SDL/platforms/unix/pforth_standalone pForth_GUI_loader.fth
