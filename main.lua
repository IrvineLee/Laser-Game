---------------------------------------------------------------------------------
--
-- Main.lua
--
---------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

-- Caches
_W = display.contentWidth;
_H = display.contentHeight;
X_Center = display.contentWidth / 2;
Y_Center = display.contentHeight / 2;

local widget = require( "widget" )

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local currOffset = 0

-- Global variables.
bgOffset = 30

timerAnim = nil
arrowLeft = nil
arrowRight = nil

-- Tweakable settings.
local nextScene = "ChallengeSelect"
local sceneEffect = "fade"
local nextSceneTime = 700

local alphaSpd = 8

local topFrame = display.newRect(0, -40, _W, 40)
topFrame.anchorX = 0.0; topFrame.anchorY = 0.0; 
topFrame:setFillColor(0, 255)

local btmFrame = display.newRect(0, _H, _W, 40)
btmFrame.anchorX = 0.0; btmFrame.anchorY = 0.0;
btmFrame:setFillColor(0, 255)

-------------------------- Global functions --------------------------

-- ScrollView listener
function scrollListener( event )
    
    local phase = event.phase
    local scrollView = event.target

    if ( phase == "began" or phase == "moved") then 
        arrowLeft.isVisible = false
        arrowRight.isVisible = false
    elseif ( phase == "ended" ) then 
        
        local function onScrollComplete()

        	local function arrowsReset()
				arrowLeft.alpha = 0
			    arrowLeft.isUpAlpha = true

				arrowRight.alpha = 0
				arrowRight.isUpAlpha = true
			end

            if(arrowLeft == nil or arrowRight == nil) then return end

            if(scrollView.currPage == 1) then arrowsReset(); arrowLeft.isVisible = false; arrowRight.isVisible = true;
            elseif(scrollView.currPage > 1 and scrollView.currPage < scrollView.maxPage) then 
            	arrowsReset()
            	arrowLeft.isVisible = true 
            	arrowRight.isVisible = true
            elseif(scrollView.currPage == scrollView.maxPage) then arrowsReset(); arrowLeft.isVisible = true; arrowRight.isVisible = false;
            end
        end
    
        local xDiff = event.xStart - event.x

        if(xDiff > 30 and scrollView.currPage < scrollView.maxPage) then
            currOffset = -_W * scrollView.currPage

            scrollView:scrollToPosition{ x = currOffset, time = 300, onComplete = onScrollComplete }
            scrollView.currPage = scrollView.currPage + 1

        elseif(xDiff < -30 and scrollView.currPage > 1) then
            currOffset = currOffset + _W

            scrollView:scrollToPosition{ x = currOffset, time = 300, onComplete = onScrollComplete }
            scrollView.currPage = scrollView.currPage - 1
        else 
        	scrollView:scrollToPosition{ x = currOffset, time = 300, onComplete = onScrollComplete }
        end
    end

    return true
end

function resetOffset( scrollView )
    scrollView.currPage = 1
    currOffset = 0
    scrollView:scrollToPosition{ x = 0, time = 50 }
end

function animateAlpha( object, spd )
    local alpha

    if(object.isUpAlpha == false) then

        alpha = object.alpha - (0.01 * spd)
        if(alpha <= 0) then object.isUpAlpha = true; object.alpha = 0 
        else object.alpha = alpha 
        end

    elseif(object.isUpAlpha) then

        alpha = object.alpha + (0.01 * spd)
        if(alpha >= 1) then object.isUpAlpha = false; object.alpha = 1
        else object.alpha = alpha 
        end

    end
end

function createArrows( isVisibleLeft, isVisibleRight )
    arrowLeft = display.newImage("Images/choose_challenge/left_botton.png", _W * 0.1, _H * 0.6);
    arrowLeft.xScale = 0.25; arrowLeft.yScale = 0.25;
    arrowLeft.isUpAlpha = false
    arrowLeft.isVisible = isVisibleLeft

    if(isVisibleLeft == nil) then arrowLeft.isVisible = false 
	elseif(isVisibleLeft ~= nil) then arrowLeft.isVisible = isVisibleLeft end
	
    arrowRight = display.newImage("Images/choose_challenge/right_botton.png", _W * 0.9, _H * 0.6);
    arrowRight.xScale = 0.25; arrowRight.yScale = 0.25;
    arrowRight.isUpAlpha = false
    
    if(isVisibleRight == nil) then arrowRight.isVisible = true 
	elseif(isVisibleRight ~= nil) then arrowRight.isVisible = isVisibleRight end

    local function startAnim() 
        animateAlpha( arrowLeft, alphaSpd ) 
        animateAlpha( arrowRight, alphaSpd ) 
    end
    timerAnim = timer.performWithDelay(1, startAnim, -1)

    local tempGroup = display.newGroup()
    tempGroup:insert(arrowLeft)
    tempGroup:insert(arrowRight)


    return tempGroup
end

function clearArrows()
	timer.cancel(timerAnim)
	arrowLeft:removeSelf(); arrowLeft = nil;
	arrowRight:removeSelf(); arrowRight = nil;
end

function genBtn( default, over, w, h, x, y, name, event )
    local button = widget.newButton
    {
    	font = "Arial",
        emboss = true,
        width = w,
        height = h,
        defaultFile = default,
        overFile = over,
        onEvent = event
    }
    button.anchorX = 0.5; button.anchorY = 0.5;
    button.x = x; button.y = y;
    button.name = name

    return button
end

function genBackBtn( event )
	local button = widget.newButton
    {
        font = "Arial",
        emboss = true,
        width = 50,
        height = 50,
        defaultFile = "Images/Mirrors_level/back_on_botton.png",
        overFile = "Images/Mirrors_level/back_off_botton.png",
        onEvent = event
    }
    button.anchorX = 0.5; button.anchorY = 0.5;
    button.x = X_Center; button.y = _H * 0.9
    button.name = "backBtn"

    return button
end


------------------------------------------------------------------------------

storyboard.loadScene("ChallengeSelect")
storyboard.loadScene("WorldSelection")
storyboard.loadScene("StageSelection")
storyboard.loadScene("MainGame")

storyboard.gotoScene( "MainMenu" );

