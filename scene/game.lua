-- Requirements
local composer = require "composer"
local ponytiled = require "com.ponywolf.ponytiled"
local fx = require "com.ponywolf.ponyfx"
local snap = require "com.ponywolf.snap"
local json = require "json"
local app = require "app"

-- Variables local to scene
local scene = composer.newScene()
local world, hud, map

function scene:create( event )
  local view = self.view -- add display objects to this group
  local params = event.params or {}

  physics.start()
  physics.setGravity(0,0)

  -- load world
  self.map = params.map or "house"
  local worldData = json.decodeFile(system.pathForFile("map/" .. self.map .. ".json"))
  self.world = ponytiled.new(worldData, "map")
  self.world:centerAnchor()

  --standard extensions
  self.world:extend("decor")
  view:insert(self.world)
  self.world:findLayer("physics").isVisible = false
  self.world:toBack()

  --custom extensions
  self.world.extensions = "scene.game.lib."
  self.world:extend("hero", "exit" )
  self.world:centerObject("hero")

    -- add virtual joysticks to mobile
    local vjoy = require( "com.ponywolf.vjoy" )
    local stick = vjoy.newStick(1,16,32)
    local buttonA = vjoy.newButton(16,"buttonA")
    local buttonX = vjoy.newButton(16,"buttonX")

    buttonA:setFillColor(0,0.75,0.1)
    buttonX:setFillColor(0,0,1)

    snap(stick, "bottomright", 16)
    snap(buttonA, "bottomleft", 24)
    snap(buttonX, "bottomleft", 24)

    buttonA:translate(32,0)
    buttonX:translate(0,-32)
    view:insert( buttonA )
    view:insert( buttonX )
    view:insert( stick )

end

local function enterFrame(event)
  local elapsed = event.time
  -- Do these every frame regardless of pause
  local world = scene.world
  world:sortLayer("game")
  world:centerObject("hero", true)
  world:boundsCheck()

end

function scene:pause()
  Runtime:removeEventListener("enterFrame", enterFrame)
end

function scene:resume()
  Runtime:addEventListener("enterFrame", enterFrame)
end


local function key(event)
  local phase, name = event.phase, event.keyName

end

function scene:show( event )
  local phase = event.phase
  if ( phase == "will" ) then
    Runtime:addEventListener("enterFrame", enterFrame)
  elseif ( phase == "did" ) then
    fx.fadeIn()
  end
end

function scene:hide( event )
  local phase = event.phase
  if ( phase == "will" ) then

  elseif ( phase == "did" ) then
    Runtime:removeEventListener("enterFrame", enterFrame)
  end
end

function scene:destroy( event )

end

scene:addEventListener("create")
scene:addEventListener("show")
scene:addEventListener("hide")
scene:addEventListener("destroy")

return scene