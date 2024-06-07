# CavesNext

Copyright 1990-2024 Rob Probin

"CavesNext" or "Caves of Chaos" or simply "Caves"

## Background

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


## Hints to Playing the Text Version

You must make a map, and plan which monsters you fight first. The game is on a 10 by 10 grid - and leveling up is critical to defeating each monster.

## Working with the Forth version

Some of the Forth version was tested in gForth. Although this isn't compatible with vForth (or vs. versa) it's not hard to get it to run.

It was incrementally, interactively, tested as is the way with Forth. 


## Other information

### Compiling the C version

At some point I'll add a comment on how to do it on differnt platforms. But since it's a single file using standard C, I think you should be able to compile this on any standard C machine.

### Running the Lua version

There is a helper script - but I haven't got around to documenting any of this yet.

### License

I've put the source files under GPLv3, although there is a shareware message in the binary. 

Usually my code is under permissive licenses like the MIT license or Zlib-style licenses. If you wnat to do something that you think the GPLv3 won't allow you to do, then tell me what, and we can discuss a change.

### Notes on the name

I've recently become aware of a table-top RPG module that contains a dungeon with a similar name. However, these bear no relationship to this game. I don't think I'd played this specific module *before* writing this game, so this is likely simply a co-incidence. It's a pretty generic name and the words 'Chaos' and 'Caves' popular in the late 70' and early 80's - with Chaos Theory and dungeon crawlers like Colossal Cave.

I'd like to have a written a game called 'Pyramids of Mars' - there was printed magazine type-in game of that name, but I think the author might have got the name (accidentially or otherwise) from the Doctor Who series in 1975.


