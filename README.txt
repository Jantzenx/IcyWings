JANTZEN WELLS AND JOHN BROPHY
https://github.com/Jantzenx/IcyWings

About our Project:

  For this project we decided to utilize Lua's strengths for scripting 2D graphics programs by making our own version of the popular iOS game "Tiny Wings"

  In order to accomplish this task we decided to use a free 2D graphics engine called LOVE2D

  All of the source code will be included in submission, including the main.Lua file that is the meat of the code, and this README.

  To make things easier for anyone who wants to play the game, the link above takes you to a github repository that contains not only the game but the LOVE2D engine to run it.

To install (On WINDOWS, I couldn't get LOVE2D to run on Linux due to USNA cert issues):

  1. Go to the link, click the "code" button, and install as a zip file, it's pretty small.

  2. Extract the zip file to somewhere where you can access it.

  3. Open the file, double-click "icywings.exe", and enjoy. (Note: windows will warn you, just click "more info", then run)

Known Bugs and Issues:

  1. There is no finish to the game, the level eventually ends and you fly off the edge, click esc to close the program if this happens. The solution to think would be to generate "chunks"
  of hills relative to player position that dynamically push and pop onto the object stack as you go.

Key Challenges and Implementation:

  Icywings is a simple game, but implementing its gameplay was much more difficult than expected. Every hill is made of many many line segments that follow some variation of the sin() function.
  With enough of these segments, you sacrifice performance for nice smooth hills. This is part of the reason why the level is relatively short, I wanted to keep the smoothness high.

  These hills are seemingly random by the use of a factor that changes the magnitude of the sin() function. In order to make the transitions as smooth as possible, the hills can only change their factor
  when their sin() value reaches a certain position. This was one of the hardest features to implement.

  In order to create the icy "ground", I had to draw polygons that attach to this line segment and fill the space below, giving the illusion of an infinitely deep underground below the hills.

  Everything is modeled using the LOVE2D physics engine, which allowed me to create a world where gravity is represented accurately and acts upon our penguin, which is modeled technically as a
  ball by the physics engine. So, we have a ball affected by gravity that can change its own acceleration via an applied force, which rolls and jumps off our line segment hills.

  Another piece of the puzzle is allowing the user to see where the ball is going. We did this via a camera class that sets the game viewing window to a fixed point, that can scale and move if needed.
  The camera acts on the position of the ball in the physics world, and will scale using the exponential function given the balls Y coordinate as a parameter, which gives the nice zoom effect once a certain
  height is reached after a jump.

  In order to get a score, we just divide the X position of the ball by 64 to get the actual represented distance in meters, then display it.

  Finally, the title and game over "screens" were handled simply by game state flags.
