#include <stdio.h>
#include <stdlib.h>

/* NOTE: my random (x_rand) is included at the bottom of THIS source */

/* CAVES OF CHAOS [RELEASE VERSION]
 * ===============-------> A little RPG
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
 *   v1.28-c99 - Converted to C99, 4 May 2024, Rob Probin.
 *
 */

/* NOTE ABOUT STRUCTURE
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
 */

//
// Function prototypes
//
int x_rand(int dice);
void message(void);
void setmap(void);
void goroom(int px, int py,char** namepp, int* monhit, int* omonhit);
void rmintro(int t, int g, int l, int c, char* b, int m);
int pdeath(int hp, int level, int gold);
void mondeath(int x, int y, char* monname, int oldhp, int* gold);
void heal(int* gold, int* hp);
int innum(void);
void newlvl(int* count, int* l, int* l2, int* t);
void pmove(int* x, int* y, int l, int* ox, int* oy, int mo);
int foptions();
void castop(int in, int* monhit, int* playerhp, int* pdamage);
void moncast(int x, int y, char* namestr, int* manhp, int* mhit, int* level, int* j);
void fighting(int mdamage, int pdamage, int* monhp, int* playerhp, char* name, int* count, int* mo);
int gend(int gold, int lev2, int hp);

#define getch() getchar()		// emulate getch (MacOS X change)

/*
 *-- Hidem & array definition -
 *
Hidem
 *
 */

int z[11][11][10];	/* Monster in room data - note all zero indices not
			   used so infact [10][10][9] */
int m[6];		/* Man spell list m[0] not used */



/*
 *
 * MAIN PROGRAM BLOCK
 *
 */

int main(void)
{
int count,x,y,ox,oy,l,l2,mo,t,g,v,j,multi;
int i,a;			/* general variables */
char *nameptr;			/* pointer to the name string */
int mhit,omhit;			/* monster hit points and original */

do
{
  /************* start (new game) *************/
  message();
  setmap();

  /*
   * - Data setup -
   */
  m[1]=10;
  m[2]=2;
  m[3]=2;
  m[4]=1;
  m[5]=3;		/* players initial spells */
  count=0;		/* number of monnster killed this level */

  x=1;			/* players X position */
  y=10;			/* players Y position */
  ox=x;			/* players old X */
  oy=y;			/* players old Y - where to run to */
  l=1;			/* players level that can be drained */
  l2=1;			/* players True Level */
  mo=100;		/* current number of monsters */
  t=10;			/* players hit points */
  g=0;			/* players Gold */
  multi=0;		/* Multiple fight off */
  /* End of Data Setup */

do
{
  /********** Re-read room data **************/
  v=1;			/* players hit strength */
  j=1;			/* monsters hit strength */

  goroom(x,y,&nameptr,&mhit,&omhit);	/* generate monster in room */

do
{
  /******* fight sequence repeat, same room **************/

  rmintro(t,g,l,mhit,nameptr,multi);		/* intro to room */

  i=pdeath(t,l,g);	/* player death (i 0=continue 1=goto start 2=stop) */
		/* not from this routine but i=3 re-read room, i=4 same room */


/************ FIGHT/RUN/MONSTER DEATH/SPELL CASTING **********************/

if(!i)		/* dont skip if i=0, other values of i loop or stop game */
  {
  /* Is this rooms monster dead? */
  if(!mhit)				/* if monster dead mon hp = 0 */
    /* Monster dead */
    {

    /* Are there any monsters left ? */
    if(mo==0)
      /* If no monsters, player has completed game */
      {
      a=gend(g,l2,t);			/* completion message */
      if(a=='1') i=1;			/* run again */
      else i=2;				/* else stop */
      }
    else
      /* otherwise monster death and player movement */
      {
      multi=0;                         /* multiple fight off */
      mondeath(x,y,nameptr,omhit,&g);	/* tell player monster dead */
      heal(&g,&t);				/* option to heal */
      newlvl(&count,&l,&l2,&t);			/* check for new player level */

      pmove(&x,&y,l,&ox,&oy,mo);		/* player movement */
      i=3; 		/* i=3, player moved - re-read room */
      }
    }
  else		
    /* monster in this room is still alive */
    {

    if(multi==0)
    {
    a=foptions();			/* get what fight options are wanted */
    if(a=='m' || a=='M')
      {
      printf("Fight for many rounds...\n\n");
      printf("Please enter number of rounds to fight : ");
      multi=innum();
      if(multi<1) multi=1;
      multi-=1;
      }
    }
    else
    {
    multi-=1;
    a='M';
    }

    if(a=='F' || a=='f') printf(" Fight\n");

    if(a=='R' || a=='r')
      /* option chosen was RUN option */
      {
      printf(" Run\n\n\n");
      t-=1;	/* loose one hit point for running (chicken alert!!!!) */
      z[x][y][2]=mhit;	/* store this monsters hit points */
      x=ox;
      y=oy;	/* move to last position - must have dead monster in it */
      i=3; /* player moved, re-read room */
      }
    else
      /* spells and fighting */
      {
      castop(a,&mhit,&t,&v);	/* check and do player spell casting */
      if(mhit!=0)
        {
        moncast(x,y,nameptr,&t,&mhit,&l,&j);	/* monster casting */
        }
      fighting(j,v,&mhit,&t,nameptr,&count,&mo);	/* real fighting Zzzz */
      i=4;      /* - Monster was alive loop - ie no room change */
      }
    } /* end of monster alive block */
  }  /* end of i==0 block .... next section decides on loop due to i */

/* what does i do?  0=continue(above, not here), 1=goto start, 2=stop,
 *			3=re-read room, 4=same room 
 *
 *			Note on i=0, pdeath does not know what other routines
 *			may re-direct program so i=0 is intermediate state.
 */

} while(i==4); /* same room loop */
} while(i==3); /* new room loop */
} while(i==1); /* new game */

} /* end of main */


/* message
 *
 * - Screen start section -
 *
 */

void message(void)
{
printf("\n\nCaves Of Chaos      -      A little Fantasy RPG\n");
printf("         ... or something like that!!!\n\n");
printf("Copyright 1990-2001 Rob (Zed) Probin (The road goes on forever....)");
printf("\nCONTACT: rob@zedworld.demon.co.uk  or  http://www.lightsoft.co.uk\n");
printf("Copies of this program may be made for NO CHARGE\n");
printf("SHAREWARE -- CHARGE FOR USE => Spread EVERYWHERE\n");
printf("Original written in GFA Basic V2 (by Zed)\n");
printf("Original version in C (7/5/92 & 12/2/93-Release modification)\n");
printf("Mac OS X version 13th August 2001. \n\n");
printf("Now the game.....       (v1.28-c99)\n\n");
}


/* - Room occupation by monsters - */

int data[100] ={11,11,17,12,12, 9,16,22,10,20,
	       14,11,11,17,12,12, 9,15,22,10,
	       14,14,11,11,12,12, 9,16,15,15,
	       14,14,21,05,05,12, 9, 9,16,16,
	       07,25,05,05,05,13, 9,19, 9, 9,

	       18,25,05,21,05,13,13,13,17,17,
	       21,05,05,05,05,23,23,23,25,07,
	       03,03,05, 8, 8,18,24,24,25,25,
	       02,04,06,05, 8, 8,24,07,25,19,
	       01,06,04,04, 8,18,07,25,23,9};

/* setmap
 *
 * - Map set up routine -
 *
 */
void setmap(void)
{
int x,y,*ptr;
ptr=data;
    for(y=1 ; y!=11 ; y++)
    {
	for(x=1 ; x!=11 ; x++)
	{
	z[x][y][1] = *(ptr++);
	z[x][y][2] = -1;
	}
    }
}


/* - Monster data - */

char monname[]="Kobold\0Light Bulb\0Giant Fly\0Slime\0Super Rat\0\
Skeleton\0Vampire\0Purple Worm\0Demon\0Dragon\0Orc\0Bear\0Gargoyle\0\
Elf\0Giant Scorpion\0Troll\0Giant Snake\0Wolf\0Bat\0Destroyer\0Zombie\0\
Hill Giant\0Werewolf\0Ogre\0Goblin\0";

int mondata[176]={1,0,0,0,0,0,0,	2,2,0,0,0,0,0,
		  3,0,0,0,0,0,0,	4,0,0,0,0,0,0,
		  23,0,0,0,0,0,0,	2,0,0,0,0,0,0,
		  20,0,0,0,2,0,0,	5,0,0,0,0,0,0,
		  50,20,1,0,0,0,0,	150,10,5,0,0,0,0,
		  25,0,0,0,0,0,0,	30,0,0,0,0,0,0,
		  57,0,0,0,0,0,0,
		  9,0,5,0,0,0,0,	90,10,0,0,0,0,0,
		  120,0,0,8,0,2,0,	26,0,0,0,0,0,0,
		  10,0,0,0,0,0,0,	8,0,0,0,0,0,0,
		  200,20,10,10,10,20,2,	10,0,0,0,0,0,0,
		  135,0,0,0,0,2,0,	35,0,0,2,0,0,0,
		  18,0,0,0,0,6,0,	15,0,0,0,0,0,0, -1};

/*
 * - Get room and monster data for this room -
 *
 */
void goroom(int px, int py,char** namepp, int* monhit, int* omonhit)
// monhit omonhit	/* pointer to monter hit points and pointer to
//          			   original monster hit pointer */
// namepp;		/* this is the pointer to the name pointer */
{

int n;			/* holds monster number */
int *mdata;		/* pointer to monster data */

mdata=mondata;		/* make pointer point to mon data array */
n=z[px][py][1];		/* get the monster in this room */

if(!n)			/* if monster number=0 error */
  {
  printf("ERROR 1 - MONSTER DATA IN ERROR\n");
  exit(0);
  }

mdata += (n-1)*7;	/* point to correct set of data */
*namepp = monname;	/* make the name pointer point to the name list
			   via the name pointer pointer */


while(**namepp!='\0' && n!=1)	/* loop while not end of list and no at 
				   correct place */
  {
  while(*((*namepp)++)!='\0');	/* empty loop to find '\0' */

			/* this is NOT in the inner loop */
  n--;				/* one item forward */

  }


if(**namepp=='\0')		/* double \0 indicates end of list */
  {
  printf("ERROR 2 - END OF NAME STRING REACHED\n");
  exit(0);
  }


if(z[px][py][2]!=-1)		/* if not first time player been in this room */
  {
  *monhit=z[px][py][2];		/* fetch monster hit points from old visit */
  *omonhit=z[px][py][3];	/* and original hit points */
  }
else
  {
  z[px][py][2]=*(mdata++);	/* hit points from monster list */
  *monhit=z[px][py][2];		/* hit point into variable as well */
  *omonhit=*monhit;		/* original hit points variable too */

  z[px][py][3]=*omonhit;	/* in store as well */

  z[px][py][4]=*(mdata++);	/* get monster spells and put in store */
  z[px][py][5]=*(mdata++);
  z[px][py][6]=*(mdata++);
  z[px][py][7]=*(mdata++);
  z[px][py][8]=*(mdata++);
  z[px][py][9]=*mdata;
  }
}		/* end of goroom() */


/*
 * - Room intro text -
 */
void rmintro(int t, int g, int l, int c, char* b, int m)
{
printf("\nYou have %d hit points and %d gold\n",t,g);
if(m==0) printf("You are Level %d\n",l);
printf("Here is a monster with %d hit points called a %s\n",c,b);
}

/*
 * - Player Death text -
 */
int pdeath(int hp, int level, int gold)
{
char c;
int go2;

if(hp<1 || level==0)
  {
  printf("You have died\n");
  printf("You had %d gold when you died\n\n",gold);
  printf("Press Y to play again, or type N to stop. \n");
  printf("? ");
  do
    c=getch();
  while(c!='Y' && c!='y' && c!='N' && c!='n');

  if(c=='Y' || c=='y')
    {
    printf("Yes please !!!\n\n");
    go2=1;
    }
  else
    {
    printf("No, not again\n\n");
    go2=2;
    }
  }
else
  go2=0;	/* go2, 0=continue 1=goto start 2=stop */

return (go2);
}



/*
 * - Monster Death text -
 */

void mondeath(int x, int y, char* monname, int oldhp, int* gold)
{
  printf("The %s is Dead\n",monname);
  printf("You find %d Gold\n\n",oldhp);

  z[x][y][2]=0;
  z[x][y][3]=0;
  *gold+=oldhp;
}

/*
 * - Heal Routine -
 */
void heal(int* gold, int* hp)
{
char a;
int num;

  printf("Do you wish to Heal(Type H) or continue(Type C)\n\n? ");
  do
  a=getch();
  while(a!='H' && a!='h' && a!='C' && a!='c');

  if(a=='H' || a=='h')
    {
    printf("Heal\nHealing: (10 gold = 1 hp)");
    do
    {
      printf("\nType Hit points to be healed: ");

      num=innum();

      if((num*10)>*gold || num<0)
      {
        printf("\nNot Enough Money!!\n");
        printf("Type zero not to heal\n");
        num=-1;
      }
    } while(num<0);
  *gold-=num*10;
  *hp+=num;
  }

  else printf("Continue\n");

}


/* Allows input of a number */
int innum(void)
{		/* return type int */
int i,c;

do
  i=getchar()-'0';
while(i<0 || i>9);		/* first numeric character */

do
{
  c=getchar()-'0';
  i=i*10+c;
}
while(c>=0 && c<=9);		/* until last number character */
i=(i-c)/10;			/* get rid of non numeric char */

return i;
}

/*
 * - New level -
 */
void newlvl(int* count, int* l, int* l2, int *t)
{
int a;
  if(*count==10)
  {
    printf("\nYou Gain a level!!!\n");
    printf("\n          YOU COCKY BLEEDER\n");	/* Pauls sentence!! */
    printf("You gain 10 hp\n");
    printf("You gain 5 spells!\n\n");
    for(a=1 ; a<6 ; a++)
      m[a]++;	/* BASIC version had random selection of 5 spells */

    *l+=1;
    *l2+=1;
    *t+=10;
    *count=0;
  }
}


/*
 * Player move around
 */
void pmove(int* x,int* y, int l, int* ox,int* oy, int mo)
{

char c;


  printf("\nYou may go ");

  if(*x!=1) printf("West (Type W) or ");
  if(*x!=10) printf("East (Type E) or ");
  if(*y!=10) printf("South (Type S) or ");
  if(*y!=1) printf("North (Type N)");
  printf("\nor Wait (Type Q)");

  if(l>3) printf(" or Check the number of Monsters (Type M).\n");
  else printf(".\n");

    printf("\nDirection >");
  do {
    c=getch();
  } while(c!='N' && c!='n' && c!='S' && c!='s' && c!='E' && c!='e' && c!='W'
&& c!='w' && c!='Q' && c!='q' && c!='M' && c!='m');

  *ox=*x;
  *oy=*y;

  if((c=='N' || c=='n') && *y!=1)
    {
    printf("\n\nYou head North");
    *y-=1;
    }
  if((c=='S' || c=='s') && *y!=10)
    {
    printf("\n\nYou head South");
    *y+=1;
    }
  if((c=='W' || c=='w') && *x!=1)
    {
    printf("\n\nYou head West");
    *x-=1;
    }
  if((c=='E' || c=='e') && *x!=10)
    {
    printf("\n\nYou head East");
    *x+=1;
    }

  if(c=='Q' || c=='q') printf("\n\nYou stay where you are");

  if((c=='M' || c=='m') && l>3) printf("\n\nThere are %d monsters",mo);

  printf("\n\n");


/* player moved, re-read room */
}




/* - Player fight options - */
int foptions(void)
{
int c;

printf("\nType R to run, F to fight once, M to fight many times");
printf(" or S to Cast Spell\n");
printf("What do you wish to do? ");

do
  c=getch();
while(c!='r' && c!='R' && c!='f' && c!='F' && c!='s' && c!='S' && c!='m' && c!='M');

return c;
}

/* - Cast option - */
void castop(int in, int* monhit, int* playerhp, int* pdamage)
{
int i;


if(in=='S' || in=='s')
  {
  printf(" Cast spell\n\n");
  if(m[1]!=0) printf("Type 1 to cast an Ice Dart (%d left)\n",m[1]);
  if(m[2]!=0) printf("Type 2 to cast a Fireball (%d left)\n",m[2]);
  if(m[3]!=0) printf("Type 3 to cast Regenerate (%d left)\n",m[3]);
  if(m[4]!=0) printf("Type 4 to cast Drain level (%d left)\n",m[4]);
  if(m[5]!=0) printf("Type 5 to cast Gain Strength (%d left)\n",m[5]);
  printf("Type 6. to not cast a spell\n");

  do
  {
    do
    {
    printf("\nWhich Magic Spell? ");
    i=innum();
    } while(i<1 || i>6);

  } while(i!=6 && m[i]==0);

  /* actual spell activation */

  if(i==1)
      {
      *monhit-=1;
      printf("\nYou cast an Ice Dart\n");
      m[1]-=1;
      }
  if(i==2)
      {
      *monhit-=10;
      printf("\nYou cast a Fireball\n");
      m[2]-=1;
      }
  if(i==3)
      {
      *playerhp+=10;
      printf("\nYou cast Regenerate\n");
      printf("You fell stronger\n");
      m[3]-=1;
      }
  if(i==4)
      {
      *monhit-=20;
      printf("\nYou cast Drain Level\n");
      m[4]-=1;
      }
  if(i==5)
      {
      *pdamage+=1;
      printf("\nYou cast Gain Strength\n");
      m[5]-=1;
      }
  }
}

/* - Monster cast - */
void moncast(int x, int y,char* namestr, int* manhp, int* mhit, int* level, int* mdamage)
{
int k;

k=x_rand(6);

if(k==0 && z[x][y][4]!=0)
  {
  z[x][y][4]-=1;
  printf("\nThe %s casts an Ice dart\n",namestr);
  *manhp-=1;
  }

if(k==1 && z[x][y][5]!=0)
  {
  z[x][y][5]-=1;
  printf("\nThe %s casts a Fireball\n",namestr);
  *manhp-=10;
  }

if(k==2 && z[x][y][6]!=0)
  {
  z[x][y][6]-=1;
  printf("\nThe %s casts Regenerate\n",namestr);
  *mhit+=10;
  }

if(k==3 && z[x][y][7]!=0)
  {
  z[x][y][7]-=1;
  printf("\nThe %s casts Drain level\n",namestr);
  *manhp-=10;
  *level-=1;
  }

if(k==4 && z[x][y][8]!=0)
  {
  z[x][y][8]-=1;
  printf("\nThe %s casts Gain Strength\n",namestr);
  *mdamage+=1;
  }

if(k==5 && z[x][y][9]!=0)           // bug fix 10-Nov-2003 by Rob, spotted by Stu :-(
  {
  z[x][y][9]-=1;
  printf("\nThe %s casts MEGA DEATH\n",namestr);
  printf("Oh S**t!!!\n");
  *manhp-=50;
  }
}




/* - General fight - */
void fighting(int mdamage, int pdamage,int* monhp, int* playerhp, char* name, int* moncount, int* nummon)
{
int k;

printf("\n");
k=x_rand(20)-9-mdamage*5+pdamage*5;

if(*monhp+k>*playerhp)
  {
  *playerhp-=mdamage;
  printf("The %s hits you for %d",name,mdamage);
  }
else
  {
  *monhp-=pdamage;
  printf("You hit the %s for %d",name,pdamage);
  }

if(*monhp<1)
  {
  (*nummon)--;
  *moncount+=1;
  *monhp=0;
  }

printf("\n\n");
}



/* - Completed Mission - */
int gend(int gold, int lev2, int hp)
{
int a;

printf("You find 2000 gold pieces!!!!!!\n");
printf("\n\nYou have completed your mission by clearing the Caves of Chaos");

gold+=2000;
lev2+=1;
printf("\n\nYou completed the game with %d gold pieces.\n",gold);
printf("You have your levels restored and are at the ultimate level, %d.",lev2);
printf("\nYou had %d hps at the end.\n\n",hp);
printf("CONGRATULATIONS!!!!  (Tell Rob!!!)\n\n");

do
{
  printf("Type 1 to run again, or 2 to Quit ");
  a=getchar();

} while(a!='1' && a!='2');

return a;
}




/* random stuff */

static long x_seed=3456;

/* Random Number Generator by Rob (ZED) Probin 4/7/92 */
/* using mod function sequence */

int x_rand(int dice)
{

long x;

x=75*(x_seed+1);			/* basic random sequence */
x%=65537;				/* then find remainder */

x_seed=--x;				/* next seed new random number*/
x*=(long)dice;				/* make sure in wanted dice range */
x/=65536;				/* change to correct scale last*/

return (int)x;

}
