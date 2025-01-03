\ gForth loader
\ Copright (c) 2024 Rob Probin
\ Written 20 December 2024 by Rob Probin
\ GPLv3 license
\
\ Requires SDL libraries SDL2, SDL_image, SDL_mixer, and SDL_ttf
\ and https://github.com/ProgrammingRainbow/Beginners-Guide-to-SDL2-in-Gforth
\ Put the SDL folder inside this folder under the name SDL2. 
\ SDL2 bindings for Gforht are kindly Zlib licenses - so no worries.

ANEW TASK-FORTH_GUI_LOADER.FTH

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

: load-font ( -- )
    renderer S\" ZX_Maverick/ZX_Maverick.png\x00" drop IMG_LoadTexture to font-tex
;

\ : set-font ( fontaddr -- )
\
\ ;

: .SDL_Rect ( addr -- )
    ." SDL_Rect: "
    dup SDL_Rect-x u32@ . ." x " 
    dup SDL_Rect-y u32@ . ." y " 
    dup SDL_Rect-w u32@ . ." w " 
        SDL_Rect-h u32@ . ." h "
;

\ List of graphics
0 constant border_whole

1 constant map_TL
2 constant map_TR
3 constant map_BL
4 constant map_BR

5 constant map_LS
6 constant map_RS
7 constant map_TS
8 constant map_BS

9 constant map_MID

map_MID 1+ constant number_of_graphics

number_of_graphics array gr_array

: load_graphics ( -- )
    renderer S\" Graphics/mmborder.png\x00" drop IMG_LoadTexture border_whole gr_array !

    renderer S\" Graphics/corner_es.png\x00" drop IMG_LoadTexture map_TL gr_array !
    renderer S\" Graphics/corner_sw.png\x00" drop IMG_LoadTexture map_TR gr_array !
    renderer S\" Graphics/corner_ne.png\x00" drop IMG_LoadTexture map_BL gr_array !
    renderer S\" Graphics/corner_nw.png\x00" drop IMG_LoadTexture map_BR gr_array !

    renderer S\" Graphics/side_nes.png\x00" drop IMG_LoadTexture map_LS gr_array !
    renderer S\" Graphics/side_nws.png\x00" drop IMG_LoadTexture map_RS gr_array !
    renderer S\" Graphics/side_esw.png\x00" drop IMG_LoadTexture map_TS gr_array !
    renderer S\" Graphics/side_new.png\x00" drop IMG_LoadTexture map_BS gr_array !

    renderer S\" Graphics/open4.png\x00" drop IMG_LoadTexture map_MID gr_array !
    number_of_graphics 0 ?do
        I gr_array 0= if ." Error loading graphics " I . cr then
    loop
;

: destroy_graphics ( -- )
    number_of_graphics 0 ?do
        I gr_array dup if SDL_DestroyTexture else drop then
    loop
;

: graphic.draw { x y gr -- }
    x PIXEL_SCALE * text_destrect SDL_Rect-x u32!
    y PIXEL_SCALE * text_destrect SDL_Rect-y u32!
    8 PIXEL_SCALE * text_destrect SDL_Rect-w u32!
    8 PIXEL_SCALE *  text_destrect SDL_Rect-h u32!

    renderer gr gr_array @ NULL text_destrect SDL_RenderCopy if
        ." Error rendering graphic: " SDL_GetError ctype cr
    then
;
: gr.fill { x y w h -- }
    x PIXEL_SCALE * text_destrect SDL_Rect-x u32!
    y PIXEL_SCALE * text_destrect SDL_Rect-y u32!
    w PIXEL_SCALE * text_destrect SDL_Rect-w u32!
    h PIXEL_SCALE * text_destrect SDL_Rect-h u32!
    renderer text_destrect SDL_RenderFillRect
;


: border.draw { x y gr -- }
    \ for border items it's a bit different
    \ calculate 
    gr 3 and 4 << text_srcrect SDL_Rect-x u32!
    gr $c and 2 << text_srcrect SDL_Rect-y u32!
    16 text_srcrect SDL_Rect-w u32!
    16 text_srcrect SDL_Rect-h u32!
    \ text_srcrect .SDL_Rect

    x PIXEL_SCALE * text_destrect SDL_Rect-x u32!
    y PIXEL_SCALE * text_destrect SDL_Rect-y u32!
    16 PIXEL_SCALE * text_destrect SDL_Rect-w u32!
    16 PIXEL_SCALE *  text_destrect SDL_Rect-h u32!
    \ text_destrect .SDL_Rect

    renderer border_whole gr_array @ text_srcrect text_destrect SDL_RenderCopy if
        ." Error rendering graphic: " SDL_GetError ctype cr
    then
;




defer keystep

8 constant CHAR_WIDTH
8 constant CHAR_HEIGHT
0 value pixel_y_offset

: calc_destrect ( x y -- )
    \ set position of the text
    ( y ) CHAR_HEIGHT * 
        pixel_y_offset +
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

: scroll_y
    text_buffer NUM_COLUMNS + 
    text_buffer
    NUM_LINES 1- NUM_COLUMNS *
        move ( src dest u -- )

    \ erase the last line
    NUM_COLUMNS NUM_LINES 1- * text_buffer +
    NUM_COLUMNS
    bl
    fill  ( addr u char -- ) 
;

variable loopc

defer render_graphics
: no_render_graphics 
    \ ." No render_graphics" cr
;

' no_render_graphics is render_graphics

: render_all
    render_graphics
    render_text_buf
    show_screen
    clear-renderer
;
: interframe
        do-event-loop
        \ could do special updates while waiting for key here
        \ if screen changed you will need show_screen
        frame-delay
        loopc @ 1+ loopc !
;
: make_picture
    render_all
    interframe
;

true value enable_scroll
true value enable_pixel_scroll

: scroll? 
        texty NUM_LINES >= if
            enable_scroll if
                enable_pixel_scroll if
                    CHAR_HEIGHT 0 ?do
                        I negate to pixel_y_offset
                        make_picture
                        10 SDL_Delay
                    loop
                    0 to pixel_y_offset
                then
                NUM_LINES 1- to texty
                scroll_y
                make_picture
                10 SDL_Delay
                \ ." Scroll?" key
            else
                0 to texty
                clear_text_buf
            then
        then
;

: text_wrap?
    textx NUM_COLUMNS >= if
        0 to textx
        texty 1+ to texty
        scroll?
    then
;
: at_xy { x y -- }
    x y S" at_xy" check_xy
    x to textx
    y to texty
;

false value print_to_terminal

: ~emit ( c -- )
    text_wrap?
    print_to_terminal if dup emit then

    text_buf!
    textx 1+ to textx
;

: ~type ( c-addr u -- )
    0 ?do
        dup c@ ~emit
        1+
    loop
    drop
;

: (~")  ( -- , type following string )
        r> count 2dup + aligned >r ~type
;

: ~" ( <string> -- , type string )
        state @
        IF      compile (~")  ,"
        ELSE [char] " parse ~type
        THEN
; immediate


: ~cr ( -- )
    print_to_terminal if cr then

    0 to textx
    texty 1+ to texty
    scroll? 
;

: ~space ( -- ) bl ~emit ;
: ~spaces ( n -- ) 0 ?do ~space loop ;

: (~.) ( n -- ) dup abs 0 <# #s rot sign #> ;
: ~. ( n -- ) (~.)  ~type ~space ;


\ : fifo_array  ( empty #cells -- ) ( -- addr )
\     create dup , swap , 0 , cell* allot
\    does> swap cell* +
\ ;

32 constant key_array_max_size
key_array_max_size array key_array
0 value key_array_current_size
: key_array_empty? ( -- flag ) key_array_current_size 0= ;
: key_array_keys? ( -- flag ) key_array_current_size 0<> ;
: key_array_full? ( -- flag ) key_array_current_size key_array_max_size = ;
: key_array_push ( n -- )
    key_array_full? 0= if
        key_array_current_size key_array !
        key_array_current_size 1+ to key_array_current_size
    else
        ." **** Key array full - drop key **** " cr
    then
;
: key_array_drop ( -- )
    key_array_current_size 1 ?do
        I key_array @ I 1- key_array !
    loop
;
: key_array_peek ( -- n )
        0 key_array @   \ oldest
;
: key_array_pop ( -- n )
    key_array_keys? if 
        key_array_peek
        key_array_drop
        key_array_current_size 1- to key_array_current_size
    else
        ." **** Key array empty **** " cr
        abort
    then
;

: fix_numeric_keys ( c -- c)
    dup SDLK_KP_1 = if drop SDLK_1 exit then
    dup SDLK_KP_2 = if drop SDLK_2 exit then
    dup SDLK_KP_3 = if drop SDLK_3 exit then
    dup SDLK_KP_4 = if drop SDLK_4 exit then
    dup SDLK_KP_5 = if drop SDLK_5 exit then
    dup SDLK_KP_6 = if drop SDLK_6 exit then
    dup SDLK_KP_7 = if drop SDLK_7 exit then
    dup SDLK_KP_8 = if drop SDLK_8 exit then
    dup SDLK_KP_9 = if drop SDLK_9 exit then
    dup SDLK_KP_0 = if drop SDLK_0 exit then
;

: handle_keydown { scancode keycode -- }
    \ ." Keydown " scancode . keycode . cr
    scancode SDL_SCANCODE_ESCAPE = IF
        true to quit_flag
\        SDL_MESSAGEBOX_INFORMATION S\" Key Pressed\x00" S\" Key Pressed\x00" window SDL_ShowSimpleMessageBox drop
    THEN
    scancode SDL_SCANCODE_SPACE = IF
        \ ." Pressed Space - Change colour" cr
        random-color
        clear-renderer
        render_all
    THEN
    keycode
    fix_numeric_keys
    key_array_push
;

0 value game_start_time

: close_down
    ." Exiting (loop count = " loopc @ . ." ) " cr
    ." Average frame time = " SDL_GetTicks64 game_start_time - loopc @ / . ." ms" cr
    .frame_stats

    font-tex SDL_DestroyTexture
    destroy_graphics
    IMG_Quit
    platform-close

;

: (~key)
        key_array_keys? if
            key_array_pop
        else
            key? if
                key
            else
                ." Abort - no key" cr
                abort
            then
        then
;

: depth_check ( -- )
    depth 0< if 
        ." STACK UNDERFLOW" cr
        ." DEPTH = " depth . cr 
        .s
        ." ---- QUIT --- " cr 
        quit
    then
;

: ~key ( -- key | -1 forquit )
    \ ." ~key " .s
    depth_check

    render_all
    begin
        interframe
    key? quit_flag or key_array_keys? or until

    quit_flag if 
        \ bye = caves130_GUI.fth doesn't handle quit properly - so just abort
        close_down
        quit
        \ normally we shoudl return a sentinel value
        -1
    else
        (~key)
    then
;

: ~key? ( -- flag)
    key_array_keys? key? or

    quit_flag if 
        \ bye = caves130_GUI.fth doesn't handle quit properly - so just abort
        close_down
        quit
    then
;

: timed_wait ( n -- )
    SDL_GetTicks64 + 
    begin
        interframe
        SDL_GetTicks64 over >=
            ~key? or
    until
    drop
;


: (keystep)
    ." [[[]]]   x y = " textx . texty .
    .s
    ~key drop
;

' (keystep) is keystep

\ ACCEPT a n1 --- n2
\ Transfers characters from the input terminal to the address a for n1 location or until receiving a 0x13 “CR”
\ character. A 0x00 “null” character is added. It leaves on TOS n2 as the actual length of the received string. More, n2 is
\ also copied in SPAN user variable. See also QUERY.

\ accept ( c-addr +n1 – +n2  ) core “accept”
\ 
\ Get a string of up to n1 characters from the user input device and store it at c-addr. n2 is the length of the 
\ received string. The user indicates the end by pressing RET. Gforth supports all the editing functions available on 
\ the Forth command line (including history and word completion) in accept. 

: step_back
    textx if
        textx 1- to textx
    else
        texty if
            texty 1- to texty
            NUM_COLUMNS 1- to textx
        then
    then
;

: ~accept { caddr n1 | numchars -- n2 }
    0 -> numchars
    begin
        ~key 
        n1 if \ only allow if n1 > 0
            dup bl >= 
                over 127 <
                    and if
                        dup ~emit
                        dup caddr ! 
                        1 +-> caddr
                        -1 +-> n1
                        1 +-> numchars
                    then
        then
        dup 13 = over 10 = or if
            drop numchars
            exit
        then
        dup 127 = over 8 = or if
            numchars if
                -1 +-> caddr
                1 +-> n1
                -1 +-> numchars
                step_back
                bl ~emit
                step_back
            then
        then
        \ ." Numchars = " numchars . ." n1 = " n1 . .s
        drop
    again
;

: clear_screen
    clear-renderer  \ not strictly necessary
    0 to textx
    0 to texty
    clear_text_buf
    ['] no_render_graphics is render_graphics
;

: set_drawcolour { r green b -- }
    renderer r green b 255 SDL_SetRenderDrawColor
    if ." Error SDL_SetRenderDrawColor" . cr then
    \ set border colour as well on Spectrum Next
;

include caves130_GUI.fth

\ : game.update
\ ;

\ : game.draw
\    clear-screen
\ ;


\ why is this not in SDL2 from SDL_image.fs ??? 
#2	constant IMG_INIT_PNG


CREATE clipRect SDL_Rect ALLOT
: clip_rect_check
    cr
    renderer SDL_RenderIsClipEnabled if ." Clip enabled" else ." Clip not enabled" then cr  
    renderer clipRect SDL_RenderGetClipRect
    ." Clip rect = " clipRect .SDL_Rect
    cr
;



: run
    0 loopc !
    S" Caves" platform-open
    IMG_INIT_PNG IMG_Init 0= IF 
        ." Error initializing SDL_image: " SDL_GetError ctype cr
        exit
    THEN
    load_graphics
    load-font
    false to quit_flag
    renderer 255 255 255 255 SDL_SetRenderDrawColor if
        ." Error SDL_SetRenderDrawColor" . cr
    then

    clear-renderer
    clear_screen
    \ clip_rect_check
    SDL_GetTicks64 to game_start_time
    ['] handle_keydown is do_keyd
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
    depth if ." ============ WARNING Stack not empty =========" cr .s then
    caves_main
    \ [char] A ~emit ~cr
    \ ~key .

    depth if ." ============ WARNING Stack not empty =========" cr .s then
    close_down
;

\ run

\ load with:
\ /Users/rob/Current_Projects/pForth/pforth_SDL/platforms/unix/pforth_standalone pForth_GUI_loader.fth
