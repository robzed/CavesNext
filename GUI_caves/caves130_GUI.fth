\ GUI Version Copright (c) 2024 Rob Probin
\ Written 27 December 2024 - 1 Jan 2025 by Rob Probin
\ GPLv3 license

\ * CAVES OF CHAOS [RELEASE VERSION]
\ * ===============\-----> A little RPG
\ *
\ *    by Rob. (ZED) Probin (c) Copyright 1990/91/92 - 2025
\ *
\ *    Converted to C on 5/7/92.
\ *    Original version in GFA Basic v2
\ *
\ *   v1.27 - MacOS X Port, 13/8/2001, Rob Probin. 
\ *   v1.28 - Bug fix 10-Nov-2003 by Rob/Stu. Destroyer casts mega death straight away. line 681
\ *           But maybe the Destroyer SHOULD case mega death straight away?
\ *           Has this bug always been in?
\ *   v1.29 - Rob Probin, ported to Lua 27 Feb 2019
\ *   v1.30 - Rob Probin, ported to vForth-Next 4 May 2024
\ *   v1.30G - Rob Probin, graphical version 27 December 2024, 1 Jan 2025
\
 
\ * NOTE ABOUT STRUCTURE
\ *
\ * This program has poor structuring. The reason for this lies in its
\ * BASIC origins, not because GFA Basic is unstructured (it can be VERY
\ * structured!) but because this was just a little mess around program
\ * that I was writing that seems to have expanded !!!
\ *
\ * In the C version I have attempted to add more structure to the program
\ * to allow easy examination of the program, but it is still far from
\ * perfect. Forth version is slightly better, but still not great.
\ *
\ * The moral of this story....
\ *
\ *        ALWAYS STRUCTURE PROGRAMS even if they are only a few lines
\ * long or you could regret it.....
\ *                                   ZED.
\ *

\ =====================================================================
\ License for Code - see file 'LICENSE' and README.md - summary: GPL v3
\ =====================================================================

0 value blue_text

\ *
\ * UTILITY FUNCTIONS
\ *
: input ( -- c )
    \ remove spaces and return the character pressed
    begin
        ~key dup
        bl <=
    while
        drop
    repeat
;

: invert-flag ( f -- f' ) 
    0= ;

\ : oneof ( addr u c -- flag )
\    \ check if c is in the string
\    swap
\    ?do 
\        over over c@ = if
\            2drop true leave
\        then
\    loop
\    2drop
\  ;


\ Constrained input - a single button press
: C-input ( compare-xt -- c )
        0 \ dummy previous key
        begin
            drop
            input upper
            over execute
        until
        nip
;


\ NOTE: my random (x_rand) used to be is included at the bottom of THIS source

\ random stuff */

variable x_seed
3456 x_seed !

\ Random Number Generator by Rob (ZED) Probin 4/7/92 */
\ using mod function sequence */
\
\ dice = number of options
\ n = options in range 0 to n-1
: x_rand ( dice -- n )

    \ x = 75*(x_seed+1);		\ basic random sequence */
    x_seed @ 75 um* 75 0 d+

    \ x = x % 65537;				\ then find remainder */
    \ 65537 mod
    over over u< - - 

    \ x_seed = x-1				\ next seed new random number*/
    1- dup x_seed !

    \ x = x * dice;			\ make sure in wanted dice range */
    \ x= x / 65536;				\ change to correct scale last*/
    \ return math.floor(x);
    um* swap drop
;


\ *
\ * MAIN PROGRAM BLOCK
\ *

10 constant height_y
10 constant width_x
6 constant #mon_spells

\ these are converted into cells to avoid underflow problem (c@ is uint8_t)
2 constant hp_slots     \ first byte is actual HPs, second is original hit points for gold reward
1 constant mons_id_slots

mons_id_slots cells hp_slots cells + constant _spell_offset

\ calculate how big record is
_spell_offset #mon_spells + constant sizeof_MapRec

\ in C code this was 'z' instead of map. But map is more descriptive here
create map width_x height_y * sizeof_MapRec * allot

\ we should have used some structure words rather than calculate it ourselves...

\ fetch the address of a room
: get_room_addr ( x y -- addr )
    1- width_x * 1- + sizeof_MapRec * map +
;

: mons@ ( x y -- n )
    get_room_addr @
;
: mons! ( n x y -- )
    get_room_addr !
;
: mons_HP@ ( x y -- n )
    get_room_addr CELL+ @
;
: mons_HP! ( n x y -- )
    get_room_addr CELL+ !
;
: mGold@ ( x y -- n )
    get_room_addr 2 CELLS + @
;
: mGold! ( n x y -- )
    get_room_addr 2 CELLS + !
;

\ get the address of the byte storing the spell
: mSPELLaddr ( sp x y -- addr-of-spell )
    get_room_addr 
    \ check spell number in range first
    over 1 < if ." mspell<1 " bye then
    over 6 > if ." mspell>6 " bye then
    1- +
    _spell_offset +
;

\ sp = 1-6 ... notice: '2 +' is actually '3 + 1-'
: mSPELL@ ( sp x y -- n )
    mSPELLaddr c@
;
: mSPELL! ( n sp x y -- )
    mSPELLaddr c!
;
: mSPELL1- ( sp x y -- )
        mSPELLaddr dup 
        c@ 1- 
        swap c!
;


\ *
\ * - Screen start section -
\ *


: center_text { caddr u -- }
    NUM_COLUMNS u - 2/ 0 max ~spaces
    caddr u ~type
;

\ Probably should be from current x position...
: right_adjust { caddr u -- }
    NUM_COLUMNS u - 0 max ~spaces
    caddr u ~type
;
: key_wait ( n -- )
    timed_wait ~key? if ~key drop then
;

: instructions
    192 192 128 set_drawcolour

    clear_screen
    S" - Instructions -" center_text ~cr
    ~cr
    ~" You are in a dungeon" ~cr
    S" called the Caves of Chaos;" center_text ~cr
    S" a dangerous place."  right_adjust ~cr
    ~cr
    1000 key_wait
    S" It's a 10 by 10 set of rooms" center_text ~cr
    ~cr
    1000 key_wait
    ~" Defeat all the monsters " ~cr
    S" in the caves to win." right_adjust ~cr
    ~cr
    1000 key_wait
    S" You can move " center_text ~cr
    S" North, South, East or West " center_text ~cr
    S" after defeating a monster." center_text ~cr
    ~cr
\               11111111112222222222333
\      12345678901234567890123456789012
    \ ~" You can heal yourself," ~cr
    \ S" but it costs 10 gold." right_adjust ~cr

    1000 key_wait
    ~" Health is more useful than gold." ~cr
    ~cr

    1000 key_wait
    S" Use your spells carefully." center_text ~cr
    ~cr

    1000 key_wait
    ~" Tackle monsters in the right" ~cr
    S" order to win all fights." right_adjust ~cr
    ~cr ~cr

    1000 key_wait
    begin
        make_picture
        0 23 at_xy
        flash if
            S" (press a key to continue)" center_text
        else
            NUM_COLUMNS ~spaces
        then
        ~key?
    until
    ~key drop
    drop
;

300 value wait_cr_time

: wait_cr ( -- flag )
    ~cr
    make_picture
    wait_cr_time timed_wait
    ~key? dup if ~key drop then
;

: credits_scroller ( -- )
    96 192 192 set_drawcolour
    clear_screen
    100 to wait_cr_time

    0 NUM_LINES 1- at_xy
    ~" Caves Of Chaos" ~cr wait_cr if exit then
    ~"    A little Fantasy RPG"  wait_cr if exit then
    S" ... or something like that!!!" right_adjust ~cr wait_cr if exit then
    S" (v1.30G)" right_adjust wait_cr if exit then
                             wait_cr if exit then
\               11111111112222222222333
\      12345678901234567890123456789012
    ~" Copyright 1990-2025 Rob Probin" wait_cr if exit then
    S" (The road goes on forever....)" right_adjust wait_cr if exit then
                                    wait_cr if exit then
    ~" CONTACT: rob http://??????" wait_cr if exit then
    wait_cr if exit then
    wait_cr if exit then
                               wait_cr if exit then
    ~" Written and design by"  wait_cr if exit then
                               wait_cr if exit then
    ~"     Rob Probin"         wait_cr if exit then
    wait_cr if exit then
    wait_cr if exit then

    10 to wait_cr_time
\               11111111112222222222333
\      12345678901234567890123456789012
    ~" Thanks to: "            wait_cr if exit then
    ~"     Stu, and the rest of the" wait_cr if exit then
    S" gang." right_adjust wait_cr if exit then
    ~cr
    ~" Fonts - ZX Origins from" wait_cr if exit then
    S" https://damieng.com/typography/" right_adjust wait_cr if exit then
                            wait_cr if exit then
                            wait_cr if exit then

    ~" History:"  wait_cr if exit then
                 wait_cr if exit then
\               11111111112222222222333
\      12345678901234567890123456789012
    ~" Original written in GFA Basic V2"  wait_cr if exit then
    S" on an Atari ST in 1990" right_adjust wait_cr if exit then
                                        wait_cr if exit then
    ~" Original version in C (7/5/92 &" wait_cr if exit then
    S" 12/2/93-Release modification)" right_adjust wait_cr if exit then
                                    wait_cr if exit then
    ~" Mac OS X version 13th Aug 2001" wait_cr if exit then
                                    wait_cr if exit then
    ~" Lua version 27th Feb 2019." wait_cr if exit then
    S" (Forlorn Fox Easter Egg)" right_adjust wait_cr if exit then
                                    wait_cr if exit then
    ~" C99 port - 4 May 2024"            wait_cr if exit then
                                    wait_cr if exit then
    ~" Forth port May to August 2024"  wait_cr if exit then
                                    wait_cr if exit then
    S" (to be vForth Next version)"  right_adjust wait_cr if exit then  
                                          wait_cr if exit then
    ~" pForth GUI version December 2024" wait_cr if exit then
    S" to January 2025" right_adjust wait_cr if exit then
    
    NUM_LINES 1- 0 ?do
        wait_cr if unloop exit then
    loop
;

: mmborder
        0 0 0 border.draw
        NUM_COLUMNS 4 - 4 / 0 ?do
            16 i 5 << + 0 1 border.draw
            32 i 5 << + 0 2 border.draw
            16 i 5 << + 192 16 - 13 border.draw
            32 i 5 << + 192 16 - 14 border.draw
        loop
        256 16 - 0 3 border.draw
        NUM_LINES 4 - 4 / 0 ?do
            0 16 i 5 << + 4 border.draw
            255 16 - 16 i 5 << + 7 border.draw
            0 32 i 5 << + 8 border.draw
            255 16 - 32 i 5 << + 11 border.draw
        loop
        0 192 16 - 12 border.draw
        255 16 - 192 16 - 15 border.draw
;


: main_menu ( -- )
    begin
        191 170 100 set_drawcolour
        clear_screen
        ['] mmborder is render_graphics

        0 3 at_xy 
        S" Caves Of Chaos" center_text ~cr
        ~cr
        S"    A little Fantasy RPG" center_text ~cr
        ~cr ~cr ~cr 
        S" 1 - Play game" center_text ~cr ~cr
        S" 2 - Credits" center_text ~cr ~cr
        S" 3 - Game Hints" center_text ~cr ~cr
        0 NUM_LINES 3 - at_xy 
        S\" \x7F 1990-2025 Rob Probin" center_text ~cr

        ~key
        dup [char] 2 = if
            credits_scroller
        then
        dup [char] 3 = if
            instructions
        then

        [char] 1 =
    until    
;



\ - Room occupation by monsters - */
\ Notice:
\  * the monster numbers are 1-25, not 0-24 - we fix this in the code
\  * inside each line is increasing x, and each line is increasing y
\  * the player starts at x,y=(1,10) - which is the bottom left here.
create source_map_data
            11 c, 11 c, 17 c, 12 c, 12 c,  9 c, 16 c, 22 c, 10 c, 20 c,
            14 c, 11 c, 11 c, 17 c, 12 c, 12 c,  9 c, 15 c, 22 c, 10 c,
            14 c, 14 c, 11 c, 11 c, 12 c, 12 c,  9 c, 16 c, 15 c, 15 c,
            14 c, 14 c, 21 c, 05 c, 05 c, 12 c,  9 c,  9 c, 16 c, 16 c,
            07 c, 25 c, 05 c, 05 c, 05 c, 13 c,  9 c, 19 c,  9 c,  9 c,

            18 c, 25 c, 05 c, 21 c, 05 c, 13 c, 13 c, 13 c, 17 c, 17 c,
            21 c, 05 c, 05 c, 05 c, 05 c, 23 c, 23 c, 23 c, 25 c, 07 c,
            03 c, 03 c, 05 c,  8 c,  8 c, 18 c, 24 c, 24 c, 25 c, 25 c,
            02 c, 04 c, 06 c, 05 c,  8 c,  8 c, 24 c, 07 c, 25 c, 19 c,
            01 c, 06 c, 04 c, 04 c,  8 c, 18 c, 07 c, 25 c, 23 c,  9 c, 


\
\   - Map set up routine -
\

255 constant NOT_LOADED

\ set up all the monsters in the rooms    
: setmap ( -- )
        
    \ get the address of the monster numbers
    source_map_data

    \ loop around all rooms
    height_y 1+ 1 do
        width_x 1+ 1 do
            \ i = x, j = y

            \ get the source map data
            dup c@

            \ if monster number=0 error
            dup 0= if
                ." ERROR 1 - MONSTER DATA IN ERROR" cr
                bye
            then

            \ we make the monster numbers zero indexed 
            1-  

            \ now store monster number
            i j mons!

\           \  -1 for monster hit points, mark player has not been in room
            NOT_LOADED i j mons_HP!

            \ next room
            1+
        loop
    loop
    drop
;


\ - Monster data -
create monname ," Kobold" ," Light Bulb" ," Giant Fly" ," Slime" ," Super Rat"
               ," Skeleton" ," Vampire" ," Purple Worm" ," Demon" ," Dragon" 
               ," Orc" ," Bear" ," Gargoyle" ," Elf" ," Giant Scorpion" 
               ," Troll" ," Giant Snake" ," Wolf" ," Bat" ," Destroyer" 
               ," Zombie" ," Hill Giant" ," Werewolf" ," Ogre" ," Goblin"
               \ end of list
               ," "

\ gforth pads space chars until align wiht uint64_t
\ vforth pads 0 terminator ;
: fix_padding ( caddr u ) 7 + 7 invert and ;
\ : fix_padding swap 1+ swap ;
\ maybe it would be better to create a list of addresses?

: get_monster_name ( n -- c-addr u )
    monname count \ ( addr length )
    rot 0 ?do
        +   \ next name address
        fix_padding
        count  \ ( addr length )
        dup 0= if
            drop
            ." ERROR 2 - END OF NAME STRING REACHED" cr
            quit
        then
    loop
;


\ debug command to show the room data
\ should be called sometime after setup
: .room_xy ( x y -- )
    2dup mons@ .
    2dup mons@ get_monster_name type
    2dup mons_HP@ NOT_LOADED <> if
        ."  hp="
        2dup mons_HP@ .
        2dup mGold@ .
        ." g {"
        2dup 1 -rot mSPELL@ .
        2dup 2 -rot mSPELL@ .
        2dup 3 -rot mSPELL@ .
        2dup 4 -rot mSPELL@ .
        2dup 5 -rot mSPELL@ .
        2dup 6 -rot mSPELL@ .
        ." }"
    else
        ."  (not loaded)"
    then

    2drop
;


\ debug command to show the map
\ should be called sometime after setmap
: debug.map
    cr
    height_y 1+ 1 do
        width_x 1+ 1 do
            ." (" i . ." ," j . ." ) = "
            i j .room_xy cr
        loop
    loop
;

0 value mapx_offfset
0 value mapy_offfset

: cell.draw { x y gr -- }
    \ x 1+ 3 << y 1+ 3 << 8 8 gr graphic.draw
    x y gr char.draw 
;

: .grid ( -- )
    \ top line
    0 0 corner_dot cell.draw
    width_x 1+ 1 do
        i 0 top_line cell.draw
    loop

    \ middle section
    height_y 1 do
        0 i side_line cell.draw
        width_x 1 do
            i j open_bot_left cell.draw
        loop
        width_x i open_bot cell.draw
    loop

    \ bottom line
    0 height_y side_line cell.draw
    height_y 1 do
        i height_y open_left cell.draw
    loop
    width_x height_y close_bot_left cell.draw
;




\ hit point and 6 spells for each monster.
create mondata 
           1 c,  0 c,  0 c,  0 c,  0 c,  0 c, 0 c,    2 c,  2 c, 0 c, 0 c, 0 c, 0 c, 0 c,
		   3 c,  0 c,  0 c,  0 c,  0 c,  0 c, 0 c,    4 c,  0 c, 0 c, 0 c, 0 c, 0 c, 0 c,
		  23 c,  0 c,  0 c,  0 c,  0 c,  0 c, 0 c,    2 c,  0 c, 0 c, 0 c, 0 c, 0 c, 0 c,
		  20 c,  0 c,  0 c,  0 c,  2 c,  0 c, 0 c,    5 c,  0 c, 0 c, 0 c, 0 c, 0 c, 0 c,
		  50 c, 20 c,  1 c,  0 c,  0 c,  0 c, 0 c,  150 c, 10 c, 5 c, 0 c, 0 c, 0 c, 0 c,
		  25 c,  0 c,  0 c,  0 c,  0 c,  0 c, 0 c,	 30 c,  0 c, 0 c, 0 c, 0 c, 0 c, 0 c,
		  57 c,  0 c,  0 c,  0 c,  0 c,  0 c, 0 c,
		   9 c,  0 c,  5 c,  0 c,  0 c,  0 c, 0 c,   90 c, 10 c, 0 c, 0 c, 0 c, 0 c, 0 c,
		 120 c,  0 c,  0 c,  8 c,  0 c,  2 c, 0 c,	 26 c,  0 c, 0 c, 0 c, 0 c, 0 c, 0 c,
		  10 c,  0 c,  0 c,  0 c,  0 c,  0 c, 0 c,    8 c,  0 c, 0 c, 0 c, 0 c, 0 c, 0 c,
		 200 c, 20 c, 10 c, 10 c, 10 c, 20 c, 2 c,   10 c,  0 c, 0 c, 0 c, 0 c, 0 c, 0 c,
         135 c,  0 c,  0 c,  0 c,  0 c,  2 c, 0 c,	 35 c,  0 c, 0 c, 2 c, 0 c, 0 c, 0 c,
		  18 c,  0 c,  0 c,  0 c,  0 c,  6 c, 0 c,	 15 c,  0 c, 0 c, 0 c, 0 c, 0 c, 0 c,

7  constant mdatasz


\
\ End of room data with monsters inside
\

\ most of these are player or general game data
5 constant #pspells
create spells ( player_spells ) #pspells allot
variable m/lvl   \ number of monster killed this level
variable x       \ players X position (1 to 10)
variable y       \ players Y position (1 to 10)
variable oldx    \ players old X
variable oldy    \ players old Y - where to run to
variable level   \ players level that can be drained
variable true_level \ players True Level
variable #mons       \ current number of monsters
variable hp     \ players hit points
variable gold   \ players Gold
variable multi  \ Multiple fight off
variable hit_strength \ players hit strength
variable mon_hit_strength \ monster hit strength


\
\ These fetch/store the current monster's data 
\
: .mons.name ( -- )
    x @ y @ mons@ get_monster_name ~type
;
: mons.hp ( -- n )
    x @ y @ mons_HP@
;
: mons.hp! ( n -- )
    x @ y @ mons_HP!
;

: mons.gold ( -- n )
    x @ y @ mGold@
;
: mons.gold! ( n -- )
    x @ y @ mGold!
;


\
\ These fetch/store the players spells
\
: spell@ ( n -- )
    1- spells + c@
;
: spell! ( value n -- )
    1- spells + c!
;


\ debug command to show player data
: .player
    cr
    ." Player Stats" cr
    ." ============" cr
    ." spells{"
    #pspells 0 do
        spells I + c@ .
    loop
    ." } " cr
    ." m@l=" m/lvl @ .
    ." (" x @ . ." ," y @ . ." ) "
    ." old(" oldx @ . ." ," oldy @ . ." )" cr
    ." lvl=" level @ . 
    ." true=" true_level @ . 
    ." #mons=" #mons @ . cr
    ." hp=" hp @ . 
    gold @ . ." g" cr
    ." multi=" multi @ . 
    ." hitstr" hit_strength @ . ." mhs" mon_hit_strength @ . cr
    ." ------------" cr
;
\ Example:
\ game_data_setup .player


: room_bg_colour
    192 192 128 set_drawcolour
;

: .monshow ( x y -- )
    2dup mons_HP@ NOT_LOADED = if
        [char] * show_character
        exit
    then
    2dup mons_HP@ 0 > if
        2dup mons@ get_monster_name drop c@
        show_character
    else
        2drop
    then
;

: .monlet ( x y -- )
    \ at player position, always show the monster
    y @ = swap x @ = and if
        ." current "
        .monshow
    else
        mons.hp 0 <= if	
            .monshow
        else
            [char] . show_character
            ." not dead, not current " cr
        then
    then
;

: .map_mons ( -- )
    blue_text set-font
    height_y 1+ 1 ?do
        width_x 1+ 1 ?do
            i j .monshow
        loop
    loop
    default_font
;


: .maphighlight
    flash if 192 192 192 else 64 0 0 then set_drawcolour

    x @ y @ char.fill

    \ x @ CHAR_WIDTH * 
    \ y @ CHAR_HEIGHT *
    \ CHAR_WIDTH CHAR_HEIGHT 
    \ gr.fill

    room_bg_colour
;

: .map ( -- )

    -4 to pixel_x_offset
    -4 to pixel_y_offset

    \ Add highlight
    .maphighlight

    \ Add grid for map
    .grid

    \ Add monsters
    .map_mons

    0 to pixel_x_offset
    0 to pixel_y_offset

;

: .playerinfo
    cursor_pos  \ save cursor pos

    11 1 at_xy ~" HP: " hp @ ~. 
    11 2 at_xy ~" Gold: " gold @ ~.
    11 3 at_xy ~" Level: " level @ ~.
    11 4 at_xy ~" Str: " hit_strength @ ~.

    \ restore cursor pos
    at_xy
;

: .view ( -- )
    .map
    .playerinfo
;

\ debug command to show the current room the player is in
: .room ( -- )
    x @ y @ .room_xy
;

: .spell_name ( n -- )
    dup 1 = if ~" an Ice Dart" then
    dup 2 = if ~" a Fireball" then
    dup 3 = if ~" Regenerate" then
    dup 4 = if ~" Drain Level" then
    dup 5 = if ~" Gain Strength" then
    dup 6 = if ~" MEGA DEATH" then
    drop
;

\ debug command to show the current monster in the room the player is in
: .monster ( -- )
    ." Monster: " .mons.name cr
    ."   HP: " mons.hp . cr
    ."   Gold: " mons.gold . cr
    ."   Spells:" cr
    6 1 do
        10 spaces I .spell_name ." ? = " I x @ y @ mSPELL@ . cr
    loop
;


\
\ Get room and monster data for this room -
\
\ This function basically populates the hit point data and the spell
\ data is the player hasn't been into that room before.

: load_mon { rx ry -- }
    rx ry mons_HP@ NOT_LOADED = if	     \ if first time player been in this room
        rx ry mons@       \ get the monster in this room
        dup 0 < if
            ." ERROR - monster not set" . ~cr
            bye
        then
        mdatasz * mondata +
        \ quick sanity check hit point is not zero
        dup c@ 0 = if
            ." ERROR 3 - monster data broken" ~cr
            bye
        then
        dup c@ rx ry mons_HP!          \ hit points from monster list
        dup c@ rx ry mGold!        \ store original hit points in gold as well
        1+ dup c@ 1 rx ry mSPELL!  \ get monster spells and put in store
        1+ dup c@ 2 rx ry mSPELL!
        1+ dup c@ 3 rx ry mSPELL!
        1+ dup c@ 4 rx ry mSPELL!
        1+ dup c@ 5 rx ry mSPELL!
        1+ dup c@ 6 rx ry mSPELL!
        drop
    then
;

\ go into the room, mostly load the monster data
: goroom x @ y @ load_mon ;

: load_monX { rx ry -- }
    rx 1 < if exit then
    ry 1 < if exit then
    rx width_x > if exit then
    ry height_y > if exit then

    rx ry load_mon
;

: load_adjacent ( -- )
    x @ 1+ y @    load_monX
    x @    y @ 1+ load_monX
    x @ 1- y @    load_monX
    x @    y @ 1- load_monX
;

\ Notice: destroys x and y for player - only for debug
: DEBUG_ld_rooms ( -- )
    height_y 1+ 1 do
        width_x 1+ 1 do
            i x ! j y !
            goroom
        loop
    loop
    ." Player Location " x @ . ." ," y @ . cr
    ." room "
;
\ Example:
\ setmap DEBUG_ld_rooms debug.map


\ 
\       - Room intro text -
\ 
: rmintro ( -- )
    \ ~cr
    \ ~" You have " hp @ ~. ~" hit points and " gold @ ~. ~" gold" ~cr
    \ multi @ 0= if ~" You are Level " level @ ~. ~cr then
    ~" Here is a monster with " mons.hp ~. ~" hit points called a " .mons.name ~cr
;


: YN_char ( c -- c flag )
    dup [CHAR] Y = 
    over [CHAR] N = or
;

\ game states
0 constant G_continue
1 constant G_goto_start
2 constant G_stop
3 constant G_reread_room
4 constant G_same_room


\
\      - Player Death text -
\
\ Returns status: 0=continue 1=goto start 2=stop
: pdeath? ( -- game-state )

    hp @ 1 < level @ 0= or if
      
        ~" You have died" ~cr
        ~" You had " gold @ ~. ~" gold when you died" ~cr
        ~" Press Y to play again, or type N to stop." ~cr
        ~" ? "

        ['] YN_char C-input
        [CHAR] Y = if
            ~" Yes please !!!" ~cr ~cr
            G_goto_start
        else
            ~" No, not again" ~cr ~cr
            G_stop
        then
    else
        G_continue
    then
;



\ 
\      - Monster Death text -
\ 

: mondeath ( -- ) 
  ~" The " .mons.name ~"  is Dead" ~cr
  ~" You find " mons.gold ~. ~" Gold" ~cr ~cr
  load_adjacent
  gold @ mons.gold + gold !
  0 mons.hp!
  0 mons.gold!
;

: num_char ( c -- c flag )
    dup [CHAR] 0 >= 
    over [CHAR] 9 <= and
;

\ Adjust the character string at c-addr1 by n characters. The resulting character string, specified 
\ by c-addr2 u2, begins at c-addr1 plus n characters and is u1 minus n characters long. 
\ n is the number of characters to take from the start
: /string ( c-addr1 u1 n -- c-addr2 u2 ) tuck - >r chars + r>  ;

\ trim leading spaces (and control characters)
: ltrim ( c-addr1 u1 -- c-addr2 u2 )
    begin
        dup 0> while                \ While there are characters left
        over c@ bl > if exit then  \ Check if the current character is a space
        1 /string           \ Move the string pointer forward by one character
    repeat
;

\ returns number if no error, or just true if error
: >uint ( c-addr u -- [n false] | true )
    ltrim
    dup 0= if 2drop true exit then
    0 -rot \ this is the temporary value
    over + swap ( 0 caddr1 u -- 0 caddr2 caddr1 )
    ?do
        I c@ num_char if 
            [CHAR] 0 - swap 10 * +
        else
            2drop true unloop exit
        then
    loop
    false
;

10 constant nbuff-size
create nbuff nbuff-size 1+ allot

: innum ( -- n )
    begin
        nbuff nbuff-size ~accept ( c-addr n -- n2 )
        \ dup . dup nbuff swap ." ->" type ." <- " cr
        nbuff swap >uint ( c-addr n -- number error-flag )
    while 
        ~cr ~" That's not a number!"
        ~cr ~" Please enter a number: "
    repeat
;

: CH_char ( c -- c flag )
    dup [CHAR] C = 
    over [CHAR] H = or
;

\ in_range
\ checks if value n is inside or equal to min and max
\ returns true if it is
\ false if it's outside the range
\ it's undefined what happens if min > max
: in_range ( n min max -- flag )
    rot dup ( min max n n )
    rot     ( min n n max )
    <= -rot  ( flag min n )
    <= and
;

\ 
\         - Heal Routine -
\ 
: heal ( -- )

    ~" Do you wish to Heal(Type H) or continue(Type C)" ~cr ~cr
    ~" ? "

    ['] CH_char C-input

    [CHAR] H = if

        clear_text_buf
        0 11 at_xy

        ~" Heal" ~cr ~" Healing: (10 gold = 1 hp)"

        0 \ dummy value to be dropped first time
        begin
            drop
            ~cr ~" Enter Hit points to be healed: "

            innum

            \ can't be greater than player gold, or less than 0
            dup 10 *    \ make it into gold
            0 gold @ in_range false = if 
                ~cr 
                ~" Not Enough Money!!" ~cr
                ~" Type 0 (zero) not to heal" ~cr
                drop -1
            then
        dup 0 >=
        until

        gold @ over 10 * - gold !

        hp @ swap + hp !

    \ else ~" Continue" ~cr then
    then
;





\ 
\         - New level -
\ 
: newlvl ( -- )
    m/lvl @ 10 = if
        clear_text_buf
        0 11 at_xy
        ~" You Gain a level!!!" ~cr
        ~cr ~"           YOU COCKY BLEEDER" ~cr 	\ Pauls sentence!!
        ~" You gain 10 hp" ~cr
        ~" You gain 5 spells!" ~cr ~cr
        #pspells 1+ 1 do
            I spell@ 1+ I spell!     \ BASIC version had random selection of 5 spells
        loop
        level @ 1+ level !
        true_level @ 1+ true_level !
        hp @ 10 + hp !
        0 m/lvl !

        ~" Press a key to continue" ~cr
        ~key drop
    then
;

: move_char ( c -- c flag )
    dup [char] N = if true exit then 
    dup [char] S = if true exit then 
    dup [char] E = if true exit then 
    dup [char] W = if true exit then 
    dup [char] Q = if true exit then 
    dup [char] M = if true exit then 
    false
;


\ 
\       Player move around
\ 
: pmove ( -- )

    clear_text_buf
    0 11 at_xy

    ~" You may go" ~cr

    x @ 1 <> if ~"   West (Type W) or " ~cr then
    x @ width_x <> if ~"   East (Type E) or " ~cr then
    y @ height_y <> if ~"   South (Type S) or " ~cr then
    y @ 1 <> if ~"   North (Type N) or" ~cr then
    ~"   Wait (Type Q)" ~cr

    level @ 3 > if 
        ~"  or Check the number of Monsters (Type M)." ~cr 
    then
    ~cr ~" Direction >"

    ['] move_char C-input

    \ record the old position before moving
    x @ oldx !
    y @ oldy !

    \ try to move
    dup [char] N = if
        ~cr ~cr
        y @ 1 > if
            ~" You head North"
            y @ 1- y !
        else
            ~" You can't go North, there is a wall."
        then
    then

    dup [char] S = if
        ~cr ~cr
        y @ height_y < if
            ~" You head South"
            y @ 1+ y !
        else
            ~" You can't go South, there is a wall."
        then
    then

    dup [char] W = if
        ~cr ~cr
        x @ 1 > if
            ~" You head West"
            x @ 1- x !
        else
            ~" You can't go West, there is a wall."
        then
    then

    dup [char] E = if
        ~cr ~cr
        x @ width_x < if
            ~" You head East"
            x @ 1+ x !
        else
            ~" You can't go East, there is a wall."
        then
    then

    dup [char] Q = if
        ~cr ~cr
        ~" You stay where you are"
    then

    dup [char] M = level @ 3 > and if
        ~cr ~cr
        ~" There are " #mons @ ~. ~" monsters"
    then
    drop
    ~cr ~cr
    \ player moved, re-read room
;



: foptions_char ( c -- c flag )
    dup [char] R = 
    over [char] F = or
    over [char] S = or
    over [char] M = or
;

\ - Player fight options - 
: foptions ( -- c )
    ~cr
    ~" Type R to run, F to fight once, M to fight many times or" ~cr
    ~" S to Cast Spell" ~cr
    ~" What do you wish to do? "

    ['] foptions_char C-input
;


\ - Cast option -
: _valid_spell ( n -- flag )
    dup 1 < if drop false exit then
    dup 6 > if drop false exit then
    dup 6 = if drop true exit then  \ this is no spell type
    dup spell@ 0 = if drop false exit then
    drop true
;

: in_digit ( -- n)
    begin
        ~key [char] 0 -
        dup 0 >= over 9 <= and
    until
;

: do_cast ( -- )
    ~"  Cast spell" ~cr ~cr
    1 spell@ if ~" Type 1 to cast " 1 .spell_name ~"  (" 1 spell@ ~. ~" left)" ~cr then
    2 spell@ if ~" Type 2 to cast " 2 .spell_name ~"  (" 2 spell@ ~. ~" left)" ~cr then
    3 spell@ if ~" Type 3 to cast " 3 .spell_name ~"  (" 3 spell@ ~. ~" left)" ~cr then
    4 spell@ if ~" Type 4 to cast " 4 .spell_name ~"  (" 4 spell@ ~. ~" left)" ~cr then
    5 spell@ if ~" Type 5 to cast " 5 .spell_name ~"  (" 5 spell@ ~. ~" left)" ~cr then
    ~" Type 6 to not cast a spell" ~cr

    begin
        ~cr ~" Which Magic Spell? "
        in_digit
        dup _valid_spell invert-flag
     while
        drop
    repeat


    \ actual spell activation

    dup 1 = if
        mons.hp 1- mons.hp!
        ~cr ~" You cast " 1 .spell_name ~cr
        1 spell@ 1- 1 spell!
    then
    dup 2 = if
        mons.hp 10 - mons.hp!
        ~cr ~" You cast " 2 .spell_name ~cr
        2 spell@ 1- 2 spell!
    then
    dup 3 = if
        hp @ 10 + hp !
        ~cr ~" You cast " 3 .spell_name ~cr
        ~" You fell stronger" ~cr
        3 spell@ 1- 3 spell!
    then
    dup 4 = if
        hp @ 20 + hp !
        ~cr ~" You cast " 4 .spell_name ~cr
        4 spell@ 1- 4 spell!
    then
    dup 5 = if
        hit_strength @ 1+ hit_strength !
        ~cr ~" You cast "  5 .spell_name ~cr
        5 spell@ 1- 5 spell!
    then
    drop
;

\ - Monster cast -
: moncast ( -- )
    #mon_spells x_rand 1+ ( spell_1_to_6 )
    dup x @ y @ mSPELL@ 0= if drop exit then
    dup x @ y @ mSPELL1-

    dup 1 = if
      ~cr ~" The " .mons.name ~"  casts "  1 .spell_name ~cr
      hp @ 1- hp !
    then
    dup 2 = if 
      ~cr ~" The " .mons.name ~"  casts "  2 .spell_name ~cr
      hp @ 10 - hp !
    then
    dup 3 = if
      ~cr ~" The " .mons.name ~"  casts "  3 .spell_name ~cr
      mons.hp 10 + mons.hp!
    then
    dup 4 = if
      ~cr ~" The " .mons.name ~"  casts "  4 .spell_name ~cr
      hp @ 10 - hp !
      level @ 1 - level !
    then
    dup 5 = if
      ~cr ~" The " .mons.name ~"  casts "  5 .spell_name ~cr
      mon_hit_strength @ 1+ mon_hit_strength !
    then
    dup 6 = if          \ bug fix 10-Nov-2003 by Rob, spotted by Stu :-(
      ~cr ~" The " .mons.name ~"  casts "  6 .spell_name ~cr 
      ~" Oh S**t!!!" ~cr
      hp @ 50 - hp !
    then
    drop
;



\ - General fight -
: fighting ( -- )

    ~cr
    20 x_rand 9 - mon_hit_strength @ 5 * - hit_strength @ 5 * +
    ( result of fight ... then we balance against points )
    mons.hp + hp @ > if
      
      hp @ mon_hit_strength @ - hp !
      ~" The " .mons.name ~"  hits you for " mon_hit_strength @ ~. 
      
    else
      
      mons.hp hit_strength @ - mons.hp!
      ~" You hit the " .mons.name ~"  for " hit_strength @ ~.
    then

    mons.hp 1 < if
      
      #mons @ 1- #mons !
      m/lvl @ 1+ m/lvl !
      0 mons.hp!
    then

    ~cr ~cr 
;


: 12_char ( c -- c flag )
    dup [CHAR] 1 = 
    over [CHAR] 2 = or
;

\ - Completed Mission - */
: gend ( -- game-key )

    ~" You find 2000 gold pieces!!!!!!" ~cr
    ~cr ~cr ~" You have completed your mission by clearing the Caves of Chaos"

    gold @ 2000 + gold !
    true_level @ 1+ true_level !
    ~cr ~cr ~" You completed the game with " gold @  ~. ~" gold pieces." ~cr
    ~" You have your levels restored and are at the ultimate level, " true_level @ ~. ~" ."
    ~cr ~" You had " hp @ ~. ~" hps at the end." ~cr ~cr
    ~" CONGRATULATIONS!!!!  (Tell Rob!!!)" ~cr ~cr


    ~" Type 1 to run again, or 2 to Quit "
    ['] 12_char C-input
;

\
\ These are the main game words
\
: do_monster_dead ( -- game-state )
    \ Are there any monsters left ?
    #mons 0= if
        \ If no monsters, player has completed game
        gend			\ completion message
        [char] 1 if G_goto_start		\ run again
        else G_stop then				\ else stop

    else
        \ otherwise monster death and player movement
        
        0 multi !           \ multiple fight off
        mondeath        	\ tell player monster dead
        heal        	    \ option to heal
        newlvl      		\ check for new player level

        pmove       		\ player movement
        G_reread_room       \ i=3, player moved - re-read room
    then
;

: set_multi ( -- )
    ~" Fight for many rounds..." ~cr ~cr
    ~" Please enter number of rounds to fight : "
    innum multi !
    multi @ 1 < if 1 multi ! then
;
: do_run ( -- )
    ~"  Run" ~cr ~cr ~cr
    hp @ 1- hp !            \ loose one hit point for running (chicken alert!!!!)

    \ unlike the C version, we don't need to 
    \ store this monsters hit points
    \ because we operate out of the map.

    \ move to last position - must have dead monster in it
    oldx @ x !
    oldy @ y !
;

: do_fight ( option-selected -- )
        [char] S = if
            do_cast	    \ check and do player spell casting
        then
        mons.hp 0 > if
            moncast	    \ monster casting
        then
        fighting	    \ real fighting Zzzz
;

: do_monster_alive ( -- game-state )
    multi @ 0= if
    
        foptions        			\ get what fight options are wanted
        dup [CHAR] M = if
            set_multi
        then
    
    else
        \ if user has entered multiple fights before, do them...
        [CHAR] M
    then
    multi @ if
        multi @ 1- multi !
    then

    dup [CHAR] F = if ~"  Fight" ~cr then

    dup [CHAR] R = if
        \ option chosen was RUN option
        
        drop
        do_run
        G_reread_room \ player moved, re-read room

    else
        \ spells and fighting
        do_fight ( takes a key selector )
        G_same_room   \ - Monster was alive loop - ie no room change

    then
;


: do_encounter ( -- game-state)
    \ Is this room's monster dead?
    mons.hp 0 <= if		    \ if monster dead mon hp = 0
        \ Monster dead
        do_monster_dead
    else		
        \ monster in this room is still alive
        do_monster_alive
    then
;

: do_room ( -- game-state )
    begin
        room_bg_colour
        clear_screen
        \ ******* fight sequence repeat, same room **************
        ['] .view is render_graphics
        0 11 at_xy
        rmintro     \ intro to room

        pdeath?	\ player death? (i 0=continue 1=goto start 2=stop)
        \ not from this routine but i=3 re-read room, i=4 same room

        \ ************ FIGHT/RUN/MONSTER DEATH/SPELL CASTING **********************

        dup G_continue = if		\ dont skip if i=0, other values of i loop or stop game
            drop \ don't need the game state
            do_encounter
        then

        \ what does i do?  0=continue(above, not here), 1=goto start, 2=stop,
        \			3=re-read room, 4=same room 
        \
        \			Note on i=0, pdeath does not know what other routines
        \			may re-direct program so i=0 is intermediate state.

    dup G_same_room <> until \ same room loop
;


\ This loop reads rooms - `do_game` only exits if the player dies or the game is 
\ won. `do_game` will loop if we change rooms.
\
: do_game ( -- game-state )
    begin

        \ ********* Re-read room data **************

        1 hit_strength ! \ players hit strength
        1 mon_hit_strength ! \ monster hit strength

        goroom    	\ generate monster in room

        do_room

    dup G_reread_room = while \ new room loop
        \ nothing here
    repeat
;



: game_data_setup
    \ players initial spells
    10 spells    c!
     2 spells 1+  c!
     2 spells 2 + c!
     1 spells 3 + c!
     3 spells 4 + c!        
    0 m/lvl !        \ number of monsters killed this level starts at zero 

    1 x !            \ players X position at start
    height_y y !	 \ players Y position at start
    1 oldx !		  \ players old X
    height_y oldy !	 \ players old Y - where to run to
    1 level !		 \ players level that can be drained
    1 true_level !   \ players True Level
    100 #mons !		 \ current number of monsters
    10 hp !		     \ players hit points
    0 gold !		 \ players Gold
    0 multi !		 \ Multiple fight off
    1 hit_strength ! \ players hit strength

;

\ 
\ This is the main game entry point
\
: caves_main ( -- )
    0 0 192 make_font_colour to blue_text
    begin
        \ ************* start (new game) *************
        main_menu
        setmap      \ map is Monster in room data
        game_data_setup

        \ ************* run the game *************
        do_game \ returns game state

    G_goto_start = while \ new game
        \ nothing here
    repeat
;  \ end of main

\ setup when testing functions
: test
    cr
    ." --------- TEST SETUP ---------" cr
    setup_SDL
    setmap
    \ DEBUG_ld_rooms
    \ debug.map
    game_data_setup
    goroom
    .player 
    rmintro
    1 hit_strength !
    1 mon_hit_strength !
    \ debug.map   

    0 0 192 make_font_colour to blue_text
    clear_screen
    make_picture

;

( this is a test word for showing the latest screen)
: ++ make_picture ;

\ test ++

