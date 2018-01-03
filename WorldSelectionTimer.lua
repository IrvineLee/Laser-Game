---------------------------------------------------------------------------------
--
-- WorldSelectionTimer.lua
--
---------------------------------------------------------------------------------

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local buttonsTbl = {}
local scrollView
local currOffset = 0

-- Tweakable settings.
local nextScene = "MainGame"
local sceneEffect = "fade"
local nextSceneTime = 500

local maxPage = 3

-----------------------------------------------------------------------------------------------
    -- Event functions
-----------------------------------------------------------------------------------------------

-- Function to handle button events
local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then

        local options =
        {
            effect = sceneEffect,
            time = nextSceneTime,
            params = { isRandomizeStage = true, bgID = event.target.id }
        }

        storyboard.gotoScene( nextScene, options );
    end
end

-----------------------------------------------------------------------------------------------
    -- Main
-----------------------------------------------------------------------------------------------

local function createButtonsAndScroll()

    -- Create the widget
    scrollView = widget.newScrollView
    {
        top = 0,
        left = 10,
        width = 300,
        height = _H,
        scrollWidth = 600,
        scrollHeight = 800,
        listener = scrollListener,
        hideBackground = true,
        verticalScrollDisabled = true
    }
    scrollView.currPage = 1
    scrollView.maxPage = maxPage

    local function genBtn( default, over, id )
        local button = widget.newButton
        {
            font = "Arial",
            emboss = true,
            width = 200,
            height = 200,
            defaultFile = default,
            overFile = over,
            onEvent = handleButtonEvent
        }
        button.anchorX = 0.5; button.anchorY = 0.5;
        button.x = (_W * (id - 1)) + scrollView.width/2; button.y = scrollView.height * 0.6;
        button.id = id

        scrollView:insert( button )
    end

    genBtn( "Images/PuzzleTime_menu/Easy_level_botton.png", "Images/game/empty_box.png", 1 )
    genBtn( "Images/PuzzleTime_menu/Regular_level_botton.png", "Images/game/empty_box.png", 2 )
    genBtn( "Images/PuzzleTime_menu/Hard_level_botton.png", "Images/game/empty_box.png", 3 )

end

local function clearScene()
    scrollView:removeSelf()
    clearArrows()
end

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

function scene:createScene( event )
    print( "\nWorldSelection: createScene event" )

    local screenGroup = self.view

    local gameBg = display.newImage("Images/PuzzleTime_menu/background.png", X_Center, Y_Center);
    gameBg.xScale = 0.21; gameBg.yScale = 0.25;
    
    createButtonsAndScroll()

    screenGroup:insert( gameBg )
    screenGroup:insert( scrollView ) 
    screenGroup:insert( createArrows() )
 end

function scene:enterScene( event )
    print( "WorldSelection: enterScene event" )
    -- storyboard.purgeScene( "scene5" )
end

function scene:exitScene()
    print( "WorldSelection: exitScene event" )
    clearScene()
end

function scene:destroyScene( event )
    print( "((destroying scene WorldSelection's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------

return scene