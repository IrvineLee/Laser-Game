---------------------------------------------------------------------------------
--
-- WorldSelection.lua
--
---------------------------------------------------------------------------------

dataTable = { hints = -1, world = {} }

for i = 1, 5, 1 do
    dataTable.world[i] = 
    { 
        isLocked = true,
        lockPointID = -1,
        getStage5Hint = true,
        getStage10Hint = true
    }
end

local loadsave = require("loadsave")

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local scrollView
local lockIconGroup = display.newGroup()
local starIconGroup = display.newGroup()

-- Tweakable settings.
local prevScene = "ChallengeSelect"
local nextScene = "StageSelection"
local sceneEffect = "fade"
local nextSceneTime = 0--500

local maxPage = 5

function unlockWorld(id)
    for i = 1, lockIconGroup.numChildren, 1 do
        if(lockIconGroup[i].id == id) then 
            
            lockIconGroup[i]:removeSelf() 
            dataTable.world[id].isLocked = false
            loadsave.saveTable(dataTable, "dataTable.json") 
            break 

        end
    end
end

-- function putStar(id)
--     local xOffset = scrollView[id] button.x * id
--     local yOffset

--     if( i <= 5) then
--         xOffset = button.x * (0.41 + (i * 0.2) )
--         yOffset = button.y + 20
--     elseif( i > 5 ) then 
--         xOffset = button.x * (0.41 + ( (i-5) * 0.2) )
--         yOffset = button.y + 60 
--     end

--     local starIcon = display.newImage("Images/puzzle_menu/lock_icon.png", xOffset , yOffset);
--     starIcon.xScale = 0.14; starIcon.yScale = 0.14;
--     starIconGroup:insert(starIcon)
-- end

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

        if(event.target.name == "backBtn") then
            resetOffset(scrollView)
            storyboard.gotoScene(prevScene, sceneEffect, nextSceneTime)
        else

            -- for i = 1, lockIconGroup.numChildren, 1 do
            --     if(lockIconGroup[i].id == event.target.id) then return end
            -- end

            local options =
            {
                effect = sceneEffect,
                time = nextSceneTime,
                params = { id = event.target.id }
            }

            storyboard.gotoScene(nextScene, options)
        end
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
        button.x = (_W * (id - 1)) + scrollView.width/2; button.y = scrollView.height * 0.58;
        -- button.x = (0) + scrollView.width/2; button.y = scrollView.height * 0.58;
        button.id = id

        scrollView:insert( button )

        if( id == 1 ) then dataTable.world[id].isLocked = false end

        if(dataTable.world[id].isLocked) then
            local lockIcon = display.newImage("Images/puzzle_menu/lock_icon.png", button.x, button.y + 50);
            lockIcon.xScale = 0.2; lockIcon.yScale = 0.2;
            lockIcon.id = id
            lockIconGroup:insert(lockIcon)
            scrollView:insert( lockIconGroup )
        end
        
        for i = 1, 10, 1 do

            local xOffset = button.x
            local yOffset

            if( i <= 5) then
                xOffset = ((id-1) * _W) + (_W * (0.17 + (i * 0.1) ))
                yOffset = button.y + 20
            elseif( i > 5 ) then 
                xOffset = ((id-1) * _W) + (_W * (0.17 + ((i-5) * 0.1) ))
                yOffset = button.y + 60 
            end

            local starIcon = display.newImage("Images/puzzle_menu/lock_icon.png", xOffset , yOffset);
            starIcon.xScale = 0.14; starIcon.yScale = 0.14;
            starIcon.isVisible = false
            starIconGroup:insert(starIcon)
        end

        for i = 1, dataTable.world[id].lockPointID - 1, 1 do
            starIconGroup[i * id].isVisible = true
        end

        scrollView:insert( starIconGroup )

    end

    genBtn( "Images/puzzle_menu/mirrorslevel_botton.png", "Images/puzzle_menu/mirrorslevel_off_botton.png", 1 )
    genBtn( "Images/puzzle_menu/Glasslevel_botton.png", "Images/puzzle_menu/Glasslevel_off_botton.png", 2  )
    genBtn( "Images/puzzle_menu/Solidslevel_botton.png", "Images/puzzle_menu/Solidslevel_off_botton.png", 3 )
    genBtn( "Images/puzzle_menu/Prismslevel_botton.png", "Images/puzzle_menu/Prismslevel_off_botton.png", 4 )
    genBtn( "Images/puzzle_menu/Twistedlevel_botton.png", "Images/puzzle_menu/Twistedlevel_off_botton.png", 5 )
end

local function clearScene()
    clearArrows()
end

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

function scene:createScene( event )
    print( "\nWorldSelection: createScene event" )

    local screenGroup = self.view

    local gameBg = display.newImage("Images/PuzzleTime_menu/background.png", X_Center, Y_Center + bgOffset);
    gameBg.xScale = 0.21; gameBg.yScale = 0.25;
    
    local tempData = loadsave.loadTable("dataTable.json")
    if(tempData == nil) then loadsave.saveTable(dataTable, "dataTable.json") 
    elseif(tempData ~= nil) then dataTable = tempData; print("LOADED!!")
    end

    createButtonsAndScroll()

    screenGroup:insert( gameBg ) 
    screenGroup:insert( scrollView ) 
    screenGroup:insert( genBackBtn( handleButtonEvent ) )
end

function scene:willEnterScene( event )
    print( "\nWorldSelection: willEnterScene event" )

    local screenGroup = self.view

    if(scrollView.currPage == maxPage) then screenGroup:insert( createArrows( true, false ) )
    elseif(scrollView.currPage > 1 and scrollView.currPage < maxPage) then screenGroup:insert( createArrows( true, true ) )
    else screenGroup:insert( createArrows() )
    end

end

function scene:exitScene()
    print( "WorldSelection: exitScene event" )
    clearScene()
end

function scene:didExitScene( event )
    print( "ChallengeSelect: didExitScene event" )

        -- scrollView.currPage = 1
        -- scrollView:scrollTo( "left", { time=0 }) 
end

function scene:destroyScene( event )
    print( "((destroying scene WorldSelection's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "didExitScene", scene )
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------

return scene