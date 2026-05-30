function _config()
  return { name = "Game", game_id = "com.usagiengine.YOURGAMENAME" }
end

local radius = 35
local speed = 1
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
  }
  table.insert(shapes, newTing)
end

function _update(dt)
  if input.pressed(input.LEFT) or input.held(input.LEFT) then
    print("registered")
    shapes[1].tingX -= speed
  end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  gfx.text("Hello, Usagi!", 10, 10, gfx.COLOR_WHITE)
  local shpLng = #shapes
  for i=1, shpLng do
    print("screaming")
    print(shapes[i].tingX)
    -- I know I can make this work
    --gfx.shapes[1].type(shapes[1].tingX, shapes[1].tingY, radius, gfx.COLOR_GREEN)
    gfx.circ(shapes[1].tingX, shapes[1].tingY, radius, gfx.COLOR_GREEN)
  end
end