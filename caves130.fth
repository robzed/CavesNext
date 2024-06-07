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
6 constant number_of_spell_slots
2 constant hit_point_slots
1 constant monster_id_slots
number_of_spells_slots hit_point_slots + monster_id_slots +
constant elements_per_map_entry

\ in C code this was 'z' instead of map. But map is more descriptive here
create map width_x height_y * elements_per_map_entry * allot

\ fetch the 
: get_room_addr ( x y -- addr )
    width_x * + elements_per_map_entry * map +
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
; mOrigHP@ ( x y -- n )
    get_room_addr 2+ c@
;
; mOrigHP! ( x y -- n )
    get_room_addr 2+ c@
;

\ sp = 0-5
: mSPELL@ ( sp x y -- n )
    get_room_addr swap + 3+ c@
;
: mSPELL! ( n sp x y -- )
    get_room_addr swap + 3+ c!
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

0 [IF]

\
\       - Get room and monster data for this room -
\

: goroom ( x y -- )

    local monster = {}
    \ holds monster number
    mons@       \ get the monster in this room

    \ monster.name = monname[n]

    local mdata = mondata[n]
    if(not mdata) then
        printf("ERROR 3 - monster data broken\n");
    end

    if z[px][py][2] == -1 then		\ if not first time player been in this room
        z[px][py][2] = mdata[1];	\ hit points from monster list
        z[px][py][3] = mdata[1];	\ in store as well
        z[px][py][4] = mdata[2];	\ get monster spells and put in store */
        z[px][py][5] = mdata[3];
        z[px][py][6] = mdata[4];
        z[px][py][7] = mdata[5];
        z[px][py][8] = mdata[6];
        z[px][py][9] = mdata[7];
    end

    \ monster.hp = z[px][py][2];		\ fetch monster hit points from old visit or original
    \ monster.old_hp = z[px][py][3];	\ and original hit points

    return monster
;		\ end of goroom()

\
\ End of room data with monsters inside
\

\ most of these are player or general game data
create spells ( player_spells ) number_of_spell_slots allot
variable mcount  \ number of monster killed this level
variable x      \ players X position
variable y      \ players Y position
variable ox     \ players old X
variable oy     \ players old Y - where to run to
variable level  \ players level that can be drained
variable true_level \ players True Level
variable mo     \ current number of monsters
variable hp     \ players hit points
variable gold   \ players Gold
variable multi  \ Multiple fight off
variable hit_strength \ players hit strength
variable mon_hit_strength \ monster hit strength

0 constant continue
1 constant goto_start
2 constant stop
3 constant reread_room
4 constant same_room
variable state

\
\ These fetch/store the current monster's data 
\
: .mons.name ( -- )
    x y mons@ get_monster_name type
;
: monster.hp ( -- n )
    x y mons_HP@
;
: monster.hp! ( n -- )
    x y mons_HP!
;

: monster.old_hp ( -- n )
    x y mOrigHP@
;
: monster.old_hp! ( n -- )
    x y mOrigHP!
;
: spell@ ( n -- )
    1- spells + @
;
: spell! ( n -- )
    1- spells + !
;

\ 
\       - Room intro text -
\ 
: rmintro ( -- )
    cr
    ." You have " hp . ." hit points and " gold . ." gold" cr
    multi @ 0= if ." You are Level " level . cr then
    ." Here is a monster with " monster.hp . ." hit points called a " .mons.name cr
;

: YN_char ( c -- c flag )
    dup [CHAR] Y = 
    over [CHAR] N = or
;

\
\      - Player Death text -
\
\ Returns status: 0=continue 1=goto start 2=stop
: pdeath ( -- status )

    hp 1 < level 0= or if
      
        ." You have died" cr
        ." You had " gold . ." gold when you died" cr
        ." Press Y to play again, or type N to stop." cr
        ." ? "

        ['] YN_char C-input
        [CHAR] Y = if
            ." Yes please !!!" cr cr
            1
        else
            ." No, not again" cr cr
            2
        then
    then
;



\ 
\      - Monster Death text -
\ 

: mondeath (z, player, monster)
  
  ." The " mons.name ." is Dead" cr
  ." You find " monster.old_hp ." Gold" cr cr

  gold @ monster.old_hp + gold !
  0 monster.hp!
  0 monster.old_hp!
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
        for k,v in ipairs(player.m) do
            player.m[k] = v + 1     \ BASIC version had random selection of 5 spells
        end
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
    x @ ox !
    y @ oy !

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
        ." There are " mo @ . ." monsters"
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

: castop ( selected -- )

    [char] S <> if
        exit
    then
    
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
        monster.hp 1- monster.hp!
        cr ." You cast an Ice Dart" cr
        1 spell@ 1- 1 spell!
    then
    dup 2 = if
        monster.hp 10 - monster.hp!
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
: moncast    
    6 x_rand
    dup x y mSPELL@ 0= if drop exit then
    dup x y mSPELL1-

    dup 0= if
      cr ." The " .mons.name ." casts an Ice dart" cr
      hp @ 1- hp !
    then
    dup 1 = if 
      cr ." The " .mons.name ." casts a Fireball" cr
      hp @ 10 - hp !
    then
    dup 2 = if
      cr ." The " .mons.name ." casts Regenerate" cr
      monster.hp 10 + monster.hp!
    then
    dup 3 = if
      cr ." The " .mons.name ." casts Drain level" cr
      hp @ 10 - hp !
      level @ 1 - level !
    then
    dup 4 = if
      cr ." The " .mons.name ." casts Gain Strength" cr
      mon_hit_strength @ 1+ mon_hit_strength !
    then
    dup 5 = if          \ bug fix 10-Nov-2003 by Rob, spotted by Stu :-(
      cr ." The %s casts MEGA DEATH" cr ,.mons.name);
      ." Oh S**t!!!" cr
      hp @ 50 - hp !
    then
    drop
;



\ - General fight -
: fighting

    cr
    20 x_rand 9 - monster.hit_strength @ 5 * - hit_strength @ 5 * +

    monster.hp + hp @ > if
      
      hp @ mon_hit_strength @ - hp !
      ." The " .mons.name ." hits you for " mon_hit_strength @ . 
      
    else
      
      monster.hp = monster.hp - player.hit_strength;
      ." You hit the " .mons.name ." for " hit_strength @
    then

    monster.hp 1 < if
      
      mo @ 1- mo !
      mcount @ 1+ mcount !
      0 monster.hp!
    then

    cr cr 
;



\ - Completed Mission - */
: gend

    ." You find 2000 gold pieces!!!!!!" cr
    cr cr ." You have completed your mission by clearing the Caves of Chaos"

    gold @ 2000 + gold !
    true_level @ 1+ true_level !
    cr cr ." You completed the game with " gold @  . ." gold pieces." cr
    ." You have your levels restored and are at the ultimate level, " player.true_level @ .
    cr ." You had " hp ." hps at the end." cr cr
    ." CONGRATULATIONS!!!!  (Tell Rob!!!)" cr cr

    local a
    repeat

      ." Type 1 to run again, or 2 to Quit "
      a=input();

    until (a=='1' or a=='2');

    return a;
;

\
\ Player Data
\

: do_room ( -- )
    repeat

        \ ******* fight sequence repeat, same room **************

        rmintro(player, monster);		\ intro to room

        i = pdeath(player);	\ player death (i 0=continue 1=goto start 2=stop)
        \ not from this routine but i=3 re-read room, i=4 same room

        \ ************ FIGHT/RUN/MONSTER DEATH/SPELL CASTING **********************

    if(i==0) then		\ dont skip if i=0, other values of i loop or stop game
        
        \ Is this room's monster dead?
        if(monster.hp <= 0) then				\ if monster dead mon hp = 0
        \ Monster dead

        \ Are there any monsters left ?
        if(player.mo == 0) then
            \ If no monsters, player has completed game
            
            a=gend(player);			\ completion message
            if(a=='1') then i=1;		\ run again
            else i=2; end				\ else stop
            
        else
            \ otherwise monster death and player movement
            
            player.multi=0;                         \ multiple fight off
            mondeath(map, player, monster);	\ tell player monster dead
            heal(player);				\ option to heal
            newlvl(player);			\ check for new player level

            pmove(player);		\ player movement
            i=3; 		\ i=3, player moved - re-read room
        end
        
        else		
        \ monster in this room is still alive
        

        if(player.multi==0) then
        
            a=foptions();			\ get what fight options are wanted
            if(a=='m' or a=='M') then
                
                printf("Fight for many rounds...\n\n");
                printf("Please enter number of rounds to fight : ");
                player.multi=innum();
                if(player.multi<1) then player.multi=1; end
                player.multi = player.multi - 1;
            end
        
        else
        
            player.multi = player.multi - 1;
            a='M';
        end

        if(a=='F' or a=='f') then printf(" Fight\n"); end

        if(a=='R' or a=='r') then
            \ option chosen was RUN option
            
            printf(" Run\n\n\n");
            player.hp = player.hp -1;	\ loose one hit point for running (chicken alert!!!!)
            local x = player.x
            local y = player.y
            map[x][y][2]=monster.hp;	\ store this monsters hit points
            player.x = player.ox;
            player.y = player.oy;	\ move to last position - must have dead monster in it
            i=3; \ player moved, re-read room
            
        else
            \ spells and fighting
            
            castop(a, player, monster);	\ check and do player spell casting
            if(monster.hp ~= 0) then
            
            moncast(map, player, monster);	\ monster casting
            end
            fighting(player, monster);	\ real fighting Zzzz
            i=4;      \ - Monster was alive loop - ie no room change
            end
        end \ end of monster alive block
        end  \ end of i==0 block .... next section decides on loop due to i

    \ what does i do?  0=continue(above, not here), 1=goto start, 2=stop,
    \			3=re-read room, 4=same room 
    \
    \			Note on i=0, pdeath does not know what other routines
    \			may re-direct program so i=0 is intermediate state.

    until(i~=4); \ same room loop

;

\ This loop reads rooms - `do_game` only exits if the player dies or the game is 
\ won. `do_game` will loop if we change rooms.
\
: do_game ( -- )
    begin

      \ ********* Re-read room data **************
    
      local monster = goroom(map, player.x, player.y)	\ generate monster in room
        \ monsters have hp, old_hp, name. Their spells are the map room data

        1 hit_strength ! \ players hit strength
        1 mon_hit_strength ! \ monster hit strength
        
        do_room

    state reread_room = while \ new room loop
        \ nothing here
    repeat
;



: game_data_setup
    \ players initial spells
    10 m    c!
     2 m 1+  c!
     2 m 2 + c!
     1 m 3 + c!
     3 m 4 + c!        
    0 mcount !        \ number of monsters killed this level starts at zero 

    1 x !            \ players X position at start
    height_y y !	 \ players Y position at start
    1 ox !		     \ players old X
    height_y oy !	 \ players old Y - where to run to
    1 level !		 \ players level that can be drained
    1 true_level !   \ players True Level
    100 mo !		 \ current number of monsters
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
        do_game

    state goto_start = while \ new game
        \ nothing here
    repeat
;  \ end of main


\ run the game!
caves_main

[THEN]
