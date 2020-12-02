--[[

This is the main.lua file. It executes first and in this demo
is sole purpose is to set some initial visual settings and
then you execute our game or menu scene via composer.

Composer is the official scene (screen) creation and management
library in Corona SDK. This library provides developers with an
easy way to create and transition between individual scenes.

https://docs.coronalabs.com/api/library/composer/index.html

-- ]]

local composer = require "composer"
composer.recycleOnSceneChange = true

-- The default magnification sampling filter applied whenever an image is loaded by Corona.
-- Use "nearest" with a small content size to get a retro-pixel look
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "linear")

-- Removes bottom bar on Android
if isAndroid then
  if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
    native.setProperty( "androidSystemUiVisibility", "lowProfile" )
  else
    native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
  end
end

if isiOS then -- don't turn off background music, remove status bar on iOS
  display.setStatusBar( display.HiddenStatusBar )
  native.setProperty( "prefersHomeIndicatorAutoHidden", true )
  native.setProperty( "preferredScreenEdgesDeferringSystemGestures", true )
  audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end

-- reserve audio for menu and bgsound
local snd = require "com.ponywolf.ponysound"
snd:setVolume(0.75)
snd:batch("blip", "laser", "explode", "jump", "thud", "coin", "gun","select_fast","select_slow", "water1","chew","shovel")

-- go to menu screen
display.setDefault("background", 0.2,0.2,0.2)
composer.gotoScene( "scene.game", { params={ map = "house" } } )
