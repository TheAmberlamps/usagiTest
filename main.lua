local dandelion = require "dandelion"
local tween = require "tween"
local timeInt = 1
local fxTim = true
local onMenu = true
local gameOn = false
local inIntro = false
local baseMass = 3
local colVal = 1
local sprWid = 16
local sprWidStr = sprWid * 2
local subVal = true
local accel = 0.25
local movSpd = 20
local spawnTime = 5
local gameTime = 0
GameW = usagi.GAME_W
print("GameW: " .. GameW)
GameH = usagi.GAME_H
print("GameH: " .. GameH)
CentW = usagi.GAME_W / 2
CentH = usagi.GAME_H / 2
local pX = 0
local pY = 0
local starNum = 50
local ellRot = 0
local arrow = {}
local options = {
  'PLAY'
}
local current_option = 1

function _init()
  --local scoreTab = usagi.load() or 0
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
    lines = {},
    score = 0,
    hiScore = 0--scoreTab[1] or scoreTab
  }
    while #State.stars < starNum do
      MakeStars(1)
    end
  --DrawingTing('circ')
  --AntiMatter(usagi.GAME_W - usagi.GAME_W / 4, usagi.GAME_H / 2)
  --MakeShip(sprWid * 2, sprWid * 2, 'r', movSpd)
  --BulletMaker(State.player, GameW - 16, CentH, 150)
  music.loop('RainPixLoFi')
  --LayoutCheck()
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
      origin[1] = GameW
      if data == 'bR' then
        origin[2] = GameH
      end
      if data == 'r' then
        origin[2] = w.y
      end
    end
    if dir == 'l' or dir == 'bL' or dir == 'tL' then
      if data == 'bL' then
        origin[2] = GameH
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
      origin[2] = GameH
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
      nA.y1 = GameH
      nA.y2 = GameH - len
      nA.y3 = GameH
      nA.tY = GameH - (len * 1.5) - nA.tH / 2
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
    nA.x1 = GameW
    nA.tX = GameW - (len * 1.5) - nA.tW
    if data == 'tR' then
      nA.x2 = GameW
      nA.y2 = len
      nA.x3 = GameW - len
      nA.tY = (len * 1.5) - nA.tH / 2
    elseif data == 'bR' then
      nA.y1 = GameH
      nA.x2 = GameW - len
      nA.y2 = GameH
      nA.x3 = GameW
      nA.y3 = GameH - len
      nA.tY = GameH - (len * 1.5) - nA.tH / 2
    else
      nA.y1 = wep.y
      nA.x2 = GameW - len
      nA.y2 = wep.y + len
      nA.x3 = GameW - len
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
    nA.y1 = GameH
    nA.x2 = wep.x - len
    nA.y2 = GameH - len
    nA.x3 = wep.x + len
    nA.y3 = GameH - len
    nA.tX = wep.x - nA.tW / 2
    nA.tY = GameH - (len * 1.5) - nA.tH / 2
  end
  table.insert(arrow, nA)
end

function BulletMaker(e, x, y, v, s)
  sfx.play('laserShoot')
  local enemy = e
  if enemy == false then
    return
  end
  local variety = v
  local spd = s
  local colIn = gfx.COLOR_WHITE
  local colOut = gfx.COLOR_ORANGE
  local angle = math.atan(y - enemy.y, x - enemy.x)
  local angleDeg = math.deg(angle)
  print("angleDeg: " .. angleDeg)
  local spread = 45
  if variety == 'b' then
    colOut = gfx.COLOR_BLUE
    spd = spd / 2.5
    local split = 5
    local startAngle = angleDeg - spread / 2
    local spreadIncrement = spread / (split - 1)
    for i=1, split do
      local angleMath = math.rad(startAngle + spreadIncrement * (i - 1))
      local bullet = {
        x = x,
        y = y,
        r = 5,
        --vel = {x = math.cos(angle) * spd, y = math.sin(angle) * spd},
        -- well this is awfully handy
        vel = util.vec_from_angle(angleMath, spd),
        colIn = colIn,
        colOut = colOut,
        type = "circ",
        alive = true,
        split = 5,
        spread = spread
      }
      table.insert(State.bullets, bullet)
    end
    return
  elseif variety == 'r' or 'y' then
    print("angle: " .. angle)
    local bullet = {
      x = x,
      y = y,
      r = 5,
      --vel = {x = math.cos(angle) * spd, y = math.sin(angle) * spd},
      -- well this is awfully handy
      vel = util.vec_from_angle(angle, spd),
      colIn = colIn,
      colOut = colOut,
      type = "circ",
      alive = true,
      split = 5,
      spread = spread
    }
    table.insert(State.bullets, bullet)
  end
  -- very interesting, it seems as though instead of inserting three bullets, this is just remodifying a single one and then inserting it after all instructions.
  -- I suppose the answer here is to run a for or while loop that runs based on the number of bullets to be fired in a spread and applying that difference to the angle... need to start from one end and go to the other, forget basing conditions on the 'center' angle
end

function BulletMov(buls, dt)
  local bArr = buls
  local dt = dt
  for i=#bArr, 1, -1 do
    bArr[i].x -= bArr[i].vel.x * dt
    bArr[i].y -= bArr[i].vel.y * dt
    if bArr[i].x < 0 - bArr[i].r or bArr[i].y < 0 - bArr[i].r or bArr[i].y > GameH + bArr[i].r then
      table.remove(buls, i)
      -- this below will need to be overhauled
      if State.player then
        --BulletMaker(State.player, GameW - 16, CentH, 150)
      end
    elseif bArr[i].alive == false then
      dandelion.debris_emitter_b(bArr[i].x - bArr[i].r / 2, bArr[i].y)
      table.remove(buls, i)
      State.score += 2
      sfx.play("bullHit")
      if State.player then
        --BulletMaker(State.player, GameW - 16, CentH, 150)
      end
    end
  end
end

function MakeShip(w, h, c, spn, spd)
  local newShip = {
    x = CentW + w / 2,
    y = CentH,
    w = w,
    h = h,
    class = c,
    spn = spn,
    spd = spd,
    -- this should be dependent on spawn location compared to screen values
    -- that being said let's try hard-coding one solution and then moving towards that goal
    sPos = nil,
    dPos = nil,
    dVel = nil,
    rotVal = 0,
    type = 'spr',
    alive = true,
    intro = true,
    shooting = false,
    shotT = usagi.elapsed + 1,
  }
  if newShip.spn == 'r' then
    newShip.x = GameW + newShip.w
    newShip.y = math.random(h, GameH - h)
    newShip.dPos = {x = GameW - newShip.w, y = newShip.y}
    newShip.dVel = util.vec_from_angle(math.atan(newShip.y - newShip.dPos.y, newShip.x - newShip.dPos.x), newShip.spd)
  end
  if newShip.spn == 'l' then
    newShip.x = -newShip.w
    newShip.y = math.random(h, GameH - h)
    newShip.dPos = {x = newShip.w * 2, y = newShip.y}
    newShip.dVel = util.vec_from_angle(math.atan(newShip.y - newShip.dPos.y, newShip.x + newShip.dPos.x), newShip.spd)
  end
  if newShip.spn == 't' then
    newShip.x = math.random(w, GameW - w)
    newShip.y = -newShip.h
    newShip.dPos = {x = newShip.x, y = newShip.h * 2}
    newShip.dVel = util.vec_from_angle(math.atan(newShip.y + newShip.dPos.y, newShip.x - newShip.dPos.x), newShip.spd)
  end
  if newShip.spn == 'b' then
    newShip.x = math.random(w, GameW - w)
    newShip.y = GameH + newShip.h
    newShip.dPos = {x = newShip.x, y = GameH - newShip.h}
    newShip.dVel = util.vec_from_angle(math.atan(newShip.y - newShip.dPos.y, newShip.x - newShip.dPos.x), newShip.spd)
  end
  newShip.sPos = {x = newShip.x, y = newShip.y}
  table.insert(State.enemies, newShip)
end

function ShipDraw(s)
  local ship = s
  if State.player then
    ship.rotVal = math.atan(ship.y - State.player.y, ship.x - ship.w / 2 - State.player.x)
  end
  local sx = 0
  local sy = 0
  if ship.class == "r" then
    sx = 16
  end
  if ship.class == "b" then
    sx = 32
    sy = 16
  end
  if ship.class == "y" then
    sx = 32
  end
  gfx.sspr_ex(sx, sy, 16, 16, ship.x - 32, ship.y - 16, 16 * 2, 16 * 2, false, false, ship.rotVal, gfx.COLOR_TRUE_WHITE, 1.0)
end

function Shooter(e)
  local ens = e
  local bullType
  local elap = usagi.elapsed
  local timeDiff = 1
  for i=1, #ens do
    if ens[i].class == 'b' then
      timeDiff = 2
    end
    if ens[i].class == 'y' then
      timeDiff = 0.5
    end
    if elap >= ens[i].shotT + timeDiff and State.player and ens[i].shooting == true then
      bullType = ens[i].class
      BulletMaker(State.player, ens[i].x - ens[i].w / 2, ens[i].y, bullType, 150)
      ens[i].shotT = elap --math.random(3)
    end
  end
end

function WeaponTracker(ting)
  local wep = ting
  if wep.x > 0 and wep.x < GameW and wep.y > 0 and wep.y < GameH then
    return "IN"
  end
  if wep.x < 0 and wep.y < 0 then
    return "tL"
  end
  if wep.x < 0 and wep.y > GameH then
    return "bL"
  end
  if wep.x > GameW and wep.y < 0 then
    return "tR"
  end
  if wep.x > GameW and wep.y > GameH then
    return "bR"
  end
  if wep.x > 0 and wep.x < GameW then
    if wep.y < 0 then
      return "u"
    end
    if wep.y > GameH then
      return "d"
    end
  end
  if wep.y > 0 and wep.y < GameH then
    if wep.x < 0 then
      return "l"
    end
    if wep.x > GameW then
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
    x = CentW,
    y = CentH,
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

-- maybe use a specific value to move by instead of magic numbers? It's all good to move by 15 but that should be 1 variable
-- ah it's accel * 15, I see... I'll need accel to stay in place if I want to roll back movement, or re-introduce the original movement as an option in the future
function Input(dt, player)
  local plr = player
  if plr then
  if input.pressed(input.UP) or input.held(input.UP) then
    -- experimental code to rework movement
    plr.y -= accel * 15 - dt
    --[[plr.movY = true
    plr.speedY -= accel - dt
    if plr.speedY < -10 then
      plr.speedY = -10
    end
    plr.y += plr.speedY
  end
  if input.released(input.UP) then
    plr.movY = false]]
  end
  if input.pressed(input.DOWN) or input.held(input.DOWN) then
    plr.y += accel * 15 - dt
    --[[plr.movY = true
    plr.speedY += accel + dt
    if plr.speedY > 10 then
      plr.speedY = 10
    end
    plr.y += plr.speedY
  end
  if input.released(input.DOWN) then
    plr.movY = false]]
  end
  if input.pressed(input.LEFT) or input.held(input.LEFT) then
    plr.x -= accel * 15 - dt
    --[[plr.movX = true
    plr.speedX -= accel - dt
    if plr.speedX < -10 then
      plr.speedX = -10
    end
    plr.x += plr.speedX
  end
  if input.released(input.LEFT) then
    plr.movX = false]]
  end
  if input.pressed(input.RIGHT) or input.held(input.RIGHT) then
    plr.x += accel * 15 - dt
    --[[plr.movX = true
    plr.speedX += accel + dt
    if plr.speedX > 10 then
      plr.speedX = 10
    end
    plr.x += plr.speedX
  end
  if input.released(input.RIGHT) then
    plr.movX = false]]
  end
  if input.held(input.BTN1) then
    State.weapon[1].mass += dt + 0.1
    if State.weapon[1].mass > baseMass * 2.5 then
      State.weapon[1].mass = baseMass * 2.5
    end
  else
    State.weapon[1].mass -= dt + 0.1
    if State.weapon[1].mass < baseMass then
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
        if secC[j].type == 'circ' then
          
        end
        if secC[j].type == 'spr' then
          sfx.play('shipEx')
          dandelion.debris_emitter(secC[j].x - secC[j].w / 2 , secC[j].y)
          if secC[j].class == 'r' then
            State.score += 10
          end
          if secC[j].class == 'b' then
            State.score += 15
          end
          if secC[j].class == 'y' then
            State.score += 20
          end
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
        --dandelion.debris_emitter(State.player.x, State.player.y)
        sfx.play("hit")
        return true
      end
    end
  end
end

function EnemIntro(e, v, dt)
  local en = e
  -- unused argument?
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
  -- global bool to determine if this should run or not
  if fxTim then
    if time + 1 > usagi.elapsed then
      return
    else
      effect.screen_shake(1, 2)
      --sfx.play("hitBlast")
      dandelion.debris_emitter(pX, pY)
      sfx.play("explosion")
      gameOn = false
      fxTim = false
    end
  end
end

-- draws two lines to show where the center of the screen is
function LayoutCheck()
  local vertL = {
    x1 = CentW,
    y1 = 0,
    x2 = CentW,
    y2 = GameH,
    col = gfx.COLOR_RED,
    a = 1
  }
  local horiL = {
    x1 = 0,
    y1 = CentH,
    x2 = GameW,
    y2 = CentH,
    col = gfx.COLOR_RED,
    a = 1
  }
  table.insert(State.lines, vertL)
  table.insert(State.lines, horiL)
end

-- test func for particles
function BitBlast(i)
  if i then
    dandelion.debris_emitter(CentW, CentH)
  end
end

function NmeSpawner(time)
  local timeVal = time
  local spawnLocs = {
    'r',
    'l',
    't',
    'b'
  }
  local spwnLoc = spawnLocs[math.random(1, #spawnLocs)]
  local spawnVars = {
    "r", "b", "y"
  }
  local spawnType = spawnVars[1]
  if gameTime >= 5 then
    spawnType = spawnVars[math.random(1, 2)]
  end
  if gameTime >= 10 then
    spawnType = spawnVars[math.random(1, 3)]
  end
  local elap = usagi.elapsed
  if elap >= timeVal and State.player then
    -- note to self; do NOT use arithmetic as an argument, either supply the values needed to do the math as arguments or run the calculations and use the RESULT as an argument.
    MakeShip(sprWidStr, sprWidStr, spawnType, spwnLoc, movSpd)
    spawnTime = elap + 5
  end
end

local tweenTesting = {}

--[[function TweenMaker(d, s, t, e)
  local dur = d
  local start = s
  local targ = t
  local ease = e
  return tween.new(dur, start, targ, ease)
end]]--

function GameStart()
  gameOn = true
  inIntro = true
  DrawingTing('circ')
  --AntiMatter(usagi.GAME_W - usagi.GAME_W / 4, usagi.GAME_H / 2)
  AntiMatter(CentW, CentH)
  print("weapon table length: " .. #State.weapon)
  -- OK, next step is dumping this constructor nonsense and just building this straight-up. No idea what the problem is here but I feel like I'm 1 step away from that payoff
  --tweenTesting = TweenMaker(2, State.weapon[1], {x = CentW + CentW / 2}, "outCubic")
  -- a table of length 0, of course...
  local newTab = {x = State.weapon[1].x}
  print(newTab)
  tweenTesting = tween.new(2, State.weapon[1], {x = GameW - GameW / 4}, 'outCubic')
  print(tweenTesting.subject)
end

-- v should be the onMenu bool
function GameOver()
  fxTim = true
  arrow = {}
  State.score = State.score * math.floor(gameTime)
  gameTime = 0
  current_option = 1
  State.player = nil
  State.weapon = {}
  State.bullets = {}
  State.enemies = {}
  State.lines = {}
  if State.score > State.hiScore then
    State.hiScore = State.score
  end
  -- could this be it?
  -- indeed it was, seems like saving and loading data is very volatile...
  -- well this needs solving, but for the meantime push forward with the planned changes
  --usagi.save({score = State.hiScore})
  State.score = 0
end

-- this is a wonderful bit of code but it's executing in the wrong place; it's being fed as an argument to a drawing function in the drawing loop, it should be executed in the update loop and that result should be used to draw.
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
  if al > 0 then
    -- this also is lovely but should be relegated to its own function so that errors related to sound bullshit are more easily traceable.
    sfx.play_ex('chargeToneClipd', al / 2, al * -3, 0)
    sfx.play_ex('chargeToneClipd', al / 2, al * -2, 0)
    sfx.play_ex('chargeToneClipd', al / 2, al * -1, 0)
  end
  State.player.alpha = al
  return al
end

--[[function DrawTitle(c)
  --local title = "NUCLEUS"
  local col = c
  local txX, txY = usagi.measure_text(title)
  gfx.text(title, CentW - txX / 2, txY * 2.5, col)
end]]

function DrawGameOver(c)
  local tex = "GAME OVER"
  local col = c
  local txX, txY = usagi.measure_text(tex)
  --State.score = State.score * math.floor(gameTime)
  local scoreText = State.score .. " POINTS * " .. math.floor(gameTime) .. "s"
  local scrX, scrY = usagi.measure_text(scoreText)
  local finalScore = tostring(State.score * math.floor(gameTime))
  local finX, finY = usagi.measure_text(finalScore)
  gfx.text(tex, CentW - txX / 2, txY, col)
  gfx.text(scoreText, CentW - scrX / 2, scrY * 2, col)
  gfx.text(finalScore, CentW - finX / 2, finY * 3, col)
end

function MenuStuff()
  if input.pressed(input.UP) then
    current_option -= 1
    if current_option < 1 then
      current_option = #options
    end
  end
  if input.pressed(input.DOWN) then
    current_option += 1
    if current_option > #options then
      current_option = 1
    end
  end
  if input.pressed(input.BTN1) then
    if current_option == 1 then
      onMenu = false
      GameStart()
    end
  end
end

function _update(dt)
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
  if onMenu == false and gameOn == true then
    if inIntro == true then
      local tween = tweenTesting:update(dt)
      if tween == true then
        inIntro = false
        -- implement a flash here 
      end
    else
      gameTime += dt
      Input(dt, State.player)
      NmeSpawner(spawnTime)
      EnemIntro(State.enemies, 0.2, dt)
      BulletMov(State.bullets, dt)
      GravEf(State.weapon[1], State.player, dt)
      --print("weapon.mass: " .. State.weapon[1].mass)
      -- 2 test functions
      --CollisionTesting(dt, State.weapon)
      --MovementTest(State.weapon[1], State.player, 100, dt)
      ArrowMaker(WeaponTracker(State.weapon[1]), State.weapon[1])
      CollChk(State.weapon, State.bullets)
      CollChk(State.weapon, State.enemies)
      if State.player then
        pX = State.player.x
        pY = State.player.y
        -- as long as player is alive, stored time will be set to usagi.elapsed; TimeTrick will only trigger if State.time > usagi.elapsed + 1, which should never happen if player lives. It may be hacky but hell, it works
        State.time = usagi.elapsed
        PlayerCol(State.weapon)
        -- whatever is fucked-up has to be tied to this, it's literally the collision math for the player
        PlayerCol(State.bullets)
        State.player.rotVal = RotVal(dt, timeInt)
        State.player.flipVal = FlipNum(0.5)
        Removals(State.player)
      end
      Shooter(State.enemies)
      State.weapon[1].color = ColourShift(colVal)
      Removals(State.enemies)
      TimeTrick(State.time)
    end
    return
  elseif onMenu == true then
    MenuStuff()
    return
  else
    BulletMov(State.bullets, dt)
    GravEf(State.weapon[1], State.player, dt)
    ArrowMaker(WeaponTracker(State.weapon[1]), State.weapon[1])
    State.weapon[1].color = ColourShift(colVal)
    CollChk(State.weapon, State.bullets)
    CollChk(State.weapon, State.enemies)
    Removals(State.enemies)
    if input.pressed(input.BTN1) then
      onMenu = true
      GameOver()
    end
  end
end

function _draw(dt)
  gfx.clear(gfx.COLOR_BLACK)
  for i=1, #State.stars do
    gfx.px(State.stars[i].tingX, State.stars[i].tingY, gfx.COLOR_WHITE)
  end
  if onMenu == false and gameOn == true and inIntro == false then
    --gfx.clear(gfx.COLOR_BLUE)
    dandelion.Draw()
    --gfx.text(math.floor(usagi.elapsed) .. 's', CentW, GameH - 40, gfx.COLOR_WHITE)
    local timTex = math.floor(gameTime) .. 's'
    local txX, txY = usagi.measure_text(timTex)
    gfx.text(timTex, CentW - txX / 2, GameH - 20, gfx.COLOR_WHITE)
    local scoreText = tostring(State.score)
    local scrX, scrY = usagi.measure_text(scoreText)
    gfx.text(scoreText, CentW - scrX / 2, 10, gfx.COLOR_PEACH)
    -- place score here, but at the top
    for i=1, #State.lines do
      gfx.line(State.lines[i].x1, State.lines[i].y1, State.lines[i].x2, State.lines[i].y2, State.lines[i].col)
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
      ShipDraw(State.enemies[i])
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
  elseif inIntro == true then
    -- player
    gfx.circ_fill(State.player.x, State.player.y, State.player.r, gfx.COLOR_WHITE)
    -- weapon
    gfx.circ_fill(State.weapon[1].x, State.weapon[1].y, State.weapon[1].r, gfx.COLOR_WHITE) --State.weapon[1].color)
  elseif onMenu == true then
    --DrawTitle(gfx.COLOR_PEACH)
    gfx.sspr_ex(0, 32, 186, 24, CentW - 180 / 2, CentH - 70, 180, 25, false, false, 0, gfx.COLOR_TRUE_WHITE, 1.0)
    local scoreText = "BEST:" .. State.hiScore
    local sW, sH = usagi.measure_text(scoreText)
    gfx.text(scoreText, CentW - sW / 2, sH / 2, gfx.COLOR_WHITE)
    local optionText = options[current_option]
    local tW, tH = usagi.measure_text(optionText)
    -- display title above the options
    --local w, h = usagi.measure_text("Game Over")
    gfx.text(options[current_option], CentW - tW / 2, CentH - tH / 2, gfx.COLOR_WHITE)
    local rad = 5
    local instructions1 = "USE YOUR MASS TO SLINGSHOT YOUR WEAPON"
    local i1w, i1h = usagi.measure_text(instructions1)
    local instructions2 = "BTN1 INCREASES MASS"
    local i2w, i2h = usagi.measure_text(instructions2)
    gfx.text_ex(instructions1, CentW - i1w / 2, GameH - i1h * 2 - i1h / 2, 1, 0, gfx.COLOR_WHITE, 1)
    gfx.text_ex(instructions2, CentW - i2w / 2, GameH - i2h - i2h / 2, 1, 0, gfx.COLOR_WHITE, 1)
    gfx.circ_fill(CentW - tW, CentH - tH / 8, rad, gfx.COLOR_ORANGE)
  else
    dandelion.Draw()
    DrawGameOver(gfx.COLOR_PEACH)
    for i=1, #State.bullets do
      gfx.circ_fill(State.bullets[i].x, State.bullets[i].y, State.bullets[i].r, State.bullets[i].colOut)
      gfx.circ_fill(State.bullets[i].x, State.bullets[i].y, State.bullets[i].r / 2, State.bullets[i].colIn)
    end
    for i=1, #State.enemies do
      if State.player then
        State.enemies[i].rotVal = math.atan(State.enemies[i].y - State.player.y, State.enemies[i].x - State.enemies[i].w / 2 - State.player.x)
      end
      ShipDraw(State.enemies[i])
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
end