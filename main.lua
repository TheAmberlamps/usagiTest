function _config()
  return { name = "Game", game_id = "com.usagiengine.YOURGAMENAME" }
end

local radius = 35
local timeInt = 1
local colVal = 1
local sprWid = 16
local subVal = true
local accel = 0.25
local centW = usagi.GAME_W / 2
local centH = usagi.GAME_H / 2
local starNum = 50
local ellRot = 0
local shapes = {}
local weapon = {}
local stars = {}

function _init()
  -- Live reload preserves globals across saved edits but resets locals.
  -- Stash mutable game state in a capitalized global like `State` so it
  -- survives reloads; F5 calls _init again to reset.
  State = {
    timer = 0
  }
    while  #stars < starNum do
      MakeStars(1)
    end
  DrawingTing('circ')
  AntiMatter(usagi.GAME_W - usagi.GAME_W / 4, usagi.GAME_H / 2)
end

function RotVal(dt, interval)
  ellRot += dt + interval
  if ellRot >= 360 then
    ellRot = ellRot - 360
  end
  return math.rad(ellRot)
end

function FlipNum(interval)
  if subVal then
    sprWid -= interval
  else
    sprWid += interval
  end
  if sprWid >= 16 then
    subVal = true
  end
  if sprWid <= 1 then
    subVal = false
  end
  return sprWid
end

function GravEf(sub, obj)
  local subject = sub
  local object = obj
  if subject.tingX > object.tingX then
    subject.tingX -= object.mass
  end
end

function ColourShift(col)
  local colNum = col
  if colNum > 16 then
    colNum = 1
  else
    colNum += 1
  end
  colVal = colNum
  return colNum
end

function DrawingTing(typeInput)
  local newTing = {
    type = typeInput,
    centSize = 5,
    mass = 1,
    tingX = centW,
    tingY = centH,
    speedX = 0,
    speedY = 0,
    movX = false,
    movY = false,
    flipVal = sprWid,
    rotVal = 0
  }
  table.insert(shapes, newTing)
end

function AntiMatter(x, y)
  local AMSprite = {
    radius = 2.5,
    tingX = x,
    tingY = y,
    speed = 0,
    color = ColourShift(0)
  }
  table.insert(weapon, AMSprite)
end

function MakeStars(num)
  local star = {
    tingX = usagi.GAME_W + 1,
    tingY = math.random(usagi.GAME_H),
    speed = math.random(1, 3)
  }
  if num then
    star.tingX = math.random(1, usagi.GAME_W)
  end
  table.insert(stars, star)
end

function LeftRight(dt)
  if input.pressed(input.LEFT) or input.held(input.LEFT) then
    shapes[1].movX = true
    shapes[1].speedX -= accel - dt
    if shapes[1].speedX < -10 then
      shapes[1].speedX = -10
    end
    shapes[1].tingX += shapes[1].speedX
  end
  if input.released(input.LEFT) then
    shapes[1].movX = false
  end
  if input.pressed(input.RIGHT) or input.held(input.RIGHT) then
    shapes[1].movX = true
    shapes[1].speedX += accel + dt
    if shapes[1].speedX > 10 then
      shapes[1].speedX = 10
    end
    shapes[1].tingX += shapes[1].speedX
  end
  if input.released(input.RIGHT) then
    shapes[1].movX = false
  end
  if shapes[1].movX == false then 
    if shapes[1].speedX > 0 then
      shapes[1].speedX -= accel
      if shapes[1].speedX < 0 then
        shapes[1].speedX = 0
      end
    else if shapes[1].speedX < 0 then
      shapes[1].speedX += accel
      if shapes[1].speedX > 0 then
        shapes[1].speedX = 0
      end
    end
    end
    shapes[1].tingX += shapes[1].speedX
  end
  if shapes[1].tingX - shapes[1].centSize <= 0 then
    shapes[1].tingX = 0 + shapes[1].centSize
    shapes[1].speedX = -shapes[1].speedX

  end
  if shapes[1].tingX + shapes[1].centSize >= usagi.GAME_W then
    shapes[1].tingX = usagi.GAME_W - shapes[1].centSize
    shapes[1].speedX = -shapes[1].speedX
  end
end

function UpDown(dt)
  if input.pressed(input.UP) or input.held(input.UP) then
    shapes[1].movY = true
    shapes[1].speedY -= accel - dt
    if shapes[1].speedY < -10 then
      shapes[1].speedY = -10
    end
    shapes[1].tingY += shapes[1].speedY
  end
  if input.released(input.UP) then
    shapes[1].movY = false
  end
  if input.pressed(input.DOWN) or input.held(input.DOWN) then
    shapes[1].movY = true
    shapes[1].speedY += accel + dt
    if shapes[1].speedY > 10 then
      shapes[1].speedY = 10
    end
    shapes[1].tingY += shapes[1].speedY
  end
  if input.released(input.DOWN) then
    shapes[1].movY = false
  end
  if shapes[1].movY == false then 
    if shapes[1].speedY > 0 then
      shapes[1].speedY -= accel
      if shapes[1].speedY < 0 then
        shapes[1].speedY = 0
      end
    else if shapes[1].speedY < 0 then
      shapes[1].speedY += accel
      if shapes[1].speedY > 0 then
        shapes[1].speedY = 0
      end
    end
    end
    shapes[1].tingY += shapes[1].speedY
  end
  if shapes[1].tingY - shapes[1].centSize <= 0 then
    shapes[1].tingY = 0 + shapes[1].centSize
    shapes[1].speedY = -shapes[1].speedY

  end
  if shapes[1].tingY + shapes[1].centSize >= usagi.GAME_H then
    shapes[1].tingY = usagi.GAME_H - shapes[1].centSize
    shapes[1].speedY = -shapes[1].speedY
  end
end

function _update(dt)
  LeftRight(dt)
  UpDown(dt)
  GravEf(weapon[1], shapes[1])
  while #stars < starNum do
    MakeStars()
  end
  for i=1, #weapon do
    weapon[1].speed += shapes[1].mass
  end
  for i=#stars, 1, -1 do
    if stars[i].tingX <= 0 then
      table.remove(stars, i)
    else
      stars[i].tingX -= stars[i].speed
    end
  end
  shapes[1].rotVal = RotVal(dt, timeInt)
  shapes[1].flipVal = FlipNum(0.5)
  weapon[1].color = ColourShift(colVal)
end 

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  gfx.text("Hello, Usagi!", 10, 10, gfx.COLOR_WHITE)
  for i=1, #shapes do
    -- I know I can make this work
    --gfx.shapes[1].type(shapes[1].tingX, shapes[1].tingY, radius, gfx.COLOR_GREEN)
    gfx.sspr_ex(0, 0, 16, 16, shapes[1].tingX - shapes[1].flipVal, shapes[1].tingY - 16, shapes[1].flipVal * 2, 16 * 2 , false, false, shapes[1].rotVal, gfx.COLOR_WHITE, 1.0)
    gfx.circ_fill(shapes[1].tingX, shapes[1].tingY, shapes[1].centSize, gfx.COLOR_WHITE)
  end
  for i=1, #weapon do
    gfx.circ_fill(weapon[i].tingX, weapon[i].tingY, weapon[i].radius, weapon[1].color)
  end
  for i=1, #stars do
    gfx.px(stars[i].tingX, stars[i].tingY, gfx.COLOR_WHITE)
  end
end