\ * CAVES OF CHAOS [RELEASE VERSION]
\ * ===============\-----> A little RPG
\ *
\ *    by Rob. (ZED) Probin (c) Copyright 1990/91/92
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
\ * perfect.
\ *
\ * The moral of this story....
\ *
\ *        ALWAYS STRUCTURE PROGRAMS even if they are only a few lines
\ * long or you could regret it.....
\ *                                   ZED.
\ *


\ These are for gForth emulation of vForth words
\ Comment out for vForth
: upper ( c1 -- c2 ) toupper ;


\ *
\ * UTILITY FUNCTIONS
\ *
: input ( -- c )
    \ remove spaces and return the character pressed
    begin
        key dup
        32 <=
    while
        drop
    repeat
;

: oneof ( addr u c -- flag )
    \ check if c is in the string
    swap
    ?do 
        over over c@ = if
            2drop true leave
        then
    loop
    2drop
;


\ Constrained input
: C-input ( compare-xt -- c )
        begin
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
2 constant hp_slots     \ first byte is actual HPs, second is original hit points for gold reward
1 constant mons_id_slots
#mon_spells hp_slots + mons_id_slots +
    constant sizeof_MapRec

\ in C code this was 'z' instead of map. But map is more descriptive here
create map width_x height_y * sizeof_MapRec * allot

\ fetch the 
: get_room_addr ( x y -- addr )
    width_x * + sizeof_MapRec * map +
;

: mons@ ( x y -- n )
    get_room_addr c@
;
: mons_HP@ ( x y -- n )
    get_room_addr 1+ c@
;
: mons_HP! ( n x y -- )
    get_room_addr 1+ c!
;
: mGold@ ( x y -- n )
    get_room_addr 2 + c@
;
: mGold! ( x y -- n )
    get_room_addr 2 + c@
;

\ sp = 1-6 ... notice: '2 +' is actually '3 + 1-'
: mSPELL@ ( sp x y -- n )
    get_room_addr swap + 2 + c@
;
: mSPELL! ( n sp x y -- )
    get_room_addr swap + 2 + c!
;
: mSPELL1- ( sp x y -- )
    mSPELL@ 1- mSPELL!
;


\ *
\ * - Screen start section -
\ *

: message ( -- )
    cr cr
    ." Caves Of Chaos      -      A little Fantasy RPG" cr
    ."          ... or something like that!!!" cr cr
    ." Copyright 1990-2024 Rob (Zed) Probin (The road goes on forever....)" cr
    ." CONTACT: rob  or  http://robprobin.com" cr
    ." Copies of this program may be made for NO CHARGE" cr
    ." SHAREWARE -- CHARGE FOR USE => Spread EVERYWHERE" cr
    ." Original written in GFA Basic V2 (by Zed)" cr
    ." Original version in C (7/5/92 & 12/2/93-Release modification" cr
    ." Mac OS X version 13th August 2001." cr
    ." Lua version 27th Feb 2019." cr
    ." C99 port - 4 May 2024." cr
    ." vForth Next version 5 May 2024." cr cr
    ." Now the game.....       (v1.30)" cr
;


\ - Room occupation by monsters - */

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

\ set up all the monsters in the rooms    
: setmap ( -- )
        
    \ get the address of the monster numbers
    source_map_data

    \ loop around all rooms
    width_x 0 do
        height_y 0 do
            
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
            j i get_room_addr c!

\           \  -1 for first time player has been in room
            -1 j i get_room_addr 1+ !

            \ next room
            1+
        loop
    loop

;

\ - Monster data -
create monname ," Kobold" ," Light Bulb" ," Giant Fly" ," Slime" ," Super Rat"
               ," Skeleton" ," Vampire" ," Purple Worm" ," Demon" ," Dragon" 
               ," Orc" ," Bear" ," Gargoyle" ," Elf" ," Giant Scorpion" 
               ," Troll" ," Giant Snake" ," Wolf" ," Bat" ," Destroyer" 
               ," Zombie" ," Hill Giant" ," Werewolf" ," Ogre" ," Goblin"
               \ end of list
               , ""

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
            bye
        then
    loop
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

0 [IF]


\
\ End of room data with monsters inside
\

\ most of these are player or general game data
5 constant #pspells
create spells ( player_spells ) #pspells allot
variable mcount  \ number of monster killed this level
variable x      \ players X position
variable y      \ players Y position
variable oldx     \ players old X
variable oldy     \ players old Y - where to run to
variable level  \ players level that can be drained
variable true_level \ players True Level
variable mcount     \ current number of monsters
variable hp     \ players hit points
variable gold   \ players Gold
variable multi  \ Multiple fight off
variable hit_strength \ players hit strength
variable mon_hit_strength \ monster hit strength

\
\ These fetch/store the current monster's data 
\
: .mons.name ( -- )
    x y mons@ get_monster_name type
;
: mons.hp ( -- n )
    x y mons_HP@
;
: mons.hp! ( n -- )
    x y mons_HP!
;

: mons.gold ( -- n )
    x y mGold@
;
: mons.gold! ( n -- )
    x y mGold!
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


\
\ Get room and monster data for this room -
\
\ This function basically populates the hit point data and the spell
\ data is the player hasn't been into that room before.

: goroom ( -- )

    x y mons@       \ get the monster in this room
    mdatasz * mondata +
    local mdata = mondata[n]
    \ quick sanity check hit point is not zero or negative
    dup c@ 0 <= if
        ." ERROR 3 - monster data broken" cr
    then

    ( monster_number -- )
    
    mons.hp -1 = if	             \ if first time player been in this room
        dup c@ mons.hp!          \ hit points from monster list
        dup c@ mons.gold!        \ store original hit points in gold as well
        1+ dup c@ 1 x y mSPELL!  \ get monster spells and put in store
        1+ dup c@ 2 x y mSPELL!
        1+ dup c@ 3 x y mSPELL!
        1+ dup c@ 4 x y mSPELL!
        1+ dup c@ 5 x y mSPELL!
        1+ dup c@ 6 x y mSPELL!
        drop
    then
;		\ end of goroom()


\ 
\       - Room intro text -
\ 
: rmintro ( -- )
    cr
    ." You have " hp . ." hit points and " gold . ." gold" cr
    multi @ 0= if ." You are Level " level . cr then
    ." Here is a monster with " mons.hp . ." hit points called a " .mons.name cr
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

    hp 1 < level 0= or if
      
        ." You have died" cr
        ." You had " gold . ." gold when you died" cr
        ." Press Y to play again, or type N to stop." cr
        ." ? "

        ['] YN_char C-input
        [CHAR] Y = if
            ." Yes please !!!" cr cr
            G_goto_start
        else
            ." No, not again" cr cr
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
  ." The " mons.name ." is Dead" cr
  ." You find " mons.gold ." Gold" cr cr

  gold @ mons.gold + gold !
  0 mons.hp!
  0 mons.gold!
;

: num_char ( c -- c flag )
    dup [CHAR] 0 >= 
    over [CHAR] 9 <= or
;

\ Allows input of a number
: innum ( -- n )
    
    \ first input has to be a number
    ['] num_char C-input

    \ make it into a number
    [CHAR] 0 - 

    begin
        input num_char
    while
        [CHAR] 0 - 
        \ multiply the first digit by 10, then add the units
        swap 10 * +
    repeat
;


: CH_char ( c -- c flag )
    dup [CHAR] C = 
    over [CHAR] H = or
;

\ 
\         - Heal Routine -
\ 
: heal ( -- )

    local a;
    local num;

    ." Do you wish to Heal(Type H) or continue(Type C)" cr cr
    ." ? "

    ['] CH_char C-input

    dup [CHAR] H if
    
        ." Heal" cr ." Healing: (10 gold = 1 hp)"

        0 \ dummy value to be dropped first time
        begin
            drop
            cr ." Type Hit points to be healed: "

            innum

            dup 10 * gold > 
            over 0 < or   if 
                cr 
                ." Not Enough Money!!" cr
                ." Type zero not to heal" cr
                drop -1
            then
        
        dup 0 > 
        until

        gold @ over 10 * - gold !

        hp @ swap - hp !

    else ." Continue" CR then

;





\ 
\         - New level -
\ 
: newlvl ( -- )
    mcount @ 10 = if
        cr ." You Gain a level!!!" cr
        cr ."           YOU COCKY BLEEDER" cr 	\ Pauls sentence!!
        ." You gain 10 hp" cr
        ." You gain 5 spells!" cr cr
        #pspells 1+ 1 do
            I spell@ 1+ I spell!     \ BASIC version had random selection of 5 spells
        loop
        level @ 1+ level !
        true_level @ 1+ true_level !
        hp @ 10 + hp !
        0 mcount !
    then
;

: move_char ( c -- c flag )
    dup [char] N = if -1 exit then 
    dup [char] S = if -1 exit then 
    dup [char] E = if -1 exit then 
    dup [char] W = if -1 exit then 
    dup [char] Q = if -1 exit then 
    dup [char] M = if -1 exit then 
    0
;

\ 
\       Player move around
\ 
: pmove ( -- )

    cr ." You may go "

    x @ 1 <> if ." West (Type W) or " then
    x @ width_x <> if ." East (Type E) or " then
    y @ height_y <> if ." South (Type S) or " then
    y @ 1 <> if ." North (Type N)" then
    cr ."or Wait (Type Q)"

    level 3 > if 
        ."  or Check the number of Monsters (Type M)." cr 
    else
        cr
    then
    cr ." Direction >"

    ['] move_char C-input

    \ record the old position before moving
    x @ oldx !
    y @ oldy !

    \ try to move
    dup [char] N = if
        cr cr
        y @ 1 > if
            ." You head North"
            y @ 1- y !
        else
            ." You can't go North, there is a wall."
        then
    then

    dup [char] S = if
        cr cr
        y @ height_y < if
            ." You head South"
            y @ 1+ y !
        else
            ." You can't go South, there is a wall."
        then
    then

    dup [char] W = if
        cr cr
        x @ 1 > if
            ." You head West"
            x @ 1- x !
        else
            ." You can't go West, there is a wall."
        then
    then

    dup [char] E = if
        cr cr
        x @ width_x < if
            ." You head East"
            x @ 1+ x !
        else
            ." You can't go East, there is a wall."
        then
    then

    dup [char] Q = if
        cr cr
        ." You stay where you are"
    then

    dup [char] M = level 3 > and if
        cr cr
        ." There are " mcount @ . ." monsters"
    then

    cr cr
    \ player moved, re-read room
end



: foptions_char ( c -- c flag )
    dup [char] R = 
    over [char] F = or
    over [char] S = or
    over [char] M = or
;

\ - Player fight options - 
: foptions ( -- c )
    cr
    ." Type R to run, F to fight once, M to fight many times"
    ."  or S to Cast Spell" cr
    ." What do you wish to do? "

    ['] foptions_char C-input
;


\ - Cast option -

: do_cast ( -- )
    ."  Cast spell" cr cr
    1 spell@ if ." Type 1 to cast an Ice Dart (" 1 spell@ ." left)" cr then
    2 spell@ if ." Type 2 to cast a Fireball (" 2 spell@ ." left)" cr then
    3 spell@ if ." Type 3 to cast Regenerate (" 3 spell@ ." left)" cr then
    4 spell@ if ." Type 4 to cast Drain level (" 4 spell@ ." left)" cr then
    5 spell@ if ." Type 5 to cast Gain Strength (" 5 spell@ ." left)" cr then
    ." Type 6. to not cast a spell" cr

    begin
        cr ." Which Magic Spell? "
        innum
        dup 1 >= if
            dup 6 = if leave then
            dup 6 < if
                dup spell@ 0 <> if leave then
            then
        then
        drop
    again


    \ actual spell activation

    dup 1 = if
        mons.hp 1- mons.hp!
        cr ." You cast an Ice Dart" cr
        1 spell@ 1- 1 spell!
    then
    dup 2 = if
        mons.hp 10 - mons.hp!
        cr ." You cast a Fireball" cr
        2 spell@ 1- 2 spell!
    then
    dup 3 = if
        hp @ 10 + hp !
        cr ." You cast Regenerate" cr
        ." You fell stronger" cr
        3 spell@ 1- 3 spell!
    then
    dup 4 = if
        hp @ 20 + hp !
        cr ." You cast Drain Level" cr
        4 spell@ 1- 4 spell!
    then
    dup 5 = if
        hit_strength @ 1+ hit_strength!
        cr ." You cast Gain Strength" cr
        5 spell@ 1- 5 spell!
    then
    drop
;

\ - Monster cast -
: moncast ( -- )
    6 x_rand 1+ ( spell_1_to_6 )
    dup x y mSPELL@ 0= if drop exit then
    dup x y mSPELL1-

    dup 1 = if
      cr ." The " .mons.name ." casts an Ice dart" cr
      hp @ 1- hp !
    then
    dup 2 = if 
      cr ." The " .mons.name ." casts a Fireball" cr
      hp @ 10 - hp !
    then
    dup 3 = if
      cr ." The " .mons.name ." casts Regenerate" cr
      mons.hp 10 + mons.hp!
    then
    dup 4 = if
      cr ." The " .mons.name ." casts Drain level" cr
      hp @ 10 - hp !
      level @ 1 - level !
    then
    dup 5 = if
      cr ." The " .mons.name ." casts Gain Strength" cr
      mon_hit_strength @ 1+ mon_hit_strength !
    then
    dup 6 = if          \ bug fix 10-Nov-2003 by Rob, spotted by Stu :-(
      cr ." The %s casts MEGA DEATH" cr ,.mons.name);
      ." Oh S**t!!!" cr
      hp @ 50 - hp !
    then
    drop
;



\ - General fight -
: fighting ( -- )

    cr
    20 x_rand 9 - mon_hit_strength @ 5 * - hit_strength @ 5 * +

    mons.hp + hp @ > if
      
      hp @ mon_hit_strength @ - hp !
      ." The " .mons.name ." hits you for " mon_hit_strength @ . 
      
    else
      
      mons.hp hit_strength - mons.hp!
      ." You hit the " .mons.name ." for " hit_strength @
    then

    mons.hp 1 < if
      
      mcount @ 1- mcount !
      mcount @ 1+ mcount !
      0 mons.hp!
    then

    cr cr 
;


: 12_char ( c -- c flag )
    dup [CHAR] 1 = 
    over [CHAR] 2 = or
;

\ - Completed Mission - */
: gend ( -- game-key )

    ." You find 2000 gold pieces!!!!!!" cr
    cr cr ." You have completed your mission by clearing the Caves of Chaos"

    gold @ 2000 + gold !
    true_level @ 1+ true_level !
    cr cr ." You completed the game with " gold @  . ." gold pieces." cr
    ." You have your levels restored and are at the ultimate level, " player.true_level @ . ." ."
    cr ." You had " hp ." hps at the end." cr cr
    ." CONGRATULATIONS!!!!  (Tell Rob!!!)" cr cr


    ." Type 1 to run again, or 2 to Quit "
    ['] 12_char C-input
;

\
\ These are the main game words
\
: do_monster_dead ( -- game-state )
    \ Are there any monsters left ?
    mcount 0= if
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
    ." Fight for many rounds..." cr cr
    ." Please enter number of rounds to fight : "
    innum multi !
    multi @ 1 < if 1 multi ! then
;
: do_run ( -- )
    ."  Run" cr cr cr
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
        mons.hp if
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
    multi @ 1- multi !

    dup [CHAR] F = if ."  Fight" cr then

    dup [CHAR] R = if
        \ option chosen was RUN option
        
        do_run
        G_reread_room \ player moved, re-read room

    else
        \ spells and fighting
        do_fight
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
    end
;

: do_room ( -- game-state )
    begin

        \ ******* fight sequence repeat, same room **************

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

        goroom    	\ generate monster in room

        1 hit_strength ! \ players hit strength
        1 mon_hit_strength ! \ monster hit strength

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
    0 mcount !        \ number of monsters killed this level starts at zero 

    1 x !            \ players X position at start
    height_y y !	 \ players Y position at start
    1 oldx !		  \ players old X
    height_y oldy !	 \ players old Y - where to run to
    1 level !		 \ players level that can be drained
    1 true_level !   \ players True Level
    100 mcount !		 \ current number of monsters
    10 hp !		     \ players hit points
    0 gold !		 \ players Gold
    0 multi !		 \ Multiple fight off
    1 hit_strength ! \ players hit strength

    \ technically don't need to set this up as it's done in pdeath
    continue state !
;

\ 
\ This is the main game entry point
\
: caves_main ( -- )
    begin
        \ ************* start (new game) *************
        message
        setmap      \ map is Monster in room data
        game_data_setup

        \ ************* run the game *************
        do_game \ returns game state

    G_goto_start = while \ new game
        \ nothing here
    repeat
;  \ end of main


\ run the game!
caves_main

[THEN]
