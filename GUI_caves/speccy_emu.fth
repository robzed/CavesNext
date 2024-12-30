\ This let's us run effectively a Spectrum Next game on Mac/Linux/Windows
\ Copyright (c) 2024 Rob Probin
\ Written 20 December 2024 by Rob Probin
\ GPLv3 license
\
\ Requires SDL libraries SDL2, SDL_image, SDL_mixer, and SDL_ttf and pForth_SDL

\ Programming notes:
\    * underscore is internal to the file (like a private variable in Python)

\ Constants
0 CONSTANT NULL

\ Make a window title with a zero terminator for C-based SDL call
256 value WINDOW_WIDTH
192 value WINDOW_HEIGHT
4 value PIXEL_SCALE

0 VALUE exit-value
NULL VALUE window
128 constant _max_window_title_len
create window_title _max_window_title_len 1+ ALLOT
NULL VALUE renderer
SDL_WINDOW_SHOWN constant window_flags
-1 constant first_rendering_driver
0 constant renderer_flags
\ SDL_RENDERER_PRESENTVSYNC constant renderer_flags
\ SDL_RENDERER_ACCELERATED SDL_RENDERER_PRESENTVSYNC or constant renderer_flags

false VALUE quit_flag
CREATE game_event SDL_Event ALLOT

: c-str-len ( c-addr -- c-addr u ) 0 BEGIN 2DUP + C@ WHILE 1+ REPEAT ;
: ctype ( c-str-addr -- ) c-str-len type ;

\ SDL_LoadBMP is Macro in C
: SDL_LoadBMP ( c-string -- SDL_Surface* )
    S\" rb\x00" drop SDL_RWFromFile 1 SDL_LoadBMP_RW
;


: _to_c-str ( source u target -- c-addr )
    \ limit the length of the string
    swap _max_window_title_len min swap

    \ zero terminate the string to start
    2dup +  \ one past the end of the string
    0 swap !    

    swap
    move ( source target u -- )
;

: cleanup-events ( -- )
    \ ." Waiting for events for 0.1 s" cr
    100 0 do
        game_event SDL_PollEvent if
            game_event SDL_Event-type u32@
            \ ." <<event type =" . cr
            drop
        then
        1 sdl_delay
    loop
    \ ." DONE - Waiting for events for 0.1 s" cr
;

: game-cleanup ( -- )
    renderer SDL_DestroyRenderer
    NULL TO renderer
    window SDL_DestroyWindow
    NULL TO window

    cleanup-events

    SDL_Quit  \  ." quit game error " exit-value @ . cr 10 ms
;

: .SDL_error ( c-addr u -- )
    ." Error: " type cr
    SDL_GetError ctype space cr
    1 TO exit-value
    game-cleanup
;

\ Pass in the Window as a string
: initialize-sdl ( addr n --  )
    window_title _to_c-str

    SDL_INIT_EVERYTHING SDL_Init IF
        S" Error initializing SDL: " .SDL_error
    THEN

    window_title SDL_WINDOWPOS_CENTERED SDL_WINDOWPOS_CENTERED 
    WINDOW_WIDTH PIXEL_SCALE * WINDOW_HEIGHT PIXEL_SCALE * window_flags
    SDL_CreateWindow TO window
    window 0= IF 
        S" Error creating Window: " .SDL_error
    THEN

    window first_rendering_driver renderer_flags SDL_CreateRenderer TO renderer
    renderer 0= IF
        S" Error creating Renderer: " .SDL_error
    THEN
;

: random-color ( -- )
    renderer 256 choose 256 choose 256 choose 255 SDL_SetRenderDrawColor dup if
        ." Error setting color code " .
        S" SDL Error:" SDL_GetError ctype cr
    else
        drop
    THEN
;

: nothing ;

\ ----------------- Public interface ----------------- \

defer do_keyd
' nothing is do_keyd


: do-event-loop
    BEGIN game_event SDL_PollEvent WHILE
        game_event SDL_Event-type u32@
        \ dup ." event type =" . cr
        DUP SDL_QUIT_ENUM = IF
            \ ." SDL_QUIT event " dup cr
            true to quit_flag
        THEN
        dup SDL_WINDOWEVENT = if
            game_event SDL_WindowEvent-event u8@ SDL_WINDOWEVENT_CLOSE = if
                true to quit_flag
            then
        then
        SDL_KEYDOWN = IF
            game_event SDL_KeyboardEvent-keysym SDL_Keysym-scancode s32@
            \ ." Key pressed " dup . cr
            \ do_keyd
            DUP SDL_SCANCODE_ESCAPE = IF
                true to quit_flag
            THEN
            DUP SDL_SCANCODE_SPACE = IF
                ." Pressed Space - Change colour" cr
                random-color
            THEN
            drop
            \ From slouken https://discourse.libsdl.org/t/scancode-vs-keycode/32860/5
            \ SDL scancodes are used for games that require position independent key input, e.g. an FPS that uses WASD 
            \ for movement should use scancodes because the position is  important (i.e. the key position shouldn’t 
            \ change on a French AZERTY keyboard, etc.) 
            \
            \ SDL keycodes are used for games that use symbolic key input, e.g.  ‘I’ for inventory, ‘B’ for bag, etc. 
            \ This is useful for MMOs and other games where the label on the key is important for understanding what 
            \ the action is. Typically shift or control modifiers on those keys do something related to the original 
            \ function and aren’t related to another letter that might be mapped there (e.g. Shift-B closes all 
            \ bags, etc.)
            \ 
            \ SDL text input is used for games that have a text field for chat, or character names, etc.
            \ 
            \ e.g. 
            \ game_event SDL_KeyboardEvent-keysym SDL_Keysym-sym s32@ SDLK_ESCAPE =
            \ game_event SDL_KeyboardEvent-keysym SDL_Keysym-scancode s32@ SDL_SCANCODE_ESCAPE =
        THEN
    REPEAT
;

: show_screen ( -- )
    renderer SDL_RenderPresent
;


\ clear the renderer
: clear-renderer ( -- )
    renderer SDL_RenderClear \ DROP
    if
        ." Error clearing renderer" cr
    THEN
;

0 value platform_frame_start_time
0 value platform_frame_delta_time

: platform-open ( name-addr name-len -- )
    initialize-sdl
    SDL_GetTicks64 to platform_frame_start_time
;

: platform-close
    game-cleanup
;

10000000 value min_frame_dt
-10000000 value max_frame_dt
create frame_stats 10 cells allot
0 value frame_stats_index

: store_min ( time -- ) min_frame_dt min to min_frame_dt ;
: store_max ( frame -- ) max_frame_dt max to max_frame_dt ;
: store_last_10 ( frame -- )
    frame_stats frame_stats_index cells + !
    frame_stats_index 1+ 10 mod to frame_stats_index
;
: store_stats ( frame -- )
    dup store_max
    dup store_min
        store_last_10
;

: .frame_stats
    cr ." Frame stats" cr
    ." Last 10: "
    10 0 do
        frame_stats i cells + @ . ." "
    loop
    ."  ms" cr
    ." Min frame time = " min_frame_dt . ." ms" cr
    ." Max frame time = " max_frame_dt . ." ms" cr
    ." Last = " platform_frame_delta_time . ." ms" cr
;

60 constant MAX_FRAMES_PER_SECOND
\ we don't care about this exactly for caves ... this will be 62.5 fps max
1000 MAX_FRAMES_PER_SECOND / constant MIN_FRAME_TIME

: frame-delay ( -- ) 
    \ could use SDL_RENDERER_PRESENTVSYNC, however let's do this this way
    SDL_GetTicks64 dup \ end time, and next start ( -- end_time end_time )
    platform_frame_start_time - \ time taken, elapsed time ( -- end-time time-taken )

    dup 0 max to platform_frame_delta_time  \ don't let it go negative ( -- end-time time-taken )
    swap to platform_frame_start_time   \ start time for next frame ( -- time-taken )

    MIN_FRAME_TIME min \ ( time taken -- time-to-delay )
    1 max   \ at least 1 ms, not negative ( time-to-delay -- time-to-delay )

    SDL_Delay

    platform_frame_delta_time store_stats
;

: get_dt ( -- u ) platform_frame_delta_time ;
