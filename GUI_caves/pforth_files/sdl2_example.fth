\ SDL2 parsing helper
\ Copyright (C) 2024 Rob Probin, based on work by ProgrammingRainbow
\ License: zLib (see LICENSE)
\ Written December 2024. 
\ Based off Video1 'main.fs' from ProgrammingRainbow's SDL2 tutorial.

\ SDL2 parsing helper
require pforth_files/sdl2_parse.fth

\ SDL2 library - notice internal paths assume we are in SDL2/ directory
S" SDL2/" set-require-subdir 
require SDL.fs
S" " set-require-subdir

\ Constants
0 CONSTANT NULL
s\" pForth SDL demo\0" DROP CONSTANT WINDOW_TITLE
800 CONSTANT WINDOW_WIDTH
600 CONSTANT WINDOW_HEIGHT
SDL_INIT_EVERYTHING CONSTANT SDL_FLAGS

0 VALUE exit-value
NULL VALUE window
NULL VALUE renderer

\ Words
: game-cleanup ( -- )
    renderer SDL_DestroyRenderer
    NULL TO renderer
    window SDL_DestroyWindow
    NULL TO window

    SDL_Quit
;

: c-str-len ( c-addr -- c-addr u ) 0 BEGIN 2DUP + C@ WHILE 1+ REPEAT ;

: error ( c-addr u -- )
    stderr write-file
    SDL_GetError c-str-len stderr write-file
    s\" \n" stderr write-file
    1 TO exit-value
    game-cleanup
;

: initialize-sdl ( -- )
    SDL_FLAGS SDL_Init IF
        S" Error initializing SDL: " error
    THEN

    WINDOW_TITLE SDL_WINDOWPOS_CENTERED SDL_WINDOWPOS_CENTERED WINDOW_WIDTH WINDOW_HEIGHT 0
    SDL_CreateWindow TO window
    window 0= IF 
        S" Error creating Window: " error
    THEN

    window -1 0 SDL_CreateRenderer TO renderer
    renderer 0= IF
        S" Error creating Renderer: " error
    THEN
;

: game-loop ( -- )
    renderer SDL_RenderClear DROP
        
    renderer SDL_RenderPresent

    5000 SDL_Delay

    game-cleanup
;

: play-game ( -- )
    initialize-sdl
    game-loop
;

play-game
