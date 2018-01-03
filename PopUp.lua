---------------------------------------------------------------------------------
--
-- PopUp.lua
--
---------------------------------------------------------------------------------

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local infoGroup = display.newGroup()
local timerDestroy
local nextScene
local nextLevel = 1

-- Tweakable settings.
local timerBeforeDestroy = 2000

local stageScene = "StageSelection"
local sceneEffect = "fade"
local nextSceneTime = 500

local uiTime = 200

-----------------------------------------------------------------------------------------------
    -- Event functions
-----------------------------------------------------------------------------------------------

local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
        local name = event.target.name

        if(name == "tutBtn") then storyboard.hideOverlay(sceneEffect, uiTime)
        elseif(name == "stageSelectBtn") then 
            storyboard.hideOverlay(sceneEffect, nextSceneTime) 
            storyboard.gotoScene(stageScene, sceneEffect, nextSceneTime)
        elseif(name == "nextBtn") then 

            local function nextSceneOnDelay()
                goToNextLevel(nextLevel)
            end

            storyboard.hideOverlay(sceneEffect, uiTime) 
            timer.performWithDelay(uiTime, nextSceneOnDelay, 1) 
            
        end 
    end
end

-----------------------------------------------------------------------------------------------
    -- Main
-----------------------------------------------------------------------------------------------

local function winPopUp( level, screenGroup )

    local bg = display.newImage( infoGroup, "Images/Pause menu/background.png", X_Center, Y_Center ); 
    bg.xScale = 0.23; bg.yScale = 0.23;

    local options = 
    {
        parent = infoGroup,
        text = "Congratulations!",     
        x = X_Center,
        y = _H * 0.15,
        width = 256,     
        font = native.systemFontBold,   
        fontSize = 34,
        align = "center" 
    }

    local myText = display.newText( options )
    myText:setFillColor( 1, 1, 1 )

    options = 
    {
        parent = infoGroup,
        text = "You completed the level",     
        x = X_Center,
        y = _H * 0.3,
        width = 230,     
        font = native.systemFont,   
        fontSize = 28,
        align = "center" 
    }
    
    local myText2 = display.newText( options )
    myText2:setFillColor( 1, 1, 1 )

    local temp = " | 10"
    if(level == 10) then temp = " | 10"; nextScene = stageScene end

    options = 
    {
        parent = infoGroup,
        text = level .. temp,     
        x = X_Center,
        y = _H * 0.5,
        width = 230,     
        font = native.systemFont,   
        fontSize = 48,
        align = "center" 
    }
    
    local myText3 = display.newText( options )
    myText2:setFillColor( 1, 1, 1 )

    screenGroup:insert(infoGroup)
    
    if(level == 10) then
        local btn = genBtn( "Images/Pause menu/level_on_botton.png", "Images/Pause menu/level_off_botton.png", 50, 50, _W * 0.5, _H * 0.7, "stageSelectBtn", handleButtonEvent )
        screenGroup:insert(btn)
    else
        local btn = genBtn( "Images/Pause menu/level_on_botton.png", "Images/Pause menu/level_off_botton.png", 50, 50, _W * 0.3, _H * 0.7, "stageSelectBtn", handleButtonEvent )
        screenGroup:insert(btn)

        btn = genBtn( "Images/Pause menu/next_on_botton.png", "Images/Pause menu/next_off_botton.png", 50, 50, _W * 0.7, _H * 0.7, "nextBtn", handleButtonEvent )
        screenGroup:insert(btn)
    end

    local btn = display.newImage( "Images/puzzle_winscreen/win_icon.png",_W * 0.8, _H * 0.87 ); 
    btn.alpha = 0.85
    btn.xScale = 0.2; btn.yScale = 0.2;
    btn.rotation = 25
    screenGroup:insert(btn)

    nextLevel = level + 1

    unlockStage(nextLevel)
end

local function infoPopUp( msg, screenGroup )
    local bg = display.newImage( infoGroup, "Images/game/info_screen.png", X_Center, Y_Center ); 
    bg.xScale = 0.23; bg.yScale = 0.23;

    local options = 
    {
        parent = infoGroup,
        text = msg,     
        x = X_Center,
        y = 0.57 * _H,
        width = 256,     
        font = native.systemFontBold,   
        fontSize = 18,
        align = "center" 
    }

    local myText = display.newText( options )
    myText.anchorX = 0.5; myText.anchorY = 0.5;
    myText:setFillColor( 1, 1, 1 )

    screenGroup:insert(infoGroup)

    local  function destroyPopUp( ... )
        timer.cancel(timerDestroy);
        storyboard.hideOverlay(sceneEffect, nextSceneTime)
    end

    timerDestroy = timer.performWithDelay(timerBeforeDestroy, destroyPopUp, 1)
end

local function tutorialPopUp( msg, screenGroup )

    local bg = display.newImage( infoGroup, "Images/game/tutorial_screen.png", X_Center, Y_Center ); 
    bg.xScale = 0.23; bg.yScale = 0.23;

    local options = 
    {
        parent = infoGroup,
        text = msg,     
        x = X_Center,
        y = Y_Center,
        width = 256,     
        font = native.systemFontBold,   
        fontSize = 18,
        align = "center" 
    }

    local myText = display.newText( options )
    myText.anchorX = 0.5; myText.anchorY = 0.5;
    myText:setFillColor( 0, 0, 0 )
    
    local btn = genBtn("Images/game/OK_on_botton.png", "Images/game/OK_off_botton.png", 60, 60, X_Center, 0.65 * _H, "tutBtn", handleButtonEvent)
    infoGroup:insert(btn)

    screenGroup:insert(infoGroup)
end

local function clearTutorial()
    infoGroup:removeSelf()
end

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

function scene:createScene( event )
    print( "\nPopUp: createScene event" )

    local screenGroup = self.view

    local currEvent = event.params.name
    local text = ""
    local id = event.params.id

    if(currEvent == "Tutorial") then
        if(id == 1) then text = "The objective of the game is to get the laser to the goal. Use the 'Mirror' tile to reflect the ray."
        elseif(id == 2) then text = "The 'Glass' tile is used to split the ray into 2. Use it wisely."
        elseif(id == 3) then text = "The 'Solid' tile blocks the ray. Move it out of the way."
        elseif(id == 4) then text = "The 'Prism' tile can be used to change the orientation of the ray. Be smart."
        elseif(id == 5) then text = "Congratulations on making it this far! You have reached the final world. Have fun!"
        end

        tutorialPopUp(text, screenGroup)
    elseif(currEvent == "Info") then
        if(id == 1) then text = "Bonus : You got 2 extra hints!" end
        infoPopUp(text, screenGroup)
    elseif(currEvent == "Win") then
        winPopUp( event.params.level, screenGroup)
    end

    screenGroup:toFront()
 end

function scene:enterScene( event )
    print( "PopUp: enterScene event" )
end

function scene:exitScene()
    print( "PopUp: exitScene event" )
end

function scene:destroyScene( event )
    print( "((destroying scene PopUp's view))" )
    clearTutorial()
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