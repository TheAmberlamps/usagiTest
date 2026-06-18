function _config()
  return { name = "Game", game_id = "com.usagiengine.YOURGAMENAME" }
end

local radius = 35
local timeInt = 1
local colVal = 1
local sprWid = 16
local subVal = true
local accel = 0.25
local gameW = usagi.GAME_W
local gameH = usagi.GAME_H
local centW = usagi.GAME_W / 2
local centH = usagi.GAME_H / 2
local starNum = 50
local ellRot = 0
local shapes = {}
local arrow = {}
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

function Rounder(val)
  if type(val) == "string" then
    return type(val)
  else
    return tostring(math.floor(val + 0.5))
  end
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
  local wep = sub
  local player = obj
  if wep.tingX > player.tingX then
    wep.speedX -= player.mass
    wep.tingX += wep.speedX
  end
  if wep.tingX < player.tingX then
    wep.speedX += player.mass
    wep.tingX += wep.speedX
  end
  --print(wep.speedX)
  if wep.tingY > player.tingY then
    wep.speedY -= player.mass
    wep.tingY += wep.speedY
  end
  if wep.tingY < player.tingY then
    wep.speedY += player.mass
    wep.tingY += wep.speedY
  end
end

--gfx.text(text, x, y, color)
--gfx.text_ex(text, x, y, scale, rotation, color, alpha)

function ArrowMaker(ting, w)
  function GetDist(dir, w)
    local origin = {0, 0}
    local dest = {0, 0}
    dest[1] = w.tingX
    print(dest)
    dest[2] = w.tingY
    --util.vec_normalize({x, y})
    --dest = util.vec_normalize(dest)
    --print(dest)
  end
  local data = ting
  local len = 10
  arrow = {}
  if data == "IN" then
    return
  end
  local wep = w
  local nA = {
    x1 = 0,
    y1 = 0,
    x2 = 0,
    y2 = 0,
    x3 = 0,
    y3 = 0,
    tX = 0,
    tY = 0,
    dText = ''
  }
  if data == "tL" or data == "l" or data == "bL" then
    if data == "tL" then
      nA.x2 = len
      nA.y3 = len
    elseif data == "bL" then
      nA.x3 = 10
      nA.y1 = gameH
      nA.y2 = gameH - len
      nA.y3 = gameH
    else
      nA.y1 = wep.tingY
      nA.x2 = len
      nA.x3 = len
      nA.y2 = wep.tingY - len
      nA.y3 = wep.tingY + len
      nA.tX = centW
      nA.tY = centH
      nA.dText = -wep.tingX
    end
  end
  if data == 'tR' or data == "r" or data == "bR" then
    nA.x1 = gameW
    GetDist(data, wep)
    if data == 'tR' then
      nA.x2 = gameW
      nA.y2 = len
      nA.x3 = gameW - len
    elseif data == 'bR' then
      nA.y1 = gameH
      nA.x2 = gameW - len
      nA.y2 = gameH
      nA.x3 = gameW
      nA.y3 = gameH - len
    else
      nA.y1 = wep.tingY
      nA.x2 = gameW - len
      nA.y2 = wep.tingY + len
      nA.x3 = gameW - len
      nA.y3 = wep.tingY - len
      nA.tX = centW
      nA.tY = centH
      nA.dText = wep.tingX - gameW
    end
  end
  if data == "u" then
    nA.x1 = wep.tingX
    nA.x2 = wep.tingX + len
    nA.y2 = len
    nA.x3 = wep.tingX - len
    nA.y3 = len
    nA.tX = centW
    nA.tY = centH
    nA.dText = -wep.tingY
  end
  if data == "d" then
    nA.x1 = wep.tingX
    nA.y1 = gameH
    nA.x2 = wep.tingX - len
    nA.y2 = gameH - len
    nA.x3 = wep.tingX + len
    nA.y3 = gameH - len
    nA.tX = centW
    nA.tY = centH
    nA.dText = wep.tingY - gameH
  end
  table.insert(arrow, nA)
end

function WeaponTracker(ting)
  local wep = ting
  if wep.tingX > 0 and wep.tingX < gameW and wep.tingY > 0 and wep.tingY < gameH then
    return "IN"
  end
  if wep.tingX < 0 and wep.tingY < 0 then
    return "tL"
  end
  if wep.tingX < 0 and wep.tingY > gameH then
    return "bL"
  end
  if wep.tingX > gameW and wep.tingY < 0 then
    return "tR"
  end
  if wep.tingX > gameW and wep.tingY > gameH then
    return "bR"
  end
  if wep.tingX > 0 and wep.tingX < gameW then
    if wep.tingY < 0 then
      return "u"
    end
    if wep.tingY > gameH then
      return "d"
    end
  end
  if wep.tingY > 0 and wep.tingY < gameH then
    if wep.tingX < 0 then
      return "l"
    end
    if wep.tingX > gameW then
      return "r"
    end
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
    mass = 0.1,
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
    speedX = 0,
    speedY = 0,
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
  ArrowMaker(WeaponTracker(weapon[1]), weapon[1])
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
  for i=1, #arrow do
    gfx.tri_fill(arrow[1].x1, arrow[1].y1, arrow[1].x2, arrow[1].y2, arrow[1].x3, arrow[1].y3, gfx.COLOR_WHITE)
    gfx.text(Rounder(arrow[1].dText), arrow[1].tX, arrow[1].tY, gfx.COLOR_RED)
    -- this is the place to run a dedicated drawing function that should rely on the same arguments to display how far outside of the screen the 'weapon' is
    -- leave drawing for the draw loop and updates for the update loop; update data then draw it
  end
  for i=1, #stars do
    gfx.px(stars[i].tingX, stars[i].tingY, gfx.COLOR_WHITE)
  end
end