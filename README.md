# CavesNext

Copyright 1990-2024 Rob Probin

"CavesNext" or "Caves of Chaos" or simply "Caves"

## About the game

Caves is a simple-but-challenging version of an old-style fantasy role-playing game where the themes are fighting, magic spells, exploration, invesigation, character improvement and strategy.

It's set in a fantasy realm with evil monsters and magic. You must fight your way out and defeat your foes before leaving. The monsters all just want to attack you. Like old style RPGs computer games that don't have much role-playing, Caves is mostly fighting, magic and levelling-up your character.

The game is played in a dungeon on a 10 by 10 grid (a bit like an expanded chess board), where the objective is to kill all monsters to escape. It sounds like you could never get lost 
which is true in theory but don't assume that the way it will work out!

Although there is some chance (randomness) involved in fighting - overall it's largely a strategy game and you can win fights reliably if you are strategic and don't just run about without a plan. Of course you must figure out what your plan should be by playing the game a few times first!

My advice for all players has always been is to make a phyiscal map. In my experience it's unlikely you will win without this. 

NOTE: there are hints below that are minor spoilers.

## Hints to Playing the Text Version

You must make a map, and plan which monsters you fight first. The game is on a 10 by 10 grid - and leveling up is critical to defeating each monster.

## More Hints for playing the game

Somewhat minor spoilers - don't read this section for full experience!

* Play the gmae a few times to get a feel of it. 
* You need to figure out when not to fight a creature that's too strong for you at the moment.
* Even though it's on a 10 by 10 grid you still discover where monsters are and what they can do. Some monsters have spells (effectively like abilities) and those are logical for the type of creature, at least if you've played fantasy games made popular with D&D (table top or computer) or read fantasy books. Then they shouldn't be too suprising - but it's still a learning experience. 
* Make a map - work out which are easier monsters and tackle those first.
* Don't fight monsters that have a lot more HP than you -  monsters that 
have more hit points are hard to defeat.
* Don't hoard gold - the only point is to heal hit points!
* You always run away to the last safe position you were at in the dungeon.
* If you are trying win the game you will need to use spells strategically, i.e. don't waste all of them too early. 

## Playing the game vs. the source code.

Reading the source code is also a minor spoiler. For instance fight mechanics and the 
map is in there - which normally is discovered as part of the game - but reading
the source code isn't as helpful as you might think - so resist the urge. 

Conversely you definitely don't need to read the code to win; avoid it if possible.

## Code History

A long time ago, I wrote a simple text based RPG in GFA BASIC for the Atari ST called Caves of Chaos. This was a quick hack and the code is terrible. But it was fun to play, if a big tricky to beat sometimes if you don't plan ahead. 

Sometime after that, a friend (called Ian) was talking to me about writing games, and so I spent a bit of time porting it to (K&R-style) C.

A sometime time after that I ported it to the Mac. 

Then I ported it to Lua as an Easter Egg, in an uncompleted game called Forlorn Fox.

Then more recently I tried to get the C version to compile on a more modern compiler. I needed to change the function signatures to get it to compile. 

Some of these versions are in the reference folder. The Lua version specifically looks like it has a bug, or at least operates player hit strength differently from the C version - and this like makes the game easier and upsets the balance of the game.

This version is ported to Forth because I wanted to run it on the hobbist/kickstarter Sinclair Spectrum Next - a remake/enhancement of classic 8-bit serial of computers from the 1980's. There are Z80 C compilers, but C isn't a great language for the Z80, and apart from that binary blobs made from C are a bit boring - I like interative environments for experimenting with - like Lua, Python, BASIC, etc.

Ignoring Z80 assembler (which I've done plenty of) the choices seemed to be Sinclair BASIC (potentially the Next enhanced version of it), or Forth. Specfically there is a pretty good Forth called vForth by Matteo Vitturi which I've played with. 

Since this is for fun, and I've always wanted to write Forth on the Sinclair Spectrum, vForth seems a good option. Also I've already written this game in BASIC ... although I really don't know if I have a 3.5" floppy copy of the BASIC source.

The code is still terrible in many ways - but perhaps it has got better slightly - although reintroducing global variables for the 8-bit version hurt a bit :-)



## Working with the Forth version

Some of the Forth version was tested in gForth. Although this isn't compatible with vForth (or vs. versa) it's not hard to get it to run.

It was incrementally, interactively, tested as is the way with Forth. 

## Other information

### Compiling the C version

At some point I'll add a comment on how to do it on different platforms. But since it's a single file using standard C, I think you should be able to compile this on any standard C machine.

### Running the Lua version

There is a helper script - but I haven't got around to documenting any of this yet.

### License

I've put the source files under GPLv3, although there is a shareware message in the binary. 

Usually my code is under permissive licenses like the MIT license or Zlib-style licenses. If you wnat to do something that you think the GPLv3 won't allow you to do, then tell me what, and we can discuss a change.

### Notes on the name

I've recently become aware of a table-top RPG module that contains dungeon with a similar name. However, these bear no relationship to this game. I don't think I'd played this specific module *before* writing this game, so this is likely simply a co-incidence. It's a pretty generic name and the words 'Chaos' and 'Caves' popular in the late 70' and early 80's - with Chaos Theory and dungeon crawlers like Colossal Cave.

I'd like to have a written a game called 'Pyramids of Mars' - there was printed magazine type-in game of that name, but I think the author might have got the name (accidentially or otherwise) from the Doctor Who series in 1975.


