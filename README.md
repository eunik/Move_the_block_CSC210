# Move the Block CSC210
This project uses assembly languange, mainly tasm, a 32-bit x86 MS-DOS.  
This project is a small game that requires you to move the scrambled blocks into the right sequence.

## Prerequisites
You will need to install [DosBox](https://www.dosbox.com/download.php?main=1) and set it up correctly. [Link](https://www.dosbox.com/wiki/Basic_Setup_and_Installation_of_DosBox)

## Running the Program
```
tasm block_game.asm
tlink block_game/t
block_game
```

## Instructions
```
The keys are the arrow keys and it will exit at esc or if you win.

--------------How to Play---------------
THE CURSOR WILL BE STUCK TO THE BLANK CELL!!!
You will switch the position of your blank with the number
above, below, left, or right of the blank using the keys.
In other words, the number will take previous place of the
blank. Inversly, same is applied to the blank and that number.
Place number in order from left->right.

I was able to get it:
-To draw table.
-Colored in checker pattern.
-Move cursor.
-Move number.
-Check win/lose.

Enjoy the game.
```
