-- NOTE: my random (x_rand) is included at the bottom of THIS source 

--[[ CAVES OF CHAOS [RELEASE VERSION]
 *   ===============-------> A little RPG
 *
 *    by Rob. (ZED) Probin (c) Copyright 1990/91/92
 *
 *    Converted to C on 5/7/92.
 *    Original version in GFA Basic v2
 *
 *   v1.27 - MacOS X Port, 13/8/2001, Rob Probin. 
 *   v1.28 - Bug fix 10-Nov-2003 by Rob/Stu. Destroyer casts mega death straight away. line 681
 *           But maybe the Destroyer SHOULD case mega death straight away?
 *           Has this bug always been in?
 *   v1.29 - Rob Probin, ported to Lua 27 Feb 2019
 --]]
 
--[[ NOTE ABOUT STRUCTURE
 *
 * This program has poor structuring. The reason for this lies in its
 * BASIC origins, not because GFA Basic is unstructured (it can be VERY
 * structured!) but because this was just a little mess around program
 * that I was writing that seems to have expanded !!!
 *
 * In the C version I have attempted to add more structure to the program
 * to allow easy examination of the program, but it is still far from
 * perfect.
 *
 * The moral of this story....
 *
 *        ALWAYS STRUCTURE PROGRAMS even if they are only a few lines
 * long or you could regret it.....
 *                                   ZED.
 --]]

--[[
 *
 * USER INTERFACE FUNCTIONS
 *
--]]

--#define getch() getchar()		// emulate getch (MacOS X change)
--[[
local function getch()
    if gulp then
    else
        return io.read(1)
    end
end
local getchar = getch
--]]
local function get_line()
    if gulp then
        return gulp.caves:get_line()
    else
        return io.read()    -- defaults to "*l" / "l" on Lua 5.1-5.4 (i.e. line read, no newline)
    end
end

local printf = function(s,...)
    local text = s:format(...)
    if gulp then
        gulp.caves:printf(text)
    else
        return io.write(text)
    end
end


--[[
 *
 * UTILITY
 *
--]]
local function input()
    local str = get_line():gsub("%s+", "")  -- don't care about number of matches
    return str
end

--[[
 *
 * MAIN PROGRAM BLOCK
 *
--]]

local height_y = 10
local width_x = 10
local map

function caves_main()

--local count,x,y,ox,oy,l,l2,mo,t,g,v,j,multi;
local i,a;			-- general variables

repeat
      --************* start (new game) *************
      message();
      
      -- map is Monster in room data
      map = setmap();

      --[[
             - Data setup -
       --]]
      local player = {
          m = { 10, 2, 2, 1, 3},		-- players initial spells
          count=0,		-- number of monster killed this level

          x=1,			-- players X position
          y=height_y,	-- players Y position
          ox=1,			-- players old X
          oy=height_y,	-- players old Y - where to run to
          level=1,		-- players level that can be drained
          true_level=1,	-- players True Level
          mo=100,		-- current number of monsters
          hp=10,			-- players hit points
          gold=0,			-- players Gold
          multi=0,		-- Multiple fight off
          hit_strength = 1;         -- Rob 3 June 2024 - Bug compared with C version?
          -- End of Data Setup
      }

    repeat

      --********* Re-read room data **************
    
      local monster = goroom(map, player.x, player.y)	-- generate monster in room
        -- monsters have hp, old_hp, name. Their spells are the map room data
        monster.hit_strength = 1
        
        repeat

          --******* fight sequence repeat, same room **************

          rmintro(player, monster);		-- intro to room

          i = pdeath(player);	-- player death (i 0=continue 1=goto start 2=stop)
            -- not from this routine but i=3 re-read room, i=4 same room

        --************ FIGHT/RUN/MONSTER DEATH/SPELL CASTING **********************

        if(i==0) then		-- dont skip if i=0, other values of i loop or stop game
          
          -- Is this room's monster dead?
          if(monster.hp <= 0) then				-- if monster dead mon hp = 0
            -- Monster dead

            -- Are there any monsters left ?
            if(player.mo == 0) then
              -- If no monsters, player has completed game
              
              a=gend(player);			-- completion message
              if(a=='1') then i=1;		-- run again
              else i=2; end				-- else stop
              
            else
              -- otherwise monster death and player movement
              
              player.multi=0;                         -- multiple fight off
              mondeath(map, player, monster);	-- tell player monster dead
              heal(player);				-- option to heal
              newlvl(player);			-- check for new player level

              pmove(player);		-- player movement
              i=3; 		-- i=3, player moved - re-read room
            end
            
          else		
            -- monster in this room is still alive
            

            if(player.multi==0) then
            
                a=foptions();			-- get what fight options are wanted
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
              -- option chosen was RUN option
              
              printf(" Run\n\n\n");
              player.hp = player.hp -1;	-- loose one hit point for running (chicken alert!!!!)
              local x = player.x
              local y = player.y
              map[x][y][2]=monster.hp;	-- store this monsters hit points
              player.x = player.ox;
              player.y = player.oy;	-- move to last position - must have dead monster in it
              i=3; -- player moved, re-read room
              
            else
              -- spells and fighting
              
              castop(a, player, monster);	-- check and do player spell casting
              if(monster.hp ~= 0) then
                
                moncast(map, player, monster);	-- monster casting
              end
              fighting(player, monster);	-- real fighting Zzzz
              i=4;      -- - Monster was alive loop - ie no room change
              end
            end -- end of monster alive block
          end  -- end of i==0 block .... next section decides on loop due to i

        --[[ what does i do?  0=continue(above, not here), 1=goto start, 2=stop,
         *			3=re-read room, 4=same room 
         *
         *			Note on i=0, pdeath does not know what other routines
         *			may re-direct program so i=0 is intermediate state.
         --]]

        until(i~=4); -- same room loop
    until(i~=3); -- new room loop
until(i~=1); -- new game

end -- end of main


--[[ message
 *
 * - Screen start section -
 *
 --]]

function message()
    printf("\n\nCaves Of Chaos      -      A little Fantasy RPG\n");
    printf("         ... or something like that!!!\n\n");
    printf("Copyright 1990-2001 Rob (Zed) Probin (The road goes on forever....)");
    printf("\nCONTACT: rob  or  http://robprobin.com\n");
    printf("Copies of this program may be made for NO CHARGE\n");
    printf("SHAREWARE -- CHARGE FOR USE => Spread EVERYWHERE\n");
    printf("Original written in GFA Basic V2 (by Zed)\n");
    printf("Original version in C (7/5/92 & 12/2/93-Release modification)\n");
    printf("Mac OS X version 13th August 2001. \n");
    printf("Lua version 27th Feb 2019. (v1.29)\n\n");
    printf("Now the game.....       (v1.29)\n\n");
end


-- - Room occupation by monsters - */

local source_map_data ={
            { 11,11,17,12,12, 9,16,22,10,20 },
            { 14,11,11,17,12,12, 9,15,22,10 },
            { 14,14,11,11,12,12, 9,16,15,15 },
            { 14,14,21,05,05,12, 9, 9,16,16 },
            { 07,25,05,05,05,13, 9,19, 9, 9 },

            { 18,25,05,21,05,13,13,13,17,17 },
            { 21,05,05,05,05,23,23,23,25,07 },
            { 03,03,05, 8, 8,18,24,24,25,25 },
            { 02,04,06,05, 8, 8,24,07,25,19 },
            { 01,06,04,04, 8,18,07,25,23,9 },
                };

--[[ setmap

   - Map set up routine -

 --]]
function setmap()
    -- set up all the monsters in the rooms    
    local z = {}
    
    -- do some basic data checks
    if #source_map_data ~= height_y then
        printf("ERROR 10 - MAP DATA IN ERROR\n");
        exit(0);
    end

    for _, line_at_y in ipairs(source_map_data) do
        if #line_at_y ~= width_x then
            printf("ERROR 10 - MAP DATA IN ERROR\n");
            exit(0);
        end
    end
    
    -- make the table array
    for x = 1, width_x do
        table.insert(z, {})     -- we index x first
        local t = z[x]
        for y = 1, height_y do
            table.insert(t, {}) -- each location has it's own table for data
        end
    end

    -- fill the table ... notice we reverse the coordinates here from t[y][x] to z[x][y]
    for y, line_at_y in ipairs(source_map_data) do
        for x, data in ipairs(line_at_y) do        
            z[x][y][1] = data;
            z[x][y][2] = -1;
        end
    end

    return z
end


-- - Monster data -

local monname ={ "Kobold","Light Bulb","Giant Fly","Slime","Super Rat",
"Skeleton","Vampire","Purple Worm","Demon","Dragon","Orc","Bear","Gargoyle",
"Elf","Giant Scorpion","Troll","Giant Snake","Wolf","Bat","Destroyer","Zombie",
"Hill Giant","Werewolf","Ogre","Goblin"};

local mondata = {{1,0,0,0,0,0,0},	{2,2,0,0,0,0,0},
		  {3,0,0,0,0,0,0},	{4,0,0,0,0,0,0},
		  {23,0,0,0,0,0,0},	{2,0,0,0,0,0,0},
		  {20,0,0,0,2,0,0},	{5,0,0,0,0,0,0},
		  {50,20,1,0,0,0,0},	{150,10,5,0,0,0,0},
		  {25,0,0,0,0,0,0},	{30,0,0,0,0,0,0},
		  {57,0,0,0,0,0,0},
		  {9,0,5,0,0,0,0},	{90,10,0,0,0,0,0},
		  {120,0,0,8,0,2,0},	{26,0,0,0,0,0,0},
		  {10,0,0,0,0,0,0},	{8,0,0,0,0,0,0},
		  {200,20,10,10,10,20,2},	{10,0,0,0,0,0,0},
		  {135,0,0,0,0,2,0},	{35,0,0,2,0,0,0},
		  {18,0,0,0,0,6,0},	{15,0,0,0,0,0,0} };

--[[
        - Get room and monster data for this room -
--]]
 
function goroom(z, px,py)

    local monster = {}
    -- holds monster number
    local n = z[px][py][1];		-- get the monster in this room

	-- if monster number=0 error
    if not n or n == 0 then
        printf("ERROR 1 - MONSTER DATA IN ERROR\n");
        exit(0);
    end

    monster.name = monname[n]
    if(not monster.name) then
        printf("ERROR 2 - END OF NAME STRING REACHED\n");
        exit(0);
    end

    local mdata = mondata[n]
    if(not mdata) then
        printf("ERROR 3 - monster data broken\n");
    end

    if z[px][py][2] == -1 then		-- if not first time player been in this room
        z[px][py][2] = mdata[1];	-- hit points from monster list
        z[px][py][3] = mdata[1];	-- in store as well
        z[px][py][4] = mdata[2];	-- get monster spells and put in store */
        z[px][py][5] = mdata[3];
        z[px][py][6] = mdata[4];
        z[px][py][7] = mdata[5];
        z[px][py][8] = mdata[6];
        z[px][py][9] = mdata[7];
    end

    monster.hp = z[px][py][2];		-- fetch monster hit points from old visit or original
    monster.old_hp = z[px][py][3];	-- and original hit points

    return monster
end		-- end of goroom()


--[[
       - Room intro text -
 --]]
function rmintro(player, monster)
    printf("\nYou have %d hit points and %d gold\n", player.hp, player.gold);
    if(player.multi==0) then printf("You are Level %d\n", player.level); end
    printf("Here is a monster with %d hit points called a %s\n", monster.hp, monster.name);
end

--[[
      - Player Death text -
--]]
function pdeath(player)

    local go2 = 0;	-- go2, 0=continue 1=goto start 2=stop

    if player.hp < 1 or player.level == 0 then
      
        printf("You have died\n");
        printf("You had %d gold when you died\n\n",player.gold);
        printf("Press Y to play again, or type N to stop. \n");
        printf("? ");
        local c
        repeat
            c = input();
        until c=='Y' or c=='y' or c=='N' or c=='n';

        if c=='Y' or c=='y' then
            printf("Yes please !!!\n\n");
            go2=1;
        else
            printf("No, not again\n\n");
            go2=2;
        end
    
    end

    return go2;
end



--[[
      - Monster Death text -
--]]

function mondeath(z, player, monster)
  
  printf("The %s is Dead\n",monster.name);
  printf("You find %d Gold\n\n", monster.old_hp);

  local x = player.x
  local y = player.y
  z[x][y][2]=0;
  z[x][y][3]=0;
  player.gold =  player.gold + monster.old_hp;
end

--[[
         - Heal Routine -
 --]]
function heal(player)

    local gold = player.gold
    local hp = player.hp

    local a;
    local num;

    printf("Do you wish to Heal(Type H) or continue(Type C)\n\n? ");
    repeat
        a = input();
    until (a=='H' or a=='h'or a=='C' or a=='c')

    if(a=='H' or a=='h') then
    
        printf("Heal\nHealing: (10 gold = 1 hp)");
        repeat
        
            printf("\nType Hit points to be healed: ");

            num=innum();

            if((num*10) > gold or num < 0) then
                printf("\nNot Enough Money!!\n");
                printf("Type zero not to heal\n");
                num = -1;
            end
        
        until (num >= 0);

        player.gold = gold - (num*10);
        player.hp = hp + num;

    else printf("Continue\n"); end

end


-- Allows input of a number
function innum()
    -- return type int
    local i
    repeat
        i = tonumber(input())
    until i
    
    return i
end


--[[
         - New level -
 --]]
function newlvl(player)
    if(player.count==10) then 
        printf("\nYou Gain a level!!!\n");
        printf("\n          YOU COCKY BLEEDER\n");	-- Pauls sentence!!
        printf("You gain 10 hp\n");
        printf("You gain 5 spells!\n\n");
        for k,v in ipairs(player.m) do
            player.m[k] = v + 1     -- BASIC version had random selection of 5 spells
        end
        player.level = player.level + 1;
        player.true_level = player.true_level + 1;
        player.hp = player.hp + 10;
        player.count = 0;
    end
end


--[[
        Player move around
 --]]
function pmove(player)

    printf("\nYou may go ");
    local x = player.x
    local y = player.y

    if(x~=1) then printf("West (Type W) or "); end
    if(x~=width_x) then printf("East (Type E) or "); end
    if(y~=height_y) then printf("South (Type S) or "); end
    if(y~=1) then printf("North (Type N)"); end
    printf("\nor Wait (Type Q)");

    if(player.level > 3) then
        printf(" or Check the number of Monsters (Type M).\n"); 
    else
        printf(".\n");
    end
    printf("\nDirection >");
    local c
    repeat
        c=input();
    until(c=='N' or c=='n' or c=='S' or c=='s' or c=='E' or c=='e' or c=='W'
    or c=='w' or c=='Q' or c=='q' or c=='M' or c=='m');

    player.ox = x;
    player.oy = y;

    if((c=='N' or c=='n') and y~=1) then
    
        printf("\n\nYou head North");
        player.y = y -1;
    end
    if((c=='S' or c=='s') and y~=height_y) then
    
        printf("\n\nYou head South");
        player.y = y +1;
    end
    if((c=='W' or c=='w') and x~=1) then
    
        printf("\n\nYou head West");
        player.x = x - 1;
    end
    if((c=='E' or c=='e') and x~=width_x) then
    
        printf("\n\nYou head East");
        player.x = x + 1;
    end

    if(c=='Q' or c=='q') then printf("\n\nYou stay where you are"); end

    if((c=='M' or c=='m') and player.level > 3) then printf("\n\nThere are %d monsters",player.mo); end

    printf("\n\n");

    -- player moved, re-read room
end




-- - Player fight options - 
function foptions()
    printf("\nType R to run, F to fight once, M to fight many times");
    printf(" or S to Cast Spell\n");
    printf("What do you wish to do? ");

    local c
    repeat
      c=input();
    until(c=='r' or c=='R' or c=='f' or c=='F' or c=='s' or c=='S' or c=='m' or c=='M');

    return c;
end

-- - Cast option -

function castop(selected, player, monster)

    if(selected~='S' and selected~='s') then
        return
    end
    
    printf(" Cast spell\n\n");
    local m = player.m
    if(m[1]~=0) then printf("Type 1 to cast an Ice Dart (%d left)\n",m[1]); end
    if(m[2]~=0) then printf("Type 2 to cast a Fireball (%d left)\n",m[2]); end
    if(m[3]~=0) then printf("Type 3 to cast Regenerate (%d left)\n",m[3]); end
    if(m[4]~=0) then printf("Type 4 to cast Drain level (%d left)\n",m[4]); end
    if(m[5]~=0) then printf("Type 5 to cast Gain Strength (%d left)\n",m[5]); end
    printf("Type 6. to not cast a spell\n");

    local i
    repeat
        repeat
            printf("\nWhich Magic Spell? ");
            i=innum();
        until (i>=1 and i<=6);
    until(i==6 or m[i]~=0);

    -- actual spell activation

    if(i==1) then
        monster.hp = monster.hp - 1;
        printf("\nYou cast an Ice Dart\n");
        player.m[1] = m[1] - 1;
    elseif(i==2) then
        monster.hp = monster.hp - 10;
        printf("\nYou cast a Fireball\n");
        player.m[2] = m[2] - 1;
    elseif(i==3) then
        player.hp = player.hp + 10;
        printf("\nYou cast Regenerate\n");
        printf("You fell stronger\n");
        player.m[3] = m[3] - 1;
    elseif(i==4) then
        monster.hp = monster.hp - 20;
        printf("\nYou cast Drain Level\n");
        player.m[4] = m[4] - 1;
    elseif(i==5) then
        player.hit_strength = player.hit_strength + 1;
        printf("\nYou cast Gain Strength\n");
        player.m[5] = m[5] - 1;
    end

end

-- - Monster cast -
function moncast(z, player, monster)
    local x = player.x
    local y = player.y
    local namestr = monster.name
    
    local k = x_rand(6);
    local spell_slot_idx = k + 4
    if z[x][y][spell_slot_idx] == 0 then
        return
    end
    z[x][y][spell_slot_idx] = z[x][y][spell_slot_idx] - 1;

    if(k==0) then
      printf("\nThe %s casts an Ice dart\n",namestr);
      player.hp = player.hp - 1
    elseif (k==1) then
      printf("\nThe %s casts a Fireball\n",namestr);
      player.hp = player.hp - 10
    elseif k == 2 then
      printf("\nThe %s casts Regenerate\n",namestr);
      monster.hp = monster.hp + 10
    elseif k==3 then
      printf("\nThe %s casts Drain level\n",namestr);
      player.hp = player.hp - 10
      player.level = player.level - 1
    elseif k==4 then
      printf("\nThe %s casts Gain Strength\n",namestr);
      monster.hit_strength = monster.hit_strength + 1
    elseif k==5 then          -- bug fix 10-Nov-2003 by Rob, spotted by Stu :-(
      printf("\nThe %s casts MEGA DEATH\n",namestr);
      printf("Oh S**t!!!\n");
      player.hp = player.hp - 50;
    end
end



-- - General fight -
function fighting(player, monster)

    printf("\n");
    local k = x_rand(20)-9-monster.hit_strength*5+player.hit_strength*5;

    if (monster.hp+k) > player.hp then
      
      player.hp = player.hp - monster.hit_strength;
      printf("The %s hits you for %d", monster.name, monster.hit_strength);
      
    else
      
      monster.hp = monster.hp - player.hit_strength;
      printf("You hit the %s for %d", monster.name, player.hit_strength);
    end

    if(monster.hp<1) then
      
      player.mo = player.mo - 1;
      player.count = player.count + 1;
      monster.hp = 0;
    end

    printf("\n\n");
end



-- - Completed Mission - */
function gend(player)

    printf("You find 2000 gold pieces!!!!!!\n");
    printf("\n\nYou have completed your mission by clearing the Caves of Chaos");

    player.gold = player.gold + 2000;
    player.true_level = player.true_level + 1;
    printf("\n\nYou completed the game with %d gold pieces.\n",player.gold);
    printf("You have your levels restored and are at the ultimate level, %d.",player.true_level);
    printf("\nYou had %d hps at the end.\n\n",player.hp);
    printf("CONGRATULATIONS!!!!  (Tell Rob!!!)\n\n");

    local a
    repeat

      printf("Type 1 to run again, or 2 to Quit ");
      a=input();

    until (a=='1' or a=='2');

    return a;
end




-- random stuff */

local x_seed=3456;

-- Random Number Generator by Rob (ZED) Probin 4/7/92 */
-- using mod function sequence */

function x_rand(dice)

    local x;

    x = 75*(x_seed+1);		-- basic random sequence */
    x = x % 65537;				-- then find remainder */

    x_seed = math.floor(x-1);				-- next seed new random number*/
    x = x * dice;			-- make sure in wanted dice range */
    x= x / 65536;				-- change to correct scale last*/

    return math.floor(x);

end


if not gulp then
    caves_main()
end
