--JANTZEN WELLS AND JOHN BROPHY
--ICYWINGS


camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0

--functions for the camera class that controls what the player sees
function camera:set()
  love.graphics.push()
  love.graphics.rotate(-self.rotation)
  love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
  love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
  love.graphics.pop()
end

function camera:move(dx, dy)
  self.x = self.x + (dx or 0)
  self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
  self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
  sx = sx or 1
  self.scaleX = self.scaleX * sx
  self.scaleY = self.scaleY * (sy or sx)
end

function camera:setPosition(x, y)
  self.x = x or self.x
  self.y = y or self.y
end

function camera:setScale(sx, sy)
  self.scaleX = sx or self.scaleX
  self.scaleY = sy or self.scaleY
end

--generates 2,000 steps of line segments to be joined as "hills"
function generateChunk(objects)

  --generates a random factor for sin
  love.math.setRandomSeed(love.timer.getTime())
  factor = love.math.random(50, 300)

  lasty = 0
  inity = 0
  --we step by 25 in the for loop due to sin math, for some reason anything else makes the hills look awful
  for i = 0,50000,25
  do
    --if we are in position to change hill size, do so by updating the factor
    if math.abs(lasty-inity) < 3 then
      if i > 1 then
        factor = love.math.random(50, 300)
      end
    end

    --creates a new edgeShape (sin() line segment) and polygon (ground)
    objects[i] = {}
    objects[i].body = love.physics.newBody(world, love.graphics.getWidth(), love.graphics.getHeight())
    --EdgeShape positon relies heavily on sin() and factor to create the desired curve
    objects[i].shape = love.physics.newEdgeShape(i, lasty, i+25, (math.sin(i+25)*factor))
    --The "ground" uses similar points except now there's 4 to create the polygon
    objects[i].under = love.physics.newPolygonShape(i, lasty, i+25, (math.sin(i+25)*factor), i, 1250, i+25, 1250)
    lasty = (math.sin(i+25)*factor)

    --set our initial y value for factor changing later
    if i == 1 then
      inity = lasty
    end
    objects[i].fixture = love.physics.newFixture(objects[i].body, objects[i].shape)

  end
end

--this function actually draws the objects that were created earlier using LOVE2D.graphics
function drawChunk(objects)

  for i = 0,50000,25
  do
    --for each object we draw a line, then its corresponsing ground polygon
    love.graphics.line(objects[i].body:getWorldPoints(objects[i].shape:getPoints()))
    love.graphics.setColor(0.13, 0.50, 0.74, 0.26)
    love.graphics.polygon("line",objects[i].body:getWorldPoints(objects[i].under:getPoints()))
    love.graphics.setColor(1, 1, 1)
  end
end

--this function serves to load any external assets and set initial variables for the game
function love.load()

  startGame = false
  gameOver = false

  --we use the newAnimation() function to initialize the png asset as an animation sprite
  animation = newAnimation(love.graphics.newImage("assets/Sprites/penguinidle.png"), 32, 32, 1)
  font = love.graphics.newFont("assets/font/Estave.ttf", 75)
  --1 meter = 64px
  love.physics.setMeter(64)
  -- create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
  world = love.physics.newWorld(0, 9.81*64, true)

  objects = {} -- table to hold all our physical objects

  generateChunk(objects)
  --creates a ball
  objects.ball = {}
  -- place the body in the world and make it dynamic, so it can move around
  objects.ball.body = love.physics.newBody(world, 1250, 200, "dynamic")
  startx = 1250
  -- the ball's shape has a radius of 20
  objects.ball.shape = love.physics.newCircleShape(20)
  -- Attach fixture to body and give it a density of 1.
  objects.ball.fixture = love.physics.newFixture(objects.ball.body,
                                                 objects.ball.shape, 1)
  objects.ball.fixture:setRestitution(0.1) -- let the ball bounce

  --creates all the images needed for background, text, etc.
  back = love.graphics.newImage("assets/Layers/mtn.png")
  title = love.graphics.newImage("assets/Layers/title.png")
  by = love.graphics.newImage("assets/Layers/by.png")
  start = love.graphics.newImage("assets/Layers/start.png")
  over = love.graphics.newImage("assets/Layers/gameover.png")
  tryagain = love.graphics.newImage("assets/Layers/tryagain.png")
  love.window.setMode(1920, 1080, {fullscreen = true, resizable=true, vsync=false, minwidth=400, minheight=300}) -- set the window dimensions to 650 by 650
end

--this function is what sets all the physics into motion and allows our camera and animations to update themselves
function love.update(dt)

if startGame == true then

  --update world object
  world:update(dt)

  currentx = objects.ball.body:getX()
  if gameOver == false then
    distance = math.floor((currentx - startx)/64)
  end
  --step through our animations based on time and duration
  animation.currentTime = animation.currentTime + dt
  if animation.currentTime >= animation.duration then
      animation.currentTime = animation.currentTime - animation.duration
  end

if gameOver == false then
  --down or "s" will force the ball to move
  if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
    objects.ball.body:applyForce(0, 650)
    objects.ball.body:applyForce(100, 0)
  end
end
end

x,y = objects.ball.body:getLinearVelocity()

--detect whether or not the player has met a lose condition
if x < 0 then
  gameOver = true
end

--set camera values to the ball's postion
camera.x = objects.ball.body:getX()+200 - love.graphics.getWidth()/2+200
camera.y = objects.ball.body:getY()-100 - love.graphics.getHeight()/2-100
camera:scale(1, 1)

end

--this function takes all of the information we have calculated and draws it to the screen
function love.draw()

  --draw background
  love.graphics.draw(back)

  --if the game has not started, draw the title screen
  if startGame == false then
    love.graphics.draw(title, love.graphics.getWidth()/2-474/2, 50)
    love.graphics.draw(by, love.graphics.getWidth()/2-448/2, 125)
    love.graphics.draw(start, love.graphics.getWidth()/2-404/2, 200)
  end

  --if the game is over, say game over and provide score
  if gameOver == true then
    love.graphics.draw(over, love.graphics.getWidth()/2-622/2, 25)
    love.graphics.print("Final Score: " .. tostring(distance), font, love.graphics.getWidth()/2-560/2, 135, 0, 1, 1)
    love.graphics.draw(tryagain, love.graphics.getWidth()/2-709/2, 225)
  end

  --in any other case, we print the distance the ball has traveled in meters
  if startGame == true and gameOver == false then
    love.graphics.setColor(0.22, 0.47, 0.93)
    love.graphics.print(distance, font, love.graphics.getWidth()/2-75/2, 50, 0, 1, 1)
  end

  --this code uses the exponential function to zoom the camera smoothly according to a given Y value of the ball
    if objects.ball.body:getY() < 1000 then
      zoom = math.exp(objects.ball.body:getY()/200)+0.3
      if zoom > 0.75 then
        zoom = 0.75
      end
      love.graphics.scale(zoom, zoom)
    else
      love.graphics.scale(0.75, 0.75)
    end

  --initialize the camera
  camera:set()
  -- set the drawing color to white and set line parameters
  love.graphics.setColor(1, 1, 1)
  love.graphics.setLineWidth(25)
  love.graphics.setLineStyle("smooth")

  --pass our objects into our draw function
  drawChunk(objects)

  --this calculates which sprite in a png will be used
  local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1

  love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum], objects.ball.body:getX()-30, objects.ball.body:getY()-30, 0, 2)
  love.graphics.setColor(0, 0, 0.2)
  love.graphics.setColor(1, 1, 1)
  --uninitialize the camera
  camera:unset()
end

--the animation function to seperate and use png images via "quads"
function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end


--some key released and key pressed functions that perform actions
function love.keyreleased(key)
  --quit game
   if key == "escape" then
      love.event.quit()
   end
   --change animation based on key release
   if key == "down" or key == "s" then
      animation = newAnimation(love.graphics.newImage("assets/Sprites/penguinidle.png"), 32, 32, 1)
   end
   --start game with space
   if key == "space" then
      startGame = true
   end
   --restart and reinitialize with backspace
   if key == "backspace" then
      gameOver = false
      startGame = false
      objects.ball.body:setPosition(1250, 200)
      objects.ball.body:setLinearVelocity(0, 0)
   end
end

function love.keypressed(key, scancode, isrepeat)
  --change animation based on key press
  if key == "down" or key == "s" then
    animation = newAnimation(love.graphics.newImage("assets/Sprites/penguinwalk.png"), 32, 32, 0.25)
  end

end
