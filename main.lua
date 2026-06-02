function _config()
  return { name = "Game", game_id = "com.usagiengine.YOURGAMENAME" }
end

local radius = 35
local accel = 0.5
local centW = usagi.GAME_W / 2
local centH = usagi.GAME_H / 2
local starNum = 50
local ellRot = 0
local shapes = {}
local stars = {}

print(usagi.SPRITE_SIZE)

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
end

function RotVal(dt)
  ellRot += dt
  if ellRot >= 360 then
    ellRot = 0
  end
  return ellRot
end

function DrawingTing(typeInput)
  local newTing = {
    type = typeInput,
    tingX = centW,
    tingY = centH,
    speed = 0,
    mov = false,
    rotVal = 0
  }
  table.insert(shapes, newTing)
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
    shapes[1].mov = true
    shapes[1].speed -= accel - dt
    if shapes[1].speed < -10 then
      shapes[1].speed = -10
    end
    shapes[1].tingX += shapes[1].speed
  end
  if input.released(input.LEFT) then
    shapes[1].mov = false
  end
  if input.pressed(input.RIGHT) or input.held(input.RIGHT) then
    shapes[1].mov = true
    shapes[1].speed += accel + dt
    if shapes[1].speed > 10 then
      shapes[1].speed = 10
    end
    shapes[1].tingX += shapes[1].speed
  end
  if input.released(input.RIGHT) then
    shapes[1].mov = false
  end
  if shapes[1].mov == false then 
    if shapes[1].speed > 0 then
      shapes[1].speed -= accel
      if shapes[1].speed < 0 then
        shapes[1].speed = 0
      end
    else if shapes[1].speed < 0 then
      shapes[1].speed += accel
      if shapes[1].speed > 0 then
        shapes[1].speed = 0
      end
    end
    end
    shapes[1].tingX += shapes[1].speed
  end
end

function _update(dt)
  LeftRight(dt)
  while #stars < starNum do
    MakeStars()
  end
  for i=#stars, 1, -1 do
    if stars[i].tingX <= 0 then
      table.remove(stars, i)
    else
      stars[i].tingX -= stars[i].speed
    end
  end
  --State.timer += dt
  shapes[1].rotVal = RotVal(dt)
  --print(State.timer)
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  gfx.text("Hello, Usagi!", 10, 10, gfx.COLOR_WHITE)
  for i=1, #shapes do
    -- I know I can make this work
    --gfx.shapes[1].type(shapes[1].tingX, shapes[1].tingY, radius, gfx.COLOR_GREEN)
    
    --gfx.sspr_ex(sx, sy, sw, sh, dx, dy, dw, dh, flip_x, flip_y, rotation, tint, alpha)
    local radNum = shapes[1].rotVal
    gfx.sspr_ex(0, 16, 16, 16, shapes[1].tingX, shapes[1].tingY, 16, 16, false, false, math.rad(radNum), gfx.COLOR_WHITE, 1.0)
  end
  for i=1, #stars do
    gfx.px(stars[i].tingX, stars[i].tingY, gfx.COLOR_WHITE)
  end
end