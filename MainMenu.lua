

---------------------------------------------------------------------------------
--
-- MainMenu.lua
--
---------------------------------------------------------------------------------

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local scale = { x = 0, y = 0 }

-- Tweakable settings.
local nextScene = "ChallengeSelect"
local sceneEffect = "fade"
local nextSceneTime = 500

-----------------------------------------------------------------------------------------------
    -- Event functions
-----------------------------------------------------------------------------------------------

-- Function to handle button events
local function handleButtonEvent( event )
    if ( event.phase == "began" ) then
    	scale.x = event.target.xScale
    	scale.y = event.target.yScale

    	event.target.xScale = event.target.xScale * 0.95
    	event.target.yScale = event.target.yScale * 0.95

    	event.target.isFocus = true
    elseif ( event.phase == "cancelled" ) then
    	event.target.xScale = scale.x
    	event.target.yScale = scale.y
    elseif ( event.phase == "ended" ) then
    	if(event.target.isFocus) then 
    		event.target.xScale = scale.x
	    	event.target.yScale = scale.y
	        storyboard.gotoScene( nextScene, sceneEffect, nextSceneTime );
	        event.target.isFocus = false
    	end
    end
end

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

function scene:createScene( event )
    print( "\nMainMenu: createScene event" )

    local screenGroup = self.view

    local gameBg = display.newImage("Images/Main_menu/background.png", X_Center, Y_Center);
	gameBg.xScale = 0.22; gameBg.yScale = 0.25;

	local playBtn = genBtn("Images/Main_menu/PLAY_on.png", "Images/Main_menu/PLAY_off.png", 160, 60, X_Center, 0.8 * _H, "playButton", handleButtonEvent)
	
    screenGroup:insert( gameBg ) 
    screenGroup:insert( playBtn ) 
 end

function scene:enterScene( event )
    print( "MainMenu: enterScene event" )
end

function scene:exitScene()
    print( "MainMenu: exitScene event" )
end

function scene:destroyScene( event )
    print( "((destroying scene MainMenu's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------

return scene