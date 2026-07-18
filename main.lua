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
    lines = {}
  }
    while #State.stars < starNum do
      MakeStars(1)
    end
  DrawingTing('circ')
  AntiMatter(usagi.GAME_W - usagi.GAME_W / 4, usagi.GAME_H / 2)
  MakeShip(sprWid * 2, sprWid * 2, {x = gameW - sprWid, y = centH + sprWid}, 'b', 20)
  --MakeShip(0 + 32, centH, sprWid * 2, sprWid * 2)
  --MakeShip(centW + 16, 16, sprWid * 2, sprWid * 2)
  --MakeShip(centW + 16, gameH - 16, sprWid * 2, sprWid * 2)
  --BulletMaker(State.player, gameW - 16, centH, 150)
  music.loop('RainPixLoFi')
  LayoutCheck()
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
  sfx.play('laserShoot')
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
        --BulletMaker(State.player, gameW - 16, centH, 150)
      end
    elseif bArr[i].alive == false then
      table.remove(buls, i)
      sfx.play("bullHit")
      if State.player then
        --BulletMaker(State.player, gameW - 16, centH, 150)
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

function MakeShip(w, h, d, spn, spd)
  local newShip = {
    x = centW + w / 2,
    y = centH,
    w = w,
    h = h,
    spn = spn,
    spd = spd,
    -- this should be dependent on spawn location compared to screen values
    -- that being said let's try hard-coding one solution and then moving towards that goal
    sPos = nil,
    dPos = d,
    dVel = nil,
    rotVal = 0,
    type = 'spr',
    alive = true,
    intro = true,
    shooting = false,
    shotT = usagi.elapsed + 1,
  }
  if newShip.spn == 'r' then
    newShip.x = gameW + newShip.w
    newShip.dPos = {x = gameW - newShip.w, y = newShip.y}
    newShip.dVel = util.vec_from_angle(math.atan(newShip.y - newShip.dPos.y, newShip.x - newShip.dPos.x), newShip.spd)
  end
  if newShip.spn == 'l' then
    newShip.x = -newShip.w
    newShip.dPos = {x = newShip.w * 2, y = newShip.y}
    newShip.dVel = util.vec_from_angle(math.atan(newShip.y - newShip.dPos.y, newShip.x + newShip.dPos.x), newShip.spd)
  end
  if newShip.spn == 't' then
    newShip.y = -newShip.h
    newShip.dPos = {x = newShip.x, y = newShip.h * 2}
    newShip.dVel = util.vec_from_angle(math.atan(newShip.y + newShip.dPos.y, newShip.x - newShip.dPos.x), newShip.spd)
  end
  if newShip.spn == 'b' then
    newShip.y = gameH + newShip.h
    newShip.dPos = {x = newShip.x, y = gameH - newShip.h}
    newShip.dVel = util.vec_from_angle(math.atan(newShip.y - newShip.dPos.y, newShip.x - newShip.dPos.x), newShip.spd)
  end
  newShip.sPos = {x = newShip.x, y = newShip.y}
  table.insert(State.enemies, newShip)
end

function Shooter(e)
  local ens = e
  local elap = usagi.elapsed
  for i=1, #ens do
    if elap >= ens[i].shotT + 1 and State.player and ens[i].shooting == true then
      BulletMaker(State.player, ens[i].x - ens[i].w / 2, ens[i].y, 150)
      ens[i].shotT = elap --math.random(3)
    end
  end
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

function Input(dt, player)
  local plr = player
  if plr then
  if input.pressed(input.UP) or input.held(input.UP) then
    plr.movY = true
    plr.speedY -= accel - dt
    if plr.speedY < -10 then
      plr.speedY = -10
    end
    plr.y += plr.speedY
  end
  if input.released(input.UP) then
    plr.movY = false
  end
  if input.pressed(input.DOWN) or input.held(input.DOWN) then
    plr.movY = true
    plr.speedY += accel + dt
    if plr.speedY > 10 then
      plr.speedY = 10
    end
    plr.y += plr.speedY
  end
  if input.released(input.DOWN) then
    plr.movY = false
  end
  if input.pressed(input.LEFT) or input.held(input.LEFT) then
    plr.movX = true
    plr.speedX -= accel - dt
    if plr.speedX < -10 then
      plr.speedX = -10
    end
    plr.x += plr.speedX
  end
  if input.released(input.LEFT) then
    plr.movX = false
  end
  if input.pressed(input.RIGHT) or input.held(input.RIGHT) then
    plr.movX = true
    plr.speedX += accel + dt
    if plr.speedX > 10 then
      plr.speedX = 10
    end
    plr.x += plr.speedX
  end
  if input.released(input.RIGHT) then
    plr.movX = false
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
    if plr.movX == false then 
      if plr.speedX > 0 then
      plr.speedX -= accel
      if plr.speedX < 0 then
        plr.speedX = 0
      end
    else if plr.speedX < 0 then
      plr.speedX += accel
      if plr.speedX > 0 then
        plr.speedX = 0
      end
    end
    end
    plr.x += plr.speedX
    end
    if plr.x - plr.r <= 0 then
      plr.x = 0 + plr.r
      plr.speedX = -plr.speedX
    end
    if plr.x + plr.r >= usagi.GAME_W then
      plr.x = usagi.GAME_W - plr.r
      plr.speedX = -plr.speedX
    end
    if plr.movY == false then 
      if plr.speedY > 0 then
        plr.speedY -= accel
        if plr.speedY < 0 then
          plr.speedY = 0
        end
      else if plr.speedY < 0 then
        plr.speedY += accel
        if plr.speedY > 0 then
          plr.speedY = 0
        end
      end
      end
      plr.y += plr.speedY
    end
    if plr.y - plr.r <= 0 then
      plr.y = 0 + plr.r
      plr.speedY = -plr.speedY
    end
    if plr.y + plr.r >= usagi.GAME_H then
      plr.y = usagi.GAME_H - plr.r
      plr.speedY = -plr.speedY
    end
  end
end

function CollisionTesting(dt, w)
  local wep = w
  for i=1, #wep do
    if input.pressed(input.UP) or input.held(input.UP) then
      wep[i].y -= 1
    end
    if input.pressed(input.DOWN) or input.held(input.DOWN) then
      wep[i].y += 1
    end
    if input.pressed(input.LEFT) or input.held(input.LEFT) then
      wep[i].x -= 1
    end
    if input.pressed(input.RIGHT) or input.held(input.RIGHT) then
      wep[i].x += 1
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
        newTab.y = secC[j].y - newTab.h / 2
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
  for i=1, #enArr do
    if enArr[i].type == 'circ' then
      result = util.circ_overlap(enArr[i], State.player)
      if result then
        State.player.alive = false
        effect.hitstop(1)
        sfx.play("hit")
        return true
      end
    end
  end
end

function EnemIntro(e, v, dt)
  local en = e
  local val = v
  for i=1, #en do
    if not en[i].shooting then
      if en[i].sPos.x > en[i].dPos.x then
        en[i].x -= en[i].dVel.x * dt
        if en[i].x < en[i].dPos.x then
          en[i].x = en[i].dPos.x
        end
      elseif en[i].sPos.x < en[i].dPos.x then
        en[i].x += en[i].dVel.x * dt
        if en[i].x > en[i].dPos.x then
          en[i].x = en[i].dPos.x
        end
      elseif en[i].sPos.y > en[i].dPos.y then
        en[i].y -= en[i].dVel.y * dt
        if en[i].y < en[i].dPos.y then
          en[i].y = en[i].dPos.y
        end
      elseif en[i].sPos.y < en[i].dPos.y then
        en[i].y += en[i].dVel.y * dt
        if en[i].y > en[i].dPos.y then
          en[i].y = en[i].dPos.y
        end
      end
      if en[i].x == en[i].dPos.x and en[i].y == en[i].dPos.y then
        en[i].shooting = true
      end
    end
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

function LayoutCheck()
  local vertL = {
    x1 = centW,
    y1 = 0,
    x2 = centW,
    y2 = gameH,
    col = gfx.COLOR_RED,
    a = 1
  }
  local horiL = {
    x1 = 0,
    y1 = centH,
    x2 = gameW,
    y2 = centH,
    col = gfx.COLOR_RED,
    a = 1
  }
  table.insert(State.lines, vertL)
  table.insert(State.lines, horiL)
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
  Input(dt, State.player)
  EnemIntro(State.enemies, 0.2, dt)
  BulletMov(State.bullets, dt)
  GravEf(State.weapon[1], State.player, dt)
  -- 2 test functions
  --CollisionTesting(dt, State.weapon)
  --MovementTest(State.weapon[1], State.player, 100, dt)
  ArrowMaker(WeaponTracker(State.weapon[1]), State.weapon[1])
  CollChk(State.weapon, State.bullets)
  CollChk(State.weapon, State.enemies)
  if State.player then
    -- as long as player is alive, stored time will be set to usagi.elapsed; TimeTrick will only trigger if State.time > usagi.elapsed + 1, which should never happen if player lives. It may be hacky but hell, it works
    State.time = usagi.elapsed
    --PlayerCol(State.weapon)
    -- whatever is fucked-up has to be tied to this, it's literally the collision math for the player
    PlayerCol(State.bullets)
    State.player.rotVal = RotVal(dt, timeInt)
    State.player.flipVal = FlipNum(0.5)
    Removals(State.player)
  end
  TimeTrick(State.time)
  Shooter(State.enemies)
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
  for i=1, #State.lines do
    gfx.line(State.lines[i].x1, State.lines[i].y1, State.lines[i].x2, State.lines[i].y2, State.lines[i].col)
  end
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
      State.enemies[i].rotVal = math.atan(State.enemies[i].y - State.player.y, State.enemies[i].x - State.enemies[i].w / 2 - State.player.x)
    end
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