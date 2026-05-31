function _config()
  return { name = "Game", game_id = "com.usagiengine.YOURGAMENAME" }
end

local radius = 35
local accel = 0.5
local centW = usagi.GAME_W / 2
local centH = usagi.GAME_H / 2
local shapes = {}

function _init()
  -- Live reload preserves globals across saved edits but resets locals.
  -- Stash mutable game state in a capitalized global like `State` so it
  -- survives reloads; F5 calls _init again to reset.
  State = {}
  DrawingTing('circ')
end

function DrawingTing(typeInput)
  local newTing = {
    type = typeInput,
    tingX = centW,
    tingY = centH,
    speed = 0,
    mov = false
  }
  table.insert(shapes, newTing)
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
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  gfx.text("Hello, Usagi!", 10, 10, gfx.COLOR_WHITE)
  local shpLng = #shapes
  for i=1, shpLng do
    -- I know I can make this work
    --gfx.shapes[1].type(shapes[1].tingX, shapes[1].tingY, radius, gfx.COLOR_GREEN)
    gfx.circ(shapes[i].tingX, shapes[i].tingY, radius, gfx.COLOR_GREEN)
  end
end