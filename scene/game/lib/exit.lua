-- tiled Plugin template

-- Use this as a template to extend a tiled object with functionality
local M = {}

local composer = require "composer"
local app = require "app"
local json = require "json"
local fx = require "com.ponywolf.ponyfx"

function M.new(instance)

  if not instance then error("ERROR: Expected display object") end
  local scene = composer.getScene("scene.game")

  function instance:collision(event)
    local phase = event.phase
    local other = event.other
    --print(phase, other.name)
    if phase == "began" then
      if other.name == "hero" then
        -- hero touched us
        if other.frameCount < 33 then return end
        other.frameCount = 0
        composer.gotoScene("scene.refresh", { params = { map = self.name, dx = other.dx, dy = other.dy }} )
      end
    elseif phase == "ended" then
      if other.name == "hero" then
        -- hero left us

      end
    end
  end

  function instance:preCollision(event)
    local other = event.other

  end

-- Add our collision listeners
  instance:addEventListener("preCollision")
  instance:addEventListener("collision")

  return instance
end

return M