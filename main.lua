function _config()
  return { name = "Game", game_id = "com.usagiengine.YOURGAMENAME" }
end

local timeInt = 1
local fxTim = true
local baseMass = 2
local colVal = 1
local sprWid = 16
local subVal = true
local accel = 0.25
local gameTime = 0
local gameW = usagi.GAME_W
local gameH = usagi.GAME_H
local centW = usagi.GAME_W / 2
local centH = usagi.GAME_H / 2
local starNum = 50
local ellRot = 0
local arrow = {}

function _init()
  -- Live reload preserves globals across saved edits but resets locals.
  -- Stash mutable game state in a capitalized global like `State` so it
  -- survives reloads; F5 calls _init again to reset.
  State = {
    time = 0,
    player = nil,
    weapon = {},
    stars = {},
    bullets = {},
    enemies = {},
  }
    while #State.stars < starNum do
      MakeStars(1)
    end
  DrawingTing('circ')
  AntiMatter(usagi.GAME_W - usagi.GAME_W / 4, usagi.GAME_H / 2)
  MakeShip(gameW, centH, sprWid * 2, sprWid * 2)
  BulletMaker(State.player, gameW - 16, centH, 150)
  music.loop('RainPixLoFi')
end

-- OK trying a little animation trick here; let's supply the raw value in degrees and only convert it to radians when needed
-- Alternatively I suppose I could store both potentials, but first things first
function RotVal(dt, interval)
  ellRot += dt + interval
  if ellRot >= 360 then
    ellRot = ellRot - 360
  end
  return ellRot
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

function GravEf(sub, obj, dt)
  local wep = sub
  local player = obj
  if player then
    if wep.x > player.x then
      wep.speedX -= wep.mass * dt
      wep.x += wep.speedX
    end
    if wep.x < player.x then
      wep.speedX += wep.mass * dt
      wep.x += wep.speedX
    end
    --print(wep.speedX)
    if wep.y > player.y then
      wep.speedY -= wep.mass * dt
      wep.y += wep.speedY
    end
    if wep.y < player.y then
      wep.speedY += wep.mass * dt
      wep.y += wep.speedY
    end
  else
    wep.x += wep.speedX
    wep.y += wep.speedY
  end
end

-- well this was an interesting little experiment, util.approach would be used in place of a LERP when you want a non-linear interpolation.
-- I should build some kind of display bar and try both methods to better understand how they operate
function MovementTest(c, t, a, dt)
  local curr = 1
  local targ = 10
  local accel = a * dt
  --print(util.approach(curr, targ, accel))
end

--gfx.text(text, x, y, color)
--gfx.text_ex(text, x, y, scale, rotation, color, alpha)

function ArrowMaker(d, w)
  local len = 10
  local data = d
  arrow = {}
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
    tW = 0,
    tH = 0,
    dText = ''
  }
  function GetDist(dir, w)
    local origin = {0, 0}
    if dir == 'r' or dir == 'tR' or dir == 'bR' then
      origin[1] = gameW
      if data == 'bR' then
        origin[2] = gameH
      end
      if data == 'r' then
        origin[2] = w.y
      end
    end
    if dir == 'l' or dir == 'bL' or dir == 'tL' then
      if data == 'bL' then
        origin[2] = gameH
      end
      if data == 'l' then
        origin[2] = w.y
      end
    end
    if dir == 'u' then
      origin[1] = w.x
    end
    if dir == 'd' then
      origin[1] = w.x
      origin[2] = gameH
    end
    local dest = {0, 0}
    dest[1] = w.x
    dest[2] = w.y
    local lenV = util.vec_dist({x=origin[1], y=origin[2]}, {x=dest[1], y=dest[2]})
    return lenV
  end
  if data == "IN" then
    return
  end
  nA.dText = tostring(Rounder(GetDist(data, wep)))
  nA.tW, nA.tH = usagi.measure_text(nA.dText)
  if data == "tL" or data == "l" or data == "bL" then
    nA.tX = len * 1.5
    if data == "tL" then
      nA.x2 = len
      nA.y3 = len
      nA.tY = (len * 1.5) - nA.tH / 2
    elseif data == "bL" then
      nA.x3 = 10
      nA.y1 = gameH
      nA.y2 = gameH - len
      nA.y3 = gameH
      nA.tY = gameH - (len * 1.5) - nA.tH / 2
    else
      nA.y1 = wep.y
      nA.x2 = len
      nA.x3 = len
      nA.y2 = wep.y - len
      nA.y3 = wep.y + len
      nA.tY = wep.y - nA.tH / 2
    end
  end
  if data == 'tR' or data == "r" or data == "bR" then
    nA.x1 = gameW
    nA.tX = gameW - (len * 1.5) - nA.tW
    if data == 'tR' then
      nA.x2 = gameW
      nA.y2 = len
      nA.x3 = gameW - len
      nA.tY = (len * 1.5) - nA.tH / 2
    elseif data == 'bR' then
      nA.y1 = gameH
      nA.x2 = gameW - len
      nA.y2 = gameH
      nA.x3 = gameW
      nA.y3 = gameH - len
      nA.tY = gameH - (len * 1.5) - nA.tH / 2
    else
      nA.y1 = wep.y
      nA.x2 = gameW - len
      nA.y2 = wep.y + len
      nA.x3 = gameW - len
      nA.y3 = wep.y - len
      nA.tY = wep.y - nA.tH / 2
    end
  end
  if data == "u" then
    nA.x1 = wep.x
    nA.x2 = wep.x + len
    nA.y2 = len
    nA.x3 = wep.x - len
    nA.y3 = len
    nA.tX = wep.x - nA.tW / 2
    nA.tY = (len * 1.5) - nA.tH / 2
  end
  if data == "d" then
    nA.x1 = wep.x
    nA.y1 = gameH
    nA.x2 = wep.x - len
    nA.y2 = gameH - len
    nA.x3 = wep.x + len
    nA.y3 = gameH - len
    nA.tX = wep.x - nA.tW / 2
    nA.tY = gameH - (len * 1.5) - nA.tH / 2
  end
  table.insert(arrow, nA)
end

function BulletMaker(e, x, y, s)
  local enemy = e
  if enemy == false then
    return
  end
  local spd = s
  local angle = math.atan(y - enemy.y, x - enemy.x)
  local bullet = {
    x = x,
    y = y,
    r = 5,
    --vel = {x = math.cos(angle) * spd, y = math.sin(angle) * spd},
    -- well this is awfully handy
    vel = util.vec_from_angle(angle, spd),
    colIn = gfx.COLOR_WHITE,
    colOut = gfx.COLOR_ORANGE,
    type = "circ",
    alive = true
  }
  table.insert(State.bullets, bullet)
  --sfx.play('laserShoot')
end

function BulletMov(buls, dt)
  local bArr = buls
  local dt = dt
  for i=#bArr, 1, -1 do
    bArr[i].x -= bArr[i].vel.x * dt
    bArr[i].y -= bArr[i].vel.y * dt
    if bArr[i].x < 0 - bArr[i].r or bArr[i].y < 0 - bArr[i].r or bArr[i].y > gameH + bArr[i].r then
      table.remove(buls, i)
      -- this below will need to be overhauled
      if State.player then
        BulletMaker(State.player, gameW - 16, centH, 150)
      end
    elseif bArr[i].alive == false then
      table.remove(buls, i)
      sfx.play("bullHit")
      if State.player then
        BulletMaker(State.player, gameW - 16, centH, 150)
      end
    end
  end
end

--function M.update(dt, b)
  --if b.alive then
    --b.t += dt
    --b.x += b.vel.x * dt
    --b.y += b.vel.y * dt
    --if b.x > usagi.GAME_W or b.x + SPR_SIZE < 0 or b.y > usagi.GAME_H or b.y + SPR_SIZE < 0 then
      --b.alive = false
    --end
  --end
--end

function MakeShip(x, y, w, h)
  local newShip = {
    x = x,
    y = y,
    w = w,
    h = h,
    rotVal = 0,
    type = 'spr',
    alive = true
  }
  table.insert(State.enemies, newShip)
end

function WeaponTracker(ting)
  local wep = ting
  if wep.x > 0 and wep.x < gameW and wep.y > 0 and wep.y < gameH then
    return "IN"
  end
  if wep.x < 0 and wep.y < 0 then
    return "tL"
  end
  if wep.x < 0 and wep.y > gameH then
    return "bL"
  end
  if wep.x > gameW and wep.y < 0 then
    return "tR"
  end
  if wep.x > gameW and wep.y > gameH then
    return "bR"
  end
  if wep.x > 0 and wep.x < gameW then
    if wep.y < 0 then
      return "u"
    end
    if wep.y > gameH then
      return "d"
    end
  end
  if wep.y > 0 and wep.y < gameH then
    if wep.x < 0 then
      return "l"
    end
    if wep.x > gameW then
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
    x = centW,
    y = centH,
    r = 5,
    type = typeInput,
    name = 'player',
    mass = baseMass,
    speedX = 0,
    speedY = 0,
    movX = false,
    movY = false,
    flipVal = sprWid,
    rotVal = 0,
    alpha = 0,
    alive = true
  }
  State.player = newTing
  --table.insert(State.player, newTing)
end

function AntiMatter(x, y)
  local AMSprite = {
    x = x,
    y = y,
    r = 2.5,
    mass = baseMass,
    type = 'circ',
    speedX = 0,
    speedY = 0,
    color = ColourShift(0),
    alive = true
  }
  table.insert(State.weapon, AMSprite)
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
  table.insert(State.stars, star)
end

function Input(dt)
  if State.player then
  if input.pressed(input.UP) or input.held(input.UP) then
    State.player.movY = true
    State.player.speedY -= accel - dt
    if State.player.speedY < -10 then
      State.player.speedY = -10
    end
    State.player.y += State.player.speedY
  end
  if input.released(input.UP) then
    State.player.movY = false
  end
  if input.pressed(input.DOWN) or input.held(input.DOWN) then
    State.player.movY = true
    State.player.speedY += accel + dt
    if State.player.speedY > 10 then
      State.player.speedY = 10
    end
    State.player.y += State.player.speedY
  end
  if input.released(input.DOWN) then
    State.player.movY = false
  end
  if input.pressed(input.LEFT) or input.held(input.LEFT) then
    State.player.movX = true
    State.player.speedX -= accel - dt
    if State.player.speedX < -10 then
      State.player.speedX = -10
    end
    State.player.x += State.player.speedX
  end
  if input.released(input.LEFT) then
    State.player.movX = false
  end
  if input.pressed(input.RIGHT) or input.held(input.RIGHT) then
    State.player.movX = true
    State.player.speedX += accel + dt
    if State.player.speedX > 10 then
      State.player.speedX = 10
    end
    State.player.x += State.player.speedX
  end
  if input.released(input.RIGHT) then
    State.player.movX = false
  end
  if input.held(input.BTN1) then
    if State.weapon[1].mass == baseMass then
      State.weapon[1].mass = State.weapon[1].mass * 3
    end
  end
  if input.released(input.BTN1) then
    if State.weapon[1].mass > baseMass then
      State.weapon[1].mass = baseMass
    end
  end
    if State.player.movX == false then 
      if State.player.speedX > 0 then
      State.player.speedX -= accel
      if State.player.speedX < 0 then
        State.player.speedX = 0
      end
    else if State.player.speedX < 0 then
      State.player.speedX += accel
      if State.player.speedX > 0 then
        State.player.speedX = 0
      end
    end
    end
    State.player.x += State.player.speedX
    end
    if State.player.x - State.player.r <= 0 then
      State.player.x = 0 + State.player.r
      State.player.speedX = -State.player.speedX
    end
    if State.player.x + State.player.r >= usagi.GAME_W then
      State.player.x = usagi.GAME_W - State.player.r
      State.player.speedX = -State.player.speedX
    end
    if State.player.movY == false then 
      if State.player.speedY > 0 then
        State.player.speedY -= accel
        if State.player.speedY < 0 then
          State.player.speedY = 0
        end
      else if State.player.speedY < 0 then
        State.player.speedY += accel
        if State.player.speedY > 0 then
          State.player.speedY = 0
        end
      end
      end
      State.player.y += State.player.speedY
    end
    if State.player.y - State.player.r <= 0 then
      State.player.y = 0 + State.player.r
      State.player.speedY = -State.player.speedY
    end
    if State.player.y + State.player.r >= usagi.GAME_H then
      State.player.y = usagi.GAME_H - State.player.r
      State.player.speedY = -State.player.speedY
    end
  end
end

function CollChk(c1, c2)
  local mainC = c1
  local secC = c2
  local result
  for i=1, #mainC do
    for j=1, #secC do
      if mainC[i].type == 'circ' and secC[j].type == 'circ' then
        result = util.circ_overlap(mainC[i], secC[j])
      end
      if mainC[i].type == 'circ' and secC[j].type == 'spr' then
        -- necessary to create a new table so as to not modify the original... may want to wrap this into its own function, but if this is the only place this code is used that seems like a waste of time.
        local newTab = {x=0,y=0,w=secC[j].w,h=secC[j].h}
        newTab.x = secC[j].x - newTab.w
        newTab.y = secC[j].y - newTab.h
        result = util.circ_rect_overlap(mainC[i], newTab)
      end
      if result then
        if secC[j].type == 'spr' then
          sfx.play('shipEx')
          --effect.screen_shake(1, 1)
        end
        secC[j].alive = false
        --print("Aye matey")
      end
    end
  end
end

function PlayerCol(e)
  local enArr = e
  local result
  State.time = usagi.elapsed
  for i=1, #enArr do
    if enArr[i].type == 'circ' then
      result = util.circ_overlap(enArr[i], State.player)
    end
  end
  if result then
    State.player.alive = false
    effect.hitstop(1)
    sfx.play("hit")
    return true
  end
end

function Removals(a)
  local arr = a
  if arr == State.player and State.player.alive == false then
    State.player = nil
    return
  end
  for i=#arr, 1, -1 do
    if arr[i].alive == false then
      table.remove(arr, i)
    end
  end 
end

function TimeTrick(t)
  local time = t
  if fxTim then
    if time + 1 > usagi.elapsed then
      return
    else
      effect.screen_shake(1, 2)
      --sfx.play("hitBlast")
      sfx.play("explosion")
      fxTim = false
    end
  end
end

function AlphaShift(dt)
  local al = State.player.alpha
  if input.held(input.BTN1) then
    al += dt
    if al > 1 then
      al = 1
    end
  else
    al -= dt * 2
    if al < 0 then
      al = 0
    end
  end
  State.player.alpha = al
  return al
end

function _update(dt)
  gameTime += dt
  Input(dt)
  BulletMov(State.bullets, dt)
  GravEf(State.weapon[1], State.player, dt)
  --MovementTest(State.weapon[1], State.player, 100, dt)
  ArrowMaker(WeaponTracker(State.weapon[1]), State.weapon[1])
  CollChk(State.weapon, State.bullets)
  --CollChk(State.bullets, State.player)
  --CollChk(State.weapon, State.player)
  CollChk(State.weapon, State.enemies)
  if State.player then
    PlayerCol(State.weapon)
    PlayerCol(State.bullets)
    State.player.rotVal = RotVal(dt, timeInt)
    State.player.flipVal = FlipNum(0.5)
    Removals(State.player)
  end
  TimeTrick(State.time)
  while #State.stars < starNum do
    MakeStars()
  end
  for i=#State.stars, 1, -1 do
    if State.stars[i].tingX <= 0 then
      table.remove(State.stars, i)
    else
      State.stars[i].tingX -= State.stars[i].speed
    end
  end
  State.weapon[1].color = ColourShift(colVal)
  Removals(State.enemies)
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  gfx.text(math.floor(usagi.elapsed) .. 's', centW, gameH - 40, gfx.COLOR_WHITE)
  gfx.text(math.floor(gameTime) ..'s', centW, gameH - 20, gfx.COLOR_WHITE)
  for i=1, #State.stars do
    gfx.px(State.stars[i].tingX, State.stars[i].tingY, gfx.COLOR_WHITE)
  end
  if State.player then
    -- I know I can make this work
    --gfx.player.type(player.tingX, player.tingY, radius, gfx.COLOR_GREEN)
    gfx.circ_fill(State.player.x, State.player.y, State.player.r, gfx.COLOR_WHITE)
    gfx.sspr_ex(0, 0, 16, 16, State.player.x - State.player.flipVal, State.player.y - 16, State.player.flipVal * 2, 16 * 2 , false, false, math.rad(State.player.rotVal), gfx.COLOR_WHITE, 1.0)
    gfx.sspr_ex(0, 0, 16, 16, State.player.x - State.player.flipVal, State.player.y - 16, State.player.flipVal * 2, 16 * 2 , false, false, State.player.rotVal, gfx.COLOR_WHITE, AlphaShift(dt))
  end
  for i=1, #State.bullets do
    gfx.circ_fill(State.bullets[i].x, State.bullets[i].y, State.bullets[i].r, State.bullets[i].colOut)
    gfx.circ_fill(State.bullets[i].x, State.bullets[i].y, State.bullets[i].r / 2, State.bullets[i].colIn)
  end
  for i=1, #State.enemies do
    if State.player then
      State.enemies[i].rotVal = math.atan(State.enemies[i].y - State.player.y, State.enemies[i].x - State.player.x)
    end
    --print(newAngle)
    gfx.sspr_ex(16, 0, 16, 16, State.enemies[i].x - 32, State.enemies[i].y - 16, 16 * 2, 16 * 2, false, false, State.enemies[i].rotVal, gfx.COLOR_TRUE_WHITE, 1.0)
  end
  for i=1, #State.weapon do
    gfx.circ_fill(State.weapon[i].x, State.weapon[i].y, State.weapon[i].r, State.weapon[1].color)
  end
  for i=1, #arrow do
    gfx.tri_fill(arrow[1].x1, arrow[1].y1, arrow[1].x2, arrow[1].y2, arrow[1].x3, arrow[1].y3, gfx.COLOR_WHITE)
    gfx.text(arrow[1].dText, arrow[1].tX, arrow[1].tY, gfx.COLOR_RED)
    -- this is the place to run a dedicated drawing function that should rely on the same arguments to display how far outside of the screen the 'weapon' is
    -- leave drawing for the draw loop and updates for the update loop; update data then draw it
  end
end