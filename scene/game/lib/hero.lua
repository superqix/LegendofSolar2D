-- Module/class for hero

-- Use this as a template to build an in-game hero
local composer = require "composer"
local json = require "json"
local app = require "app"

local fx = require "com.ponywolf.ponyfx"
local snd = require "com.ponywolf.ponysound"

-- Define module
local M = {}

local sqrt = math.sqrt
local function len(dx, dy)
  return sqrt(dx * dx + dy * dy)
end

function M.new(instance, options)
  options = options or {}
  -- Get the current scene
  local scene = composer.getScene("scene.game")

  -- Store map placement and hide placeholder
  local parent = scene.world:findLayer("game")
  local x, y = instance.x, instance.y
  display.remove(instance)

  -- load frame animation
  local heroSheetOptions = options.heroSheetOptions or { width = 16, height = 16, numFrames = 12 }
  local heroSheet = graphics.newImageSheet("img/hero.png", heroSheetOptions)
  local sequences = require("scene.game.lib.animations")[options.animations or "hero"]

  -- Build hero's view
  instance = display.newGroup()
  instance.sprite = display.newSprite(heroSheet, sequences)
  instance:insert(instance.sprite)
  instance.sprite.anchorY = 0.9
  instance.sprite:translate(0,2)
  instance.sprite:play()
  fx.breath(instance.sprite)
  parent:insert(instance)
  instance.x, instance.y = x, y

  -- vars
  instance.name = "hero"
  instance.phase = "idle"
  instance.speed = 10 -- walk speed based on physics sim

  -- Add physics
  physics.addBody(instance, "dynamic", { radius = 6, density = 2.5, bounce = 0, friction =  1})
  instance.isFixedRotation = true
  instance.linearDamping = 15

  local adx, ady, oadx, oady = 0,0,0,0

  local deadZone = 0.25
  local function axis(event)
    local scene = composer.getScene("scene.game")
    if scene and scene.isDead then
      instance.dx, instance.dy = 0,0
      return true
    end

    local axis = event.axis
    local number = axis.number or 0
    adx, ady = oadx, oady

    if number > 2 then return false end

    -- read axis
    if axis.type:find("X") then
      adx = math.max(-1.0, math.min(1.0, event.normalizedValue or 0))
    elseif axis.type:find("Y") then
      ady = math.max(-1.0, math.min(1.0, event.normalizedValue or 0))
    end

    oadx, oady = adx, ady
  end

  local lastPhase, lastKeyName, nx, ny, ox, oy = nil, nil, 0, 0, 0, 0
  local function key(event)
    local phase, keyName = event.phase, event.keyName

    -- buttons
    if phase == "down" then
      if (keyName == "buttonA" or keyName == "button1" or keyName == "space" ) then

      elseif (keyName == "buttonB" or keyName == "button2" or keyName == "leftControl" ) then

      end
    end
  end

  function instance:setSequence(sequence)
    if self.sprite and self.sprite.setSequence then
      self.sequence = sequence or self.sequence or "idle"
      self.sprite:setSequence(self.sequence)
    end
  end
  instance:setSequence()

  function instance:hide()
    self.isVisible = false
    self.shadow.isVisible = false
  end

  function instance:show()
    self.isVisible = true
    self.shadow.isVisible = true
  end

  function instance:hurt()

  end

  function instance:die()

  end

  function instance:pause()
    self.paused = true
  end

  function instance:resume()
    self.paused = false
  end

  function instance:preCollision(event)
    local other = event.other

  end

  function instance:collision(event)
    local other = event.other

  end

  instance.frameCount = 0
  local function enterFrame(event)

    -- shadow
    if instance.shadow and instance.shadow.translate then
      instance.shadow.x, instance.shadow.y = instance.x, instance.y + 3
      instance.shadow.isVisible = instance.isVisible
    else
      local scene = composer.getScene("scene.game")
      if scene then
        instance.shadow = display.newImage(scene.world:findLayer("shadow"), "img/shadow.png")
      end
    end

    if scene.isPaused then return false end

    -- frameCount
    instance.frameCount = (instance.frameCount or 0) + 1

    -- new arrow keys
    local dx,dy = 0, 0

    local kdx, kdy = 0,0
    if app.keyStates["up"] then kdy = kdy - 1 else kdy = kdy + 1 end
    if app.keyStates["down"] then kdy = kdy + 1 else kdy = kdy - 1  end
    if app.keyStates["left"] then kdx = kdx - 1 else kdx = kdx + 1 end
    if app.keyStates["right"] then kdx = kdx + 1 else kdx = kdx - 1 end

    dx = dx + kdx
    dy = dy + kdy

    dx = dx + adx
    dy = dy + ady

    -- force 8-way movement
    local a = math.deg(math.atan2(dy,dx))
    local v = len(dx, dy) < deadZone and 0 or 1
    a = math.rad(math.floor((a+22.5)/45) * 45)
    dx, dy = math.max(-1.0, math.min(math.cos(a) * v, 1.0)), math.max(math.min(math.sin(a) * v, 1.0), -1.0)

    if not instance.ignoreInput then
      instance.dx, instance.dy = dx, dy
    end

    -- check if our physics body has been deleted
    if instance.applyForce then
      -- Move it
      if not instance.paused then
        local speed = instance.speed or 10
        instance:applyForce(speed * (instance.dx or 0), speed * (instance.dy or 0), instance.x, instance.y)
      end

      -- set walking animation
      local vx, vy = instance:getLinearVelocity()
      local newSequence = "idleSouth"
      if vx < -20 then
        newSequence = "walkWest"
      elseif vx > 20 then
        newSequence = "walkEast"
      elseif vy < -20 then
        newSequence = "walkNorth"
      elseif vy > 20 then
        newSequence = "walkSouth"
      end

      if math.abs(vx) < 3 and math.abs(vy) < 3 then -- we are idle
        newSequence = newSequence:gsub("walk", "idle")
      else
        -- step sound
        if instance.frameCount % 33 == 1 then snd:play("step") end
      end

      if newSequence and instance.sequence ~= newSequence then
        instance:setSequence(newSequence)
        instance.sprite:play()
      end
    end
  end

  function instance:finalize()
    -- On remove, cleanup instance, or call directly for non-visual
    display.remove(self.shadow)
    instance:removeEventListener("preCollision")
    instance:removeEventListener("collision")
    Runtime:removeEventListener("enterFrame", enterFrame)
    Runtime:removeEventListener("axis")
    Runtime:removeEventListener("key")
  end

-- Add a finalize listener (for display objects only, comment out for non-visual)
  instance:addEventListener("finalize")

-- Add our enterFrame listener
  Runtime:addEventListener("enterFrame", enterFrame)

-- Add our joystick listeners
  Runtime:addEventListener("axis", axis)
  Runtime:addEventListener("key", key)

-- Add our collision listeners
  instance:addEventListener("preCollision")
  instance:addEventListener("collision")

  return instance
end

return M