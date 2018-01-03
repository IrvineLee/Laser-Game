---------------------------------------------------------------------------------
--
-- ChallengeSelect.lua
--
---------------------------------------------------------------------------------

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local scrollView

-- Tweakable settings.
local prevScene = "MainMenu"
local challenge1 = "WorldSelection"
local challenge2 = "WorldSelectionTimer"
local sceneEffect = "fade"
local nextSceneTime = 0--500

local maxPage = 2

-----------------------------------------------------------------------------------------------
    -- Event functions
-----------------------------------------------------------------------------------------------

-- Function to handle button events
local function handleButtonEvent( event )
    
    local phase = event.phase

    if ( phase == "moved" ) then
        local dy = math.abs( ( event.x - event.xStart ) )
        -- If the touch on the button has moved more than 10 pixels,
        -- pass focus back to the scroll view so it can continue scrolling
        if ( dy > 10 ) then
            scrollView:takeFocus( event )
        end
    elseif ( phase == "ended" ) then

        local nextScene
        if(event.target.name == "worldSelection") then nextScene = challenge1;
        elseif(event.target.name == "worldSelectionTimer") then nextScene = challenge2
        elseif(event.target.name == "backBtn") then nextScene = prevScene; resetOffset(scrollView)
        end

        storyboard.gotoScene( nextScene, sceneEffect, nextSceneTime );
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
        friction = 6,
        listener = scrollListener,
        hideBackground = true,
        verticalScrollDisabled = true
    }
    scrollView.currPage = 1
    scrollView.maxPage = maxPage

    local tempBtn
    tempBtn = genBtn("Images/choose_challenge/Puzzle_botton.png", "Images/choose_challenge/Puzzle_off_botton.png", 200, 200, scrollView.width/2, scrollView.height * 0.58, "worldSelection", handleButtonEvent)
    scrollView:insert( tempBtn )

    tempBtn = genBtn("Images/choose_challenge/Puzzletime_botton.png", "Images/choose_challenge/Puzzletime_off_botton.png", 200, 200, _W + scrollView.width/2, scrollView.height * 0.58, "worldSelectionTimer", handleButtonEvent)
    scrollView:insert( tempBtn )
end

local function clearScene()
    -- scrollView:removeSelf()
    clearArrows()
end

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

function scene:createScene( event )
    print( "\nChallengeSelect: createScene event" )

    local screenGroup = self.view

    local gameBg = display.newImage("Images/choose_challenge/background.png", X_Center, Y_Center + bgOffset);
    gameBg.xScale = 0.21; gameBg.yScale = 0.25;
    
    createButtonsAndScroll()

    screenGroup:insert( gameBg ) 
    screenGroup:insert( scrollView )
    screenGroup:insert( genBackBtn( handleButtonEvent ) )

 end

function scene:willEnterScene( event )
    print( "\nChallengeSelect: willEnterScene event" )

    local screenGroup = self.view

    if(scrollView.currPage == maxPage) then screenGroup:insert( createArrows( true, false ) )
    else screenGroup:insert( createArrows() )
    end

    -- storyboard.purgeScene( "scene5" )
end

function scene:exitScene()
    print( "ChallengeSelect: exitScene event" )
    clearScene()
end

function scene:destroyScene( event )
    print( "((destroying scene ChallengeSelect's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------

return scene