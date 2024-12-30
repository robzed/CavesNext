\ gForth loader
\ Copright (c) 2024 Rob Probin
\ Written 20 December 2024 by Rob Probin
\ GPLv3 license
\
\ Requires SDL libraries SDL2, SDL_image, SDL_mixer, and SDL_ttf
\ and https://github.com/ProgrammingRainbow/Beginners-Guide-to-SDL2-in-Gforth
\ Put the SDL folder inside this folder under the name SDL2. 
\ SDL2 bindings for Gforht are kindly Zlib licenses - so no worries.

include speccy_emu.fth

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

0 value textx
0 value texty
CREATE text_srcrect SDL_Rect ALLOT
CREATE text_destrect SDL_Rect ALLOT
NULL value font-tex
\ NULL value current_font_tex

: load-font
    renderer S\" ZX_Maverick/ZX_Maverick.png\x00" drop IMG_LoadTexture to font-tex
;

\ : set-font ( fontaddr -- )
\
\ ;

defer keystep

8 constant CHAR_WIDTH
8 constant CHAR_HEIGHT

: calc_destrect ( x y -- )
    \ set position of the text
    ( y ) CHAR_HEIGHT * 
        PIXEL_SCALE *
        text_destrect SDL_Rect-y u32!
    ( x ) CHAR_WIDTH *  
        PIXEL_SCALE *
        text_destrect SDL_Rect-x u32!
    CHAR_WIDTH  PIXEL_SCALE * text_destrect SDL_Rect-w u32!
    CHAR_HEIGHT PIXEL_SCALE * text_destrect SDL_Rect-h u32!
;

: calc_srcrect ( c -- )
    dup bl < if drop [char] ? then
    dup $80 >= if drop [char] ? then
    bl -    \ 32 is first printable character
    dup

        $1F and \ 32 characters per row
        8 *     \ 8 pixels per character
    text_srcrect SDL_Rect-x u32!

        5 >>    \ 32 characters per row
        8 *     \ 8 pixels per character
    text_srcrect SDL_Rect-y u32!

    CHAR_WIDTH  text_srcrect SDL_Rect-w u32!
    CHAR_HEIGHT text_srcrect SDL_Rect-h u32!
;

: .SDL_Rect ( addr -- )
    ." SDL_Rect: "
    dup SDL_Rect-x u32@ . ." x " 
    dup SDL_Rect-y u32@ . ." y " 
    dup SDL_Rect-w u32@ . ." w " 
        SDL_Rect-h u32@ . ." h "
;

: show_character ( x y c -- )
    calc_srcrect
    calc_destrect

    renderer font-tex text_srcrect text_destrect SDL_RenderCopy if
        ." Error rendering text: " SDL_GetError ctype cr
    then
;

24 constant NUM_LINES
32 constant NUM_COLUMNS

create text_buffer NUM_LINES NUM_COLUMNS * allot

: check_xy { x y caddr u -- }
    y 0< 
        y NUM_LINES >= or
            x 0< or
                x NUM_COLUMNS >= or
    if
        ." Out of range " textx . texty . cr
        caddr u type 
        ."  Return stack " r@ . cr
        .s abort
    then
;

: text_buf! ( c -- )
    textx texty S" text_buf!" check_xy
    text_buffer texty NUM_COLUMNS * + textx + c!
;

: clear_text_buf text_buffer NUM_LINES NUM_COLUMNS * bl fill ;

: text_buf@ { x y -- c }
    x y S" text_buf@" check_xy
    text_buffer y NUM_COLUMNS * + x + c@
;

: render_text_buf
    NUM_LINES 0 ?do
        NUM_COLUMNS 0 ?do
            i j 2dup
            text_buf@ ( x y x y -- x y c )
            dup bl <> if show_character else drop 2drop then
        loop
    loop
;

\ : scroll_y
\    NUM_LINES 1- 1 ?do
\        text_buffer i NUM_COLUMNS * + 
\        dup NUM_COLUMNS -
\        NUM_COLUMNS 
\        move ( src dest u -- )
\    loop
\    NUM_COLUMNS 0 text_buffer + NUM_COLUMNS
\    bl fill  ( addr u -- ) 
\ ;

: scroll? 
        texty NUM_LINES >= if
            ." scroll " cr
            \ NUM_LINES 1- to texty
            \ scroll_y
            0 to texty
            clear_text_buf
        then
;

: text_step_1
    textx 1+ to textx
    textx NUM_COLUMNS >= if
        ." new line " cr
               0 to textx
        texty 1+ to texty
        scroll?
    then
;
: at_xy { x y -- }
    x y S" at_xy" check_xy
    x textx !
    y texty !
;

: ~emit ( c -- )
    dup text_buf!
    emit
    text_step_1
;

: ~type ( c-addr u -- )
    0 ?do
        dup c@ ~emit
        1+
    loop
;

: (~")  ( -- , type following string )
        r> count 2dup + aligned >r ~type
;

: ~" ( <string> -- , type string )
        state @
        IF      compile (~")  ,"
        ELSE [char] " parse type
        THEN
; immediate


: ~cr
    0 to textx
    texty 1+ to texty
    scroll? 
    cr
;

: handle_keydown { scancode keycode -- }
    ." Keydown " scancode . keycode . cr
    scancode SDL_SCANCODE_ESCAPE = IF
        true to quit_flag
\        SDL_MESSAGEBOX_INFORMATION S\" Key Pressed\x00" S\" Key Pressed\x00" window SDL_ShowSimpleMessageBox drop
    THEN
;

variable loopc
0 value game_start_time

: close_down
    ." Exiting (loop count = " loopc @ . ." ) " cr
    ." Average frame time = " SDL_GetTicks64 game_start_time - loopc @ / . ." ms" cr
    .frame_stats

    font-tex SDL_DestroyTexture
    IMG_Quit
    platform-close

;

: ~key ( -- key | -1 for quit )
    render_text_buf
    show_screen
    clear-renderer
    begin
        do-event-loop
        \ could do special updates while waiting for key here
        \ if screen changed you will need show_screen
        frame-delay
        loopc @ 1+ loopc !
    key? quit_flag or until
    
    quit_flag if 
        \ bye = caves130_GUI.fth doesn't handle quit properly - so just abort
        close_down
        quit
        \ normally we shoudl return a sentinel value
        -1
    else 
        key
    then
;

: (keystep)
    ." [[[]]]   x y = " textx . texty .
    .s
    ~key drop
;

' (keystep) is keystep

: ~accept 
    accept

;

include caves130_GUI.fth

\ : game.update
\ ;

\ : game.draw
\    clear-screen
\ ;


\ why is this not in SDL2 from SDL_image.fs ??? 
#2	constant IMG_INIT_PNG

: run
    0 loopc !
    S" Caves" platform-open
    IMG_INIT_PNG IMG_Init 0= IF 
        ." Error initializing SDL_image: " SDL_GetError ctype cr
        exit
    THEN
    load-font

    false to quit_flag
    renderer 255 255 255 255 SDL_SetRenderDrawColor
    clear-renderer
    clear_text_buf
    SDL_GetTicks64 to game_start_time

\    begin
\        do-event-loop
\        game.update
\        game.draw
\        show_screen
\        
\        frame-delay
        \ ." Running " loopc @ . cr
\        loopc @ 1+ loopc !
\    key? quit_flag or until

    \ This does the whole game
    caves_main
    \ [char] A ~emit ~cr
    \ ~key .

    depth if ." ============ WARNING Stack not empty =========" cr then
    close_down
;

\ run

\ load with:
\ /Users/rob/Current_Projects/pForth/pforth_SDL/platforms/unix/pforth_standalone pForth_GUI_loader.fth
