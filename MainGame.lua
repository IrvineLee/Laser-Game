local physics = require("physics") ; physics.start() ; physics.setGravity( 0,0 ) ; 
-- physics.setDrawMode( "hybrid" )

local loadsave = require("loadsave")

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local bgTileOrigGroup = display.newGroup()
local bgTileGroup = display.newGroup()
local blockGroup = display.newGroup()
local laserGenGroup = display.newGroup()
local goalGroup = display.newGroup()
local goalActiveGroup = display.newGroup()
local beamGroup = display.newGroup()
local burstGroup = display.newGroup()

local lasersTbl = {}
local blockObjectTbl = {}
local blockPlacemenIDTbl = {}
local answerIDTbl = {}
local emptyIDTbl = {}

local latePrismRayTbl = {}

local bgTileImg = "Images/square_yellow.png"
local laserGenImg = "Images/game/Laser.png"
local goalImg = "Images/game/target_inactive.png"
local goalActiveImg = "Images/game/target.png"
local burstImg = "Images/burst.png"

local blockImg = "Images/game/mirror.png"
local glassImg = "Images/game/glass.png"
local prismImg = "Images/game/Prism.png"
local solidImg = "Images/game/solid.png"

local blockLockedImg = "Images/game/mirror_locked.png"
local glassLockedImg = "Images/game/glass_locked.png"
local prismLockedImg = "Images/game/Prism_locked.png"
local solidLockedImg = "Images/game/solid_locked.png"

local currLaser = 0
local spawnPosSave = { x = 0, y = 0 }
local goalPos = { x = 0, y = 0 }
local mTimer = nil
local mTimerPrism = nil
local currBounceCount = 0
local isGoalGenerated = false

local stageTitle
local maxStageTime = 2
local stageProperties = {}
local hintText

local screenGroup

local givenHintTbl = {}
local showWinTimer = false

local testray = 0

-- Bgs
local mirrorBg = "Images/game/background_mirrors.png"
local glassBg = "Images/game/background_glass.png"
local prismBg = "Images/game/background_prisms.png"
local solidBg = "Images/game/background_Solids.png"
local twistedBg = "Images/game/background_twisted.png"
local hardBg = "Images/game/background_hard.png"

-- Visual effects
local menuGroup = display.newGroup()
local pauseGroup = display.newGroup()
local soundOnGroup = display.newGroup()
local soundOffGroup = display.newGroup()

local scrollView

-- Tweakable settings.
local row = 4
local col = 3
local maxBounceCount = 2
local marginX = 55
local marginY = 140
local tileSpacing = 1
local tileScale = 0.8
local goalScale = 0.3
local beamColor = 
{
	 r = 255, 
	 g = 0, 
	 b = 0,
	 a = 1 
}
local blendMode = "Multiply"
local deleteTileMin = 2
local deleteTileMax = 2
local solidTileMin = 3
local solidTileMax = 4
local resetCount = 1
local totalHints = 5

local maxTileType = {}
maxTileType[1] = { name = "Mirror", currCount = 0, maxCount = maxBounceCount }
maxTileType[2] = { name = "Glass", currCount = 0, maxCount = maxBounceCount } 
maxTileType[3] = { name = "Solid", currCount = 0, maxCount = maxBounceCount } 
maxTileType[4] = { name = "Prism", currCount = 0, maxCount = 0 } 

local getHintsCount = 3

local nextScene = "PopUp"
local sceneEffect = "fade"
local nextSceneTime = 200

-----------------------------------------------------------------------------------------------
	-- Helper functions
-----------------------------------------------------------------------------------------------

-- -- Check to see whether a pos in within an image.
function isWithinImg(pos, img)
	local imgHalfWidth = img.contentWidth * 0.5;
	local imgHalfHeight = img.contentHeight * 0.5;

	local xMin = img.x - imgHalfWidth;
	local xMax = img.x + imgHalfWidth;
	local yMin = img.y - imgHalfHeight;
	local yMax = img.y + imgHalfHeight;

	local x = pos.x;
	local y = pos.y;
	if(x > xMin and x < xMax and y > yMin and y < yMax) then
		--print("Within image");
		return true;
	end
	return false;
end

function hasValWithinTbl(val, tbl)
	local hasIndex = false
		for i = 1, #tbl, 1 do
			if(tbl[i] == val) then return true end
		end
		return false
	end

function clearTbl(tbl)
	if(#tbl == 0) then return end

	local count = 0

	for i = 1, #tbl, 1 do
		table.remove(tbl)
		count = count + 1
	end
	print(count .. " entries removed. Tbl count is : " .. #tbl)
end

function removeSelf( obj )
	if(obj ~= nil) then obj:removeSelf() end
end

-----------------------------------------------------------------------------------------------


local function reinitializeDefault( isFullReset )
	bgTileOrigGroup:removeSelf()
	bgTileGroup:removeSelf()
	blockGroup:removeSelf()
	laserGenGroup:removeSelf()
	goalGroup:removeSelf()
	goalActiveGroup:removeSelf()
	beamGroup:removeSelf()
	burstGroup:removeSelf()

	bgTileOrigGroup = display.newGroup()
	bgTileGroup = display.newGroup()
	blockGroup = display.newGroup()
	laserGenGroup = display.newGroup()
	goalGroup = display.newGroup()
	goalActiveGroup = display.newGroup()
	beamGroup = display.newGroup()
	burstGroup = display.newGroup()

	lasersTbl = {}
	blockObjectTbl = {}
	blockPlacemenIDTbl = {}
	answerIDTbl = {}

	currLaser = 0
	goalPos = { x = 0, y = 0 }
	mTimer = nil
	currBounceCount = 0
	isGoalGenerated = false

	showWinTimer = false
	givenHintTbl = {}

	if(isFullReset) then
		removeSelf(stageTitle)
		removeSelf(menuGroup)
		removeSelf(pauseGroup)
		removeSelf(soundOnGroup)
		removeSelf(soundOffGroup)

		menuGroup = display.newGroup()
		pauseGroup = display.newGroup()
		soundOnGroup = display.newGroup()
		soundOffGroup = display.newGroup()

		stageTitle = nil
	end
end

-----------------------------------------------------------------------------------------------
	-- Event functions
-----------------------------------------------------------------------------------------------

local function dragDropEvent(event)

	event.target:toFront()
	if(event.target.isLocked) then return end

	if(event.phase == "began") then
		display.getCurrentStage():setFocus(event.target);
		event.target.isFocus = true;
	elseif event.target.isFocus then
		if(event.phase == "moved") then
			event.target.x = event.x;
			event.target.y = event.y;

		elseif(event.phase == "ended") then
			display.getCurrentStage():setFocus(nil);
			event.target.isFocus = false;

			local isResetPos = true;
			for i = 1, bgTileGroup.numChildren, 1 do

				if( isWithinImg( { x = event.x, y = event.y }, bgTileGroup[i]) ) then 
					
					local prevID = event.target.inhibitIndex

					if(prevID == bgTileGroup[i].id or bgTileGroup[i].isInhibit) then break 
					else
						print("\nPREV ID : " .. prevID)
						event.target.inhibitIndex = bgTileGroup[i].id

						for k = 1, bgTileGroup.numChildren, 1 do
							if(bgTileGroup[k].id == prevID) then 
								bgTileGroup[k].isInhibit = false 
							end
						end
						bgTileGroup[i].isInhibit = true
					end

					print("Drag onto tile ID: " .. bgTileGroup[i].id) 

					event.target.x = bgTileGroup[i].x;
					event.target.y = bgTileGroup[i].y;
					event.target.prevX = bgTileGroup[i].x;
					event.target.prevY = bgTileGroup[i].y;

					refreshRay()
					isResetPos = false
					break
				end
			end
			
			if(isResetPos) then
				event.target.x = event.target.prevX;
				event.target.y = event.target.prevY;
			end
		end
	end
	return true;
end

local function showHint()
	print("\nSHOW HINTS!!\n")
	local function hasVal( val, string )
		for i = 1, #givenHintTbl, 1 do
			local id

			if(string == "answerID") then id = givenHintTbl[i].answerID
			elseif(string == "blockIndex") then id = givenHintTbl[i].blockIndex
			end
			
			if(id == val) then return true end
		end

		return false
	end

	if(#givenHintTbl == #answerIDTbl) then 
		if(#emptyIDTbl == 0) then return 
		elseif(#emptyIDTbl ~= 0) then

			local freeIDTbl = {}
			for i = 1, bgTileGroup.numChildren, 1 do

				if(bgTileGroup[i].isInhibit == false) then

					local isObstructing = false

					for j = 1, #emptyIDTbl, 1 do
						if(emptyIDTbl[j] == bgTileGroup[i].id) then isObstructing = true
						end
					end

					if(isObstructing == false) then
						table.insert(freeIDTbl, bgTileGroup[i].id)
					end

				end

			end

			for i = 1, #emptyIDTbl, 1 do
				for j = 1, #blockObjectTbl, 1 do
					local tileID = blockObjectTbl[j].img.inhibitIndex

					-- If a tile is currently on a supposedly empty spot, move it to a free spot.
					if(emptyIDTbl[i] == tileID) then 
						local rand = math.random(1, #freeIDTbl)
						local id = freeIDTbl[rand]
						local x,y

						for k = 1, bgTileGroup.numChildren, 1 do
							if(bgTileGroup[k].id == tileID) then
								bgTileGroup[k].isInhibit = false
								break
							end
						end

						for k = 1, bgTileGroup.numChildren, 1 do
							if(bgTileGroup[k].id == id) then
								x = bgTileGroup[k].x
								y = bgTileGroup[k].y
								bgTileGroup[k].isInhibit = true
								break
							end
						end

						blockObjectTbl[j].img.x = x
						blockObjectTbl[j].img.y = y
						blockObjectTbl[j].img.prevX = x
						blockObjectTbl[j].img.prevY = y
						blockObjectTbl[j].img.inhibitIndex = id

						refreshRay()
						return 

					end
				end

			end
		end

	end

	local randIndex
	local answerID, answerType

	repeat
		randIndex = math.random(1, #answerIDTbl)

		if( type(answerIDTbl[randIndex]) == "table" ) then
			answerID = answerIDTbl[randIndex].answerID
			answerType = answerIDTbl[randIndex].answerType
			print("Suggested answer ID : " .. answerID)
			print("Suggested answer type : " .. answerType)
		else answerID = answerIDTbl[randIndex]; print("Suggested answer ID : " .. answerID)
		end

	until(#givenHintTbl == 0 or hasVal( answerID, "answerID" ) == false)

	local sameTypeTbl = {}

	-- Isolate all the same answer type tile into a table.
	for i = 1, #blockObjectTbl, 1 do
		if(blockObjectTbl[i].img.type == answerType) then
			if(blockObjectTbl[i].img.isLocked == false) then
				print("SAME TYPE "..blockObjectTbl[i].img.inhibitIndex)
				table.insert(sameTypeTbl, blockObjectTbl[i])
			end
		end
	end

	repeat
		local isRollAgain = false

		if(answerType == nil) then
			randIndex = math.random(1, #blockObjectTbl)
			if(blockObjectTbl[randIndex].img.isLocked) then isRollAgain = true end
		else
			randIndex = math.random(1, #sameTypeTbl)
		
			local toMoveTileID = sameTypeTbl[randIndex].img.inhibitIndex
			print("Chosen tile to move :" .. toMoveTileID)

			for i = 1, #blockObjectTbl, 1 do
				if(blockObjectTbl[i].img.inhibitIndex == toMoveTileID) then
					randIndex = i
					break
				end
			end
		end

	until( isRollAgain == false and (#givenHintTbl == 0 or hasVal( randIndex, "blockIndex" ) == false) )

	for i = 1, bgTileGroup.numChildren, 1 do 
		if(bgTileGroup[i].id == answerID) then
			print("I is : " .. i)
			print("AnswerID is : " .. answerID)
			print("block x : " .. blockObjectTbl[randIndex].img.x)
			print("block y :" .. blockObjectTbl[randIndex].img.y)

			print("bgTileGroup[i].x: " .. bgTileGroup[i].x)
			print("bgTileGroup[i].x :" .. bgTileGroup[i].y)

			-- if(bgTileGroup[i].isInhibit)

			local blockPos = { x = blockObjectTbl[randIndex].img.x,  y = blockObjectTbl[randIndex].img.y }
			local moveToPos = { x = bgTileGroup[i].x,  y = bgTileGroup[i].y }

			if( blockPos.x == moveToPos.x and blockPos.y == moveToPos.y) then
				print("SAME!!!")

			else


				if(bgTileGroup[i].isInhibit) then
					-- Exchange places.

					print("Swapping places...")
					print("BG ID: " .. bgTileGroup[i].id)
					for j = 1, #blockObjectTbl, 1 do

						if(bgTileGroup[i].id == blockObjectTbl[j].img.inhibitIndex) then
							print("Inhibit index : " .. blockObjectTbl[j].img.inhibitIndex)

							blockObjectTbl[j].img.x = blockObjectTbl[randIndex].img.x
							blockObjectTbl[j].img.y = blockObjectTbl[randIndex].img.y

							blockObjectTbl[j].img.inhibitIndex = blockObjectTbl[randIndex].img.inhibitIndex 
							blockObjectTbl[randIndex].img.inhibitIndex = bgTileGroup[i].id

							blockObjectTbl[j].img.prevX = blockObjectTbl[randIndex].img.x
							blockObjectTbl[j].img.prevY = blockObjectTbl[randIndex].img.y

							print("Swapped")
							break
						end
					end

					blockObjectTbl[randIndex].img.x = bgTileGroup[i].x
					blockObjectTbl[randIndex].img.y = bgTileGroup[i].y

					blockObjectTbl[randIndex].img.prevX = bgTileGroup[i].x
					blockObjectTbl[randIndex].img.prevY = bgTileGroup[i].y
				else
					blockObjectTbl[randIndex].img.x = bgTileGroup[i].x
					blockObjectTbl[randIndex].img.y = bgTileGroup[i].y
					bgTileGroup[i].isInhibit = true

					local prevInhibitIndex = blockObjectTbl[randIndex].img.inhibitIndex
					for j = 1, bgTileGroup.numChildren, 1 do 
						if(bgTileGroup[j].id == prevInhibitIndex) then
							bgTileGroup[j].isInhibit = false
						end
					end
					
					blockObjectTbl[randIndex].img.inhibitIndex = answerID
				end
				

			end

			local tempTbl = { answerID = answerID, blockIndex = randIndex}
			table.insert(givenHintTbl, tempTbl)
			print("givenHintTbl.answerID  " .. givenHintTbl[#givenHintTbl].answerID)
			print("givenHintTbl.blockIndex  " .. givenHintTbl[#givenHintTbl].blockIndex)

			display.newImage( goalImg, moveToPos.x, moveToPos.y )

			print("\n\n\CHECK!!!!!")
			for k = 1, #blockObjectTbl, 1 do
				if(blockObjectTbl[k].img.isLocked == false) then
					print(blockObjectTbl[k].img.inhibitIndex)
				end
			end
			print("\CHECK!!!!!\n\n")

			break
		end
	end

	refreshRay()
end

-- Function to handle button events
local function handleButtonEvent( event )
    if ( "ended" == event.phase ) then
    	local name = event.target.name

		if(name == "hintBtn") then

    		if(totalHints == 0) then return end

    		showHint()
    		totalHints = totalHints - 1
    		hintText.text = totalHints
    		
    		dataTable.hints = totalHints
			loadsave.saveTable(dataTable, "dataTable.json")

    	elseif(name == "moreBtn") then

    		print("MORE!")

    		local delay = 200
    		local currStage = stageProperties.mlevel

    		if(currStage % 5 == 0) then
    			
    			local currWorld = stageProperties.mworld

    			if( (currStage == 5 and dataTable.world[currWorld].getStage5Hint) or
    				(currStage == 10 and dataTable.world[currWorld].getStage10Hint) ) then

    				local options =
				    {
				        effect = sceneEffect,
				        time = nextSceneTime,
				        isModal = true,
				        params =
				        {
				        	name = "Info",
				        	id = 1,
				        	level = stageProperties.mlevel
				    	}
				    }

				    local function nextOnDelay()
				    	totalHints = totalHints + getHintsCount
	    				hintText.text = totalHints

	    				if(currStage == 5) then dataTable.world[currWorld].getStage5Hint = false
	    				elseif(currStage == 10) then dataTable.world[currWorld].getStage10Hint = false
	    				end

	    				dataTable.hints = totalHints
			    		loadsave.saveTable(dataTable, "dataTable.json")

				    	storyboard.showOverlay( nextScene, options )
				    end

				    timer.performWithDelay( delay, nextOnDelay )
				    delay = 2850
				end
		    	
		    end

			local options =
		    {
		        effect = sceneEffect,
		        time = nextSceneTime,
		        isModal = true,
		        params =
		        {
		        	name = "Win",
		        	id = 1,
		        	level = stageProperties.mlevel
		    	}
		    }

		    local function nextOnDelay()
		    	storyboard.showOverlay( nextScene, options )
		    end

		    timer.performWithDelay( delay, nextOnDelay )
		    showWinTimer = true

    	elseif(name == "menuBtn") then

    		scrollView:toFront()
    		scrollView:scrollToPosition{ y = _H, time = 300 }

    	elseif(name == "levelSelectBtn") then

    		 print("levelSelectBtn!")
        	storyboard.gotoScene( "StageSelection", sceneEffect, nextSceneTime );

    	elseif(name == "soundBtnOn") then

    		-- audio.stop()
    		soundOnGroup.isVisible = false
    		soundOffGroup.isVisible = true

		elseif(name == "soundBtnOff") then

			-- TODO: AUDIO PLAY.
    		soundOnGroup.isVisible = true
    		soundOffGroup.isVisible = false

    	elseif(name == "restartBtn") then

    		 print("restartBtn!")
    		 reinitializeDefault()
    		 restartLevel()

    	elseif(name == "nextBtn") then
    		
    		 print("nextBtn!")

    	elseif(name == "resumeBtn") then 

    		local function toBack()
    			scrollView:toBack()
    		end
    		
    		scrollView:scrollToPosition{ y = -1, time = 300 }
			timer.performWithDelay( 300, toBack )
    	end
        -- storyboard.gotoScene( nextLvl, sceneEffect, nextSceneTime );
    end
end

-----------------------------------------------------------------------------------------------
	-- Main
-----------------------------------------------------------------------------------------------

-- Clear the visual rays.
local function clearRayGroup()
	for i = 1, burstGroup.numChildren, 1 do
		burstGroup:remove(1)
	end
	
	for i = 1, beamGroup.numChildren, 1 do
		beamGroup:remove(1)
	end
end

-- Reset to default state.
local function resetToDefault()
	clearRayGroup()
	for i = 1, #blockObjectTbl, 1 do
		local index = blockObjectTbl[i].img.inhibitIndex
		bgTileGroup[index].isInhibit = false

		blockObjectTbl[i].img:removeSelf()
	end
	clearTbl(blockObjectTbl)
	clearTbl(blockPlacemenIDTbl)
	clearTbl(answerIDTbl)

	currBounceCount = 0
	isGoalGenerated = false
	-- isReflect = true
end

-- Generate background tiles.
local function genBgTile()
	for i = 1, row, 1 do
		for j = 1, col, 1 do
			local img = display.newImage( bgTileGroup, bgTileImg )

			local count = bgTileGroup.numChildren
			bgTileGroup[count].id = count
			bgTileGroup[count].isInhibit = false

			-- bgTileOrigGroup[count].id = count
			-- bgTileOrigGroup[count].isInhibit = false

			img.xScale = tileScale
			img.yScale = tileScale
			img.x = marginX + ( (j - 1) * (img.contentWidth + tileSpacing) )
			img.y = marginY + ( (i - 1) * (img.contentHeight + tileSpacing) )
			img.alpha = 0.5
		end
	end
end

local function getAvailableBlock( startLvl, clearanceLvl )

	if(clearanceLvl == 1) then return "Mirror" end

	local tempTbl = {}
	local id = nil

	repeat
		local rand = math.random(startLvl, clearanceLvl)
		
		if(hasValWithinTbl(rand, tempTbl) == false) then
			if(maxTileType[rand].currCount >= maxTileType[rand].maxCount) then
				table.insert(tempTbl, rand) 
			else id = rand
			end
		end
	until(id ~= nil)

	if(id == 1) then print( "Type: Mirror"); return "Mirror"
	elseif(id == 2) then print( "Type: Glass"); return "Glass"
	elseif(id == 3) then print( "Type: Prism"); return "Prism"
	elseif(id == 4) then print( "Type: Solid"); return "Solid"
	end
end

-- Generate blocks for player to move.
local function genBlock(index, bType, isLocked)
	local tileID = index
	for i = 1, bgTileGroup.numChildren, 1 do
		if(bgTileGroup[i].id == index) then index = i; break end
	end

	local imgFile
	local blockType = bType

	if(bType == nil) then
		if(isGoalGenerated) then
			blockType = "Prism"--getAvailableBlock(1, 2)
		else blockType = "Mirror"
		end
		
	end

	if(isLocked == nil) then isLocked = false end

	if(blockType == "Mirror") then 
		imgFile = blockImg
		if(isLocked) then imgFile = blockLockedImg end
	elseif(blockType == "Glass") then 
		imgFile = glassImg
		if(isLocked) then imgFile = glassLockedImg end
	elseif(blockType == "Prism") then 
		imgFile = prismImg
		if(isLocked) then imgFile = prismLockedImg end
	elseif(blockType == "Solid") then 
		imgFile = solidImg
		if(isLocked) then imgFile = solidLockedImg end
	end

	local blockObj = 
	{
		img = display.newImage( imgFile, bgTileGroup[index].x, bgTileGroup[index].y, true ),
	}
	blockObj.img.id = blockGroup.numChildren + 1
	blockObj.img.prevX = bgTileGroup[index].x
	blockObj.img.prevY = bgTileGroup[index].y
	blockObj.img.xScale = tileScale
	blockObj.img.yScale = tileScale
	blockObj.img.inhibitIndex = tileID
	blockObj.img.type = blockType
	blockObj.img.isLocked = isLocked

	table.insert(blockObjectTbl, blockObj) 

	blockGroup:insert(blockObj.img)

	local w = blockObj.img.contentWidth / 2
	local h = blockObj.img.contentHeight / 2

	physics.addBody( blockObj.img, "static", {shape = { -w, -h, w, -h, w, h, -w, h }} )
	blockObj.img:addEventListener("touch", dragDropEvent);

	bgTileGroup[index].isInhibit = true
end

local function randomizeBlocks()
	local tempIDTbl = {}
	local sameIDCount

	-- Get potential spawn positions. Randomize again when all spawn positions are the same as the answer table.
	repeat
		sameIDCount = 0
		clearTbl(tempIDTbl)

		for i = 1, #answerIDTbl, 1 do
			local tileID

			repeat
				local index = math.random( 1, bgTileGroup.numChildren )
				tileID = bgTileGroup[index].id
			until(hasValWithinTbl(tileID, tempIDTbl) == false) 

			table.insert(tempIDTbl, tileID) 

			if(answerIDTbl[i] == tileID) then sameIDCount = sameIDCount + 1 end
		end
	until(sameIDCount ~= maxBounceCount)
	
	for i = 1, #answerIDTbl, 1 do
		print("\nBlock generated at :" .. tempIDTbl[i])
		genBlock( tempIDTbl[i] )
	end
end

-- Delete unused tiles at random.
local function randomizeDeletion()

	local function IsInhibited(id, tbl)
		for j = 1, #tbl, 1 do
			if(tbl[j].img.inhibitIndex == id) then return true; end
		end
		return false
	end

	local deleteCount = math.random( deleteTileMin, deleteTileMax )

	for i = 1, deleteCount, 1 do
		
		repeat
			local index = math.random( 1, bgTileGroup.numChildren )
			local tileID = bgTileGroup[index].id
			local isSameVal = true

			if(hasValWithinTbl(tileID, answerIDTbl) == false and IsInhibited(tileID, blockObjectTbl) == false) then
				print("REMOVED TILE ID : " .. tileID)
				bgTileGroup[index]:removeSelf()
				isSameVal = false
			end
		until (isSameVal == false)
		
	end
end

local function randomizeSolidTile()

	local function IsInhibited(id, tbl)
		for j = 1, #tbl, 1 do
			if(tbl[j].img.inhibitIndex == id) then return true; end
		end
		return false
	end

	local solidCount = math.random( solidTileMin, solidTileMax )

	for i = 1, solidCount, 1 do
		
		local isBreak = false

		repeat
			local index = math.random( 1, bgTileGroup.numChildren )
			local tileID = bgTileGroup[index].id

			if(IsInhibited(tileID, blockObjectTbl) == false) then
				print("Solid spawned at ID : " .. tileID)
				genBlock( tileID,"Solid" )
				isBreak = true
			end
		until(isBreak)
	end
end

local function latePrismRay( startX, startY, destX, destY )
	local hits = physics.rayCast( startX, startY, destX, destY, "sorted" ) 
	local reflectDestX, reflectDestY

	if ( hits ) then
		-- Reflect rays.
		local hitFirst = hits[1] 
		local hitX, hitY = hitFirst.position.x, hitFirst.position.y  --store hitX and hitY to local variables

		local goal = display.newImage( goalGroup, goalImg, hitX, hitY )
		goal.xScale = goalScale; goal.yScale = goalScale;

		blockGroup[blockGroup.numChildren]:removeSelf()
	end

end

local function getDir(start, dest)
	local dirX = dest.x - start.x
	local dirY = dest.y - start.y

	if(dirX > 0) then dirX = 1
	elseif(dirX < 0) then dirX = -1
	else dirX = 0
	end

	if(dirY > 0) then dirY = 1
	elseif(dirY < 0) then dirY = -1
	else dirY = 0
	end

	return dirX, dirY
end

-- Goal generator.
local function genGoal(startX, startY, destX, destY, hits, reflectDestX, reflectDestY)

	local tilCustomSize = { x = bgTileGroup[1].contentWidth * 0.45, y = bgTileGroup[1].contentHeight * 0.45 }
	local i = 1
	local nextX, nextY = 0, 0
	local isIntersect = true

	local dirX, dirY = getDir( { x = startX, y = startY }, { x = destX, y = destY } )
	local goalX, goalY

	local isSkipFirst = true

	print("\n New Ray")
	while (isIntersect) do

		if(hits) then
			local hitFirst = hits[1] 
			local hitX, hitY = hitFirst.position.x, hitFirst.position.y
			
			if(hitFirst.object == nil) then return end
			
			local objHitID = hitFirst.object.inhibitIndex

			currBounceCount = currBounceCount + 1

			if(hasValWithinTbl(objHitID, answerIDTbl) == false) then table.insert(answerIDTbl, objHitID) end

			print("HIT tile ID : " .. objHitID); 
			print("Current bounce count: " .. currBounceCount)

			if(currBounceCount == maxBounceCount) then 
				print("Max bounce reached. Generating goal..")
				dirX, dirY = getDir( { x = hitX, y = hitY }, { x = reflectDestX, y = reflectDestY } )

				goalX = hitX + ( dirX * ( (bgTileGroup[1].contentWidth / 2)) )
				goalY = hitY + ( dirY * ( (bgTileGroup[1].contentHeight / 2)) )
				goalPos.x = goalX
				goalPos.y = goalY

				print("\n\nspawnPos.x" .. spawnPosSave.x)
				print("spawnPos.y" .. spawnPosSave.y)
				print("goalPos.x" .. goalPos.x)
				print("goalPos.y" .. goalPos.y .. "\n\n")

				for k = 1, laserGenGroup.numChildren, 1 do
					if(isWithinImg( { x = goalX, y = goalY }, laserGenGroup[k]) ) then 
						print("Laser and goal at same position. Resetting..")
						resetToDefault()
						return 
					end
				end
				local goal = display.newImage( goalGroup, goalImg, goalX, goalY )
				goal.xScale = goalScale; goal.yScale = goalScale;
			end
					
		else
			nextX = startX + tilCustomSize.x * dirX * i
			nextY = startY + tilCustomSize.y * dirY * i
		end

		-----------------------------------------------------------
		-- Debugging purposes.
		-----------------------------------------------------------
		for j = 1, bgTileGroup.numChildren, 1 do
			if(isWithinImg( { x = nextX, y = nextY }, bgTileGroup[j])) then 

				if(isSkipFirst == false) then
					if(hasValWithinTbl(j, blockPlacemenIDTbl) == false) then table.insert(blockPlacemenIDTbl, j); end
				end
				isSkipFirst = false
				i = i + 1
				isIntersect = true
				break
				-- print("Is within tile ID: " .. j)
				-- local intersected = display.newImage( burstImg ) ; intersected.x, intersected.y = nextX, nextY ; intersected.blendMode = "add"
			else isIntersect = false
			end
		end
		-----------------------------------------------------------
	end
	
	-----------------------------------------------------------
	-- Debugging purposes.
	-----------------------------------------------------------
	if(#blockPlacemenIDTbl ~= 0) then
		print("Possible spawn count: " .. #blockPlacemenIDTbl)
		for k = 1, #blockPlacemenIDTbl, 1 do
			print(" - " .. blockPlacemenIDTbl[k])
		end
	end

	if(#answerIDTbl ~= 0) then
		print("Answer count: " .. #answerIDTbl)
		-- for k = 1, #answerIDTbl, 1 do
		-- 	print(answerIDTbl[k])
		-- end
	end
	-----------------------------------------------------------

	if(hits == nil and #blockPlacemenIDTbl == 0) then
		print("----------------------------------------\nNo more possible move. Resetting..\n----------------------------------------")
		if(resetCount == 0) then 
			resetCurrentRay(false) 
			resetCount = resetCount + 1
		else resetCurrentRay(true) 
		end
		return
	end

	if(isGoalGenerated == false) then
		if(currBounceCount < maxBounceCount) then 

			if(#blockPlacemenIDTbl == 0) then return end
			
			local index
			local isLaserPos
			local tileID
			repeat
				isLaserPos = false
				index = math.random( 1, #blockPlacemenIDTbl )
				tileID = blockPlacemenIDTbl[index]

				for i = 1, #lasersTbl, 1 do
					print("Laser tileID : " .. lasersTbl[i].tileID)
					print("Randomized tileID : " .. tileID)
					-- if(lasersTbl[i].tileID == tileID) then isLaserPos = true; break; end
				end

			until (bgTileGroup[tileID].isInhibit == false)
			-- until (bgTileGroup[tileID].isInhibit == false and isLaserPos == false)

			genBlock( blockPlacemenIDTbl[index] )
			print("Block generated at tile ID : " .. blockPlacemenIDTbl[index])
			clearTbl(answerIDTbl)
			refreshRay() 
		elseif(currBounceCount == maxBounceCount) then

			if(hits ~= nil) then

				if(#answerIDTbl ~= 0) then
					print("\nAnswer")
					print("-----------")
					for k = 1, #answerIDTbl, 1 do
						print(answerIDTbl[k])
					end
					print("")
				end

				-- Reflective rays.
				local hitFirst = hits[1] 
				local hitX, hitY = hitFirst.position.x, hitFirst.position.y

				local beam1 = display.newLine( beamGroup, hitX, hitY, goalX, goalY )
				beam1.strokeWidth = 3 ; beam1:setStrokeColor( beamColor.r, beamColor.g, beamColor.b, beamColor.a ) ; beam1.blendMode = blendMode

				for i = 1, #blockObjectTbl, 1 do
					local index = blockObjectTbl[i].img.inhibitIndex
					bgTileGroup[index].isInhibit = false

					blockObjectTbl[i].img:removeSelf()
				end
				clearTbl(blockObjectTbl)

				if(mTimer ~= nil) then timer.cancel( mTimer ) end
				if(mTimerPrism ~= nil) then timer.cancel( mTimerPrism ) end
				
				clearRayGroup()
				timer.performWithDelay( 1, refreshRay )
				isGoalGenerated = true

				randomizeDeletion()
				randomizeBlocks()
				randomizeSolidTile()
			else

				-- Prism rays.
				clearTbl(answerIDTbl)
				print("\nAnswer")
				print("-----------")
				for i = 1, blockGroup.numChildren, 1 do
					table.insert(answerIDTbl, blockGroup[i].inhibitIndex)
					print( blockGroup[i].inhibitIndex )
				end
				print("")

				index = math.random( 1, #blockPlacemenIDTbl )
				genBlock( blockPlacemenIDTbl[index] )

				local function nextOnDelay()
					local fromX = latePrismRayTbl.fromX
					local fromY = latePrismRayTbl.fromY
					local toX = latePrismRayTbl.toX
					local toY = latePrismRayTbl.toY

					latePrismRay( fromX, fromY, toX, toY )
				end
				mTimerPrism = timer.performWithDelay( 1, nextOnDelay )
				isGoalGenerated = true
			end

		end
	end
end

-- Check to see whether it's the correct answer.
local function isCorrectAnswer()
	print("Checking answer...")

	for i = 1, #emptyIDTbl, 1 do
		for j = 1, #blockObjectTbl, 1 do
			local tileID = blockObjectTbl[j].img.inhibitIndex

			if(emptyIDTbl[i] == tileID) then return false end
		end
	end

	for i = 1, #answerIDTbl, 1 do
		local isGotVal = false
		local tempAnswer = nil
		local tempType = nil

		if( type(answerIDTbl[1]) == "table" ) then 
			tempAnswer = answerIDTbl[i].answerID
			tempType = answerIDTbl[i].answerType
		else tempAnswer = answerIDTbl[i]
		end

		for j = 1, #blockObjectTbl, 1 do
			local tileID = blockObjectTbl[j].img.inhibitIndex
			local tileType = blockObjectTbl[j].img.type

			if(tempAnswer == tileID) then
				if(tempType == nil or tempType == tileType) then 
					isGotVal = true
					break
				end
				
			end
		end
		
		if(isGotVal == false) then return false end
	end

	
	print("Correct Answer")
	return true
end

-- Raycasting.
local function castRay( startX, startY, destX, destY, rayID, prevBounced, isReflect )

	local function prismDistortion()
		print("Check for 3rd ray")

		-- For prism distortion ray.
		if(isReflect == false) then

			-- print("3rd draw")

			-- Get dir within prism. Top, Btm, Left, Right.
			local dirX, dirY = getDir( { x = startX, y = startY }, { x = destX, y = destY } )
			local midpointX, midpointY

			-- Get midpoint to ensure a point is within a certain image rather than a few pixels off the edge, possibly getting a wrong result.
			if(startY == destY) then
				print("Horizontal")
				midpointX = startX + ((blockGroup[1].contentWidth / 2) * dirX) 
				midpointY = startY
			elseif(startX == destX) then
				print("Vertical")
				midpointX = startX
				midpointY = startY + ((blockGroup[1].contentHeight / 2) * dirY)
			end

			if(midpointX == nil and midpointY == nil) then return end

			for j = 1, blockGroup.numChildren, 1 do

				if( blockGroup[j].type == "Prism"  and  isWithinImg( { x = midpointX, y = midpointY }, blockGroup[j] ) ) then
					
					local dirX = lasersTbl[rayID].dir.x
					local dirY = lasersTbl[rayID].dir.y

					print(dirX)
					print(dirY)

					local nextRayX = destX + (dirX * (_W + tileSpacing + testray))
					local nextRayY = destY + (dirY * (_W + tileSpacing + testray))
					currBounceCount = currBounceCount + 1

					local function nextOnDelay()
						print("3rd ray is produced")
						castRay( destX, destY, nextRayX, nextRayY, rayID, "Prism", true )
					end

					mTimerPrism = timer.performWithDelay( 1, nextOnDelay )

					if(currBounceCount == maxBounceCount) then
						latePrismRayTbl = { fromX = destX, fromY = destY, toX = nextRayX, toY = nextRayY }
					end	

					break
				end

			end

		end
	end

	local function endOfHorizontalPrism()
		print("PrismHorizontal hitting glass tile")

		-- Draw the horizontal ray.
		local beam1 = display.newLine( beamGroup, startX, startY, destX, destY )
		beam1.strokeWidth = 3 ; beam1:setStrokeColor(  beamColor.r, beamColor.g, beamColor.b, beamColor.a ) ; beam1.blendMode = blendMode

		local dirX, dirY = getDir( { x = startX, y = startY }, { x = destX, y = destY } )

		local nextRayX, nextRayY
		if(dirX == 0) then 
			print("Vertical") 
			print(lasersTbl[rayID].dir.x)
			print(lasersTbl[rayID].dir.y)
			nextRayX = startX + (lasersTbl[rayID].dir.x * (_W + tileSpacing + testray))
			nextRayY = startY + (-lasersTbl[rayID].dir.y * (_W + tileSpacing + testray))
		elseif(dirY == 0) then 
			print("Horizontal") 
			nextRayX = startX + (-lasersTbl[rayID].dir.x * (_W + tileSpacing + testray))
			nextRayY = startY + (lasersTbl[rayID].dir.y * (_W + tileSpacing + testray))

			print(nextRayX)
			print(nextRayY)
		end

		local function nextOnDelay()
			castRay( startX, startY, nextRayX, nextRayY, rayID, prevBounced, true )
			print("WTFFFF")
		end

		mTimerPrism = timer.performWithDelay( 3, nextOnDelay )

		isReflect = false
	end

	local function clearObject( event )
		display.remove( event ) ; event = nil
	end

	local hits = physics.rayCast( startX, startY, destX, destY, "sorted" ) 
	local reflectDestX, reflectDestY


	if ( hits and not (#hits == 1 and hits[1].object.type == "Goal") ) then

		-- Reflect rays.
		local hitFirst = hits[1] 

		if(hitFirst.object.type == "Goal") then
			
			for i = 1, #hits, 1 do
				print("ABSBDBDBDBDB " .. i .. " " .. hits[i].object.type)
				if(hits[i].object.type == "Goal") then 
					goalActiveGroup[hits[i].object.id].isVisible = true
				else hitFirst = hits[i]; break;
				end
			end
		end

		local hitX, hitY = hitFirst.position.x, hitFirst.position.y  --store hitX and hitY to local variables

		local burst = display.newImage( burstGroup, burstImg ) ; burst.x, burst.y = hitX, hitY ; burst.blendMode = "Multiply"
		transition.to( burst, { time = 1000, rotation = 45, alpha = 0, transition = easing.outQuad, onComplete = clearObject } )

		local reflectX, reflectY = physics.reflectRay( startX, startY, hitFirst )

		-- local beam1 = display.newLine( beamGroup, startX, startY, hitX, hitY )
		-- beam1.strokeWidth = 3 ; beam1:setStrokeColor(  beamColor.r, beamColor.g, beamColor.b, beamColor.a ) ; beam1.blendMode = blendMode

		if(hitFirst.object ~= nil) then

			local nextX, nextY

			if( hitFirst.object.type == "Solid" ) then isReflect = false; nextX = hitX; nextY = hitY;
			elseif( hitFirst.object.type == "Mirror" ) then 
				print("ISMIRROR")
				if(prevBounced == "PrismHorizontal") then endOfHorizontalPrism(); isReflect = false end
				
				if(#hits > 1) then
					print("NO. of hits : " .. #hits)

					if(prevBounced == "Prism") then 
						if(hits[2].object.type == "Glass" and (math.abs(startX - hitX) < 5 or math.abs(startY - hitY) < 5)) then
							print("PPPPPPPPP")
							isReflect = false
						end
					end
				end
				
				if(prevBounced == "Mirror" or prevBounced == "Glass") then 
					-- (Mirror tile) Prevent horisontal/vertical ray reflection due to side by side tile placement. 
					if(startY == destY or startX == destX) then print("AAA") ; return end

					-- (Mirror tile) Prevent repetitive bounces between 2 Mirror type place side by side.
					if(math.abs(startX - hitX) < 5 or math.abs(startY - hitY) < 5) then
						print("BBB") ;
						print(startX)
						print(hitX)

						print(startY)
						print(hitY)

						print(math.abs(startX - hitX))
						print(math.abs(startY - hitY))
						isReflect = false
					end
				end

				nextX = hitX; nextY = hitY;
				prevBounced = "Mirror"

			elseif( hitFirst.object.type == "Glass" ) then 

				if(prevBounced == "PrismHorizontal") then 
					endOfHorizontalPrism()
					prismDistortion()
				end

				if(prevBounced == "Glass" or prevBounced == "Mirror" ) then 
					-- (Glass tile) Prevent horisontal/vertical ray reflection due to side by side tile placement. 
					if(startY == destY or startX == destX) then print("AAA") ; return end

					-- (Glass tile) Prevent repetitive bounces between 2 glass type place side by side.
					if(math.abs(startX - hitX) < 5 or math.abs(startY - hitY) < 5) then
						print("BBB") ;
						-- print(math.abs(startX - hitX))
						-- print(math.abs(startY - hitY))
						isReflect = false
					end
				end
				

				if(#hits == 1) then nextX = destX; nextY = destY; prevBounced = "Glass"
				elseif(#hits > 1) then
					print("NO. of hits : " .. #hits)

					if(prevBounced == "Prism") then 
						if(hits[2].object.type == "Glass" and (math.abs(startX - hitX) < 5 or math.abs(startY - hitY) < 5)) then
							print("PPPPPPPPP")
							isReflect = false
						end
					end

					for i = 2, #hits, 1 do
						local hitSub = hits[i] 
						local hitSubX, hitSubY = hitSub.position.x, hitSub.position.y

						if(hitSub.object.type == "Goal") then 
							nextX = destX; nextY = destY; prevBounced = "Glass"
							goalActiveGroup[hitSub.object.id].isVisible = true

						elseif(hitSub.object.type ~= "Goal") then
							-- Stop val.
							if(hitSub.object.type == "Solid") then 
								nextX = hitSubX; nextY = hitSubY;
								-- isReflect = false
								break
							elseif(hitSub.object.type == "Prism") then 

								local dirX, dirY = getDir( { x = startX, y = startY }, { x = destX, y = destY } )

								-- Ray stops at the hit location.
								nextX = hitSubX - (dirX * 5); nextY = hitSubY - (dirY * 5);

								local function nextOnDelay()
									castRay( nextX, nextY, destX, destY, rayID, "Glass", true )
								end

								timer.performWithDelay( 1, nextOnDelay )
								break
							end
							
							-- Reflection val.
							local reflectSubX, reflectSubY = physics.reflectRay( startX, startY, hitSub )

							local reflectLen = _H
							local reflectSubDestX = ( hitSubX + ( reflectSubX * reflectLen ) )
							local reflectSubDestY = ( hitSubY + ( reflectSubY * reflectLen ) )

							local function nextOnDelay()
								castRay( hitSubX, hitSubY, reflectSubDestX, reflectSubDestY, rayID, "Glass", true )
							end

							timer.performWithDelay( 1, nextOnDelay )

							if(hitSub.object.type == "Mirror") then 
								-- Ray stops at the hit location.
								nextX = hitSubX; nextY = hitSubY;
								break

							elseif(hitSub.object.type == "Glass") then 
								-- Go thru glass val.
								nextX = destX; nextY = destY;


							end
						end
						

					end
				end

			elseif( hitFirst.object.type == "Prism" ) then 

				local function getHitPosOnTile()
					local tilePos = { x = hitFirst.object.x, y = hitFirst.object.y }
					-- print("tilePos.y " .. tilePos.y)
					-- print("hitY " .. hitY)

					local offset = 10
					if( tilePos.y >= (hitY - offset)  and tilePos.y <= (hitY + offset) ) then
						local valX = tilePos.x - hitX

						if(valX > 0) then print("Hit on the left")
						elseif(valX < 0) then print("Hit on the right")
						end

						return "Horizontal"

					elseif( tilePos.x >= (hitX - offset)  and tilePos.x <= (hitX + offset) ) then
						local valY = tilePos.y - hitY

						if(valY > 0) then print("Hit on the top")
						elseif(valY < 0) then print("Hit on the btm")
						end

						return "Vertical"
					end
				end
				
				local rayDir = getHitPosOnTile()
				local nextRayX, nextRayY
				
				local dirX, dirY = getDir( { x = startX, y = startY }, { x = destX, y = destY } )

				if(dirX ~= 0 and dirY ~= 0) then
					lasersTbl[rayID].dir.x = dirX
					lasersTbl[rayID].dir.y = dirY
				end

				if(rayDir == "Horizontal") then
					hitX = hitX + dirX
					nextRayX = hitX + ((blockGroup[1].contentWidth) * (dirX * 1.005)) 
					nextRayY = hitY

				elseif(rayDir == "Vertical") then
					hitY = hitY + dirY
					nextRayX = hitX
					nextRayY = hitY + ((blockGroup[1].contentHeight) * (dirY * 1.005)) 
				end

				local function nextOnDelay()
					-- print("CAST HORIZONTAL")
					-- print("fromX: " .. hitX)
					-- print("fromY: " .. hitY)
					-- print("toX: " .. nextRayX)
					-- print("toY: " .. nextRayY)
					castRay( hitX, hitY, nextRayX, nextRayY, rayID, "PrismHorizontal", false )
				end

				isReflect = false 
				nextX = hitX; nextY = hitY;

				mTimerPrism = timer.performWithDelay( 1, nextOnDelay )
				
			end

			-- print("1st draw")
			local beam1 = display.newLine( beamGroup, startX, startY, nextX, nextY )
			beam1.strokeWidth = 3 ; beam1:setStrokeColor(  beamColor.r, beamColor.g, beamColor.b, beamColor.a ) ; beam1.blendMode = blendMode
			
		end

		if(isReflect) then

			local reflectLen = _H
			reflectDestX = ( hitX + ( reflectX * reflectLen ) )
			reflectDestY = ( hitY + ( reflectY * reflectLen ) )

			if(startX ~= hitX or startY ~= hitY) then

			 	local function nextOnDelay()
					-- if(isGoalGenerated) then
					-- 	currBounceCount = currBounceCount + 1
					-- 	if(currBounceCount == maxBounceCount and isCorrectAnswer()) then
					-- 		reflectDestX = goalPos.x
					-- 		reflectDestY = goalPos.y

							-- print("\n\nspawnPos.x" .. spawnPosSave.x)
							-- print("spawnPos.y" .. spawnPosSave.y)
							-- print("goalPos.x" .. goalPos.x)
							-- print("goalPos.y" .. goalPos.y .. "\n\n")

					-- 	end
					-- end

					-- print("fromX: " .. hitX)
					-- print("fromY: " .. hitY)
					-- print("toX: " .. reflectDestX)
					-- print("toY: " .. reflectDestY)

					castRay( hitX, hitY, reflectDestX, reflectDestY, rayID, prevBounced, true )
				end

				mTimer = timer.performWithDelay( 1, nextOnDelay )
			end
		end

	else
		-- print("2nd draw")

		local beam1 = display.newLine( beamGroup, startX, startY, destX, destY )
		beam1.strokeWidth = 3 ; beam1:setStrokeColor(  beamColor.r, beamColor.g, beamColor.b, beamColor.a ) ; beam1.blendMode = blendMode
							
		if(hits and hits[1].object.type == "Goal") then goalActiveGroup[hits[1].object.id].isVisible = true end

		-- (Glass tile) Prevent horisontal/vertical ray reflection due to side by side tile placement. 
		if(isReflect) then
			if(startY == destY or startX == destX) then return end
		end

		-- Will only happen when conditions are true.
		prismDistortion()
	end
	print("\nENDED RAY")

							-- 	print("\n\nspawnPos.x" .. spawnPosSave.x)
							-- print("spawnPos.y" .. spawnPosSave.y)
	-- if(showWinTimer == false) then
	-- 	if(isGoalGenerated and isCorrectAnswer()) then
	-- 		local options =
	-- 	    {
	-- 	        effect = sceneEffect,
	-- 	        time = nextSceneTime,
	-- 	        isModal = true,
	-- 	        params =
	-- 	        {
	-- 	        	name = "Win",
	-- 	        	id = 1,
	-- 	        	level = stageProperties.mlevel
	-- 	    	}
	-- 	    }

	-- 	    local function nextOnDelay()
	-- 	    	storyboard.showOverlay( nextScene, options )
	-- 	    end

	-- 	    timer.performWithDelay( 200, nextOnDelay )
	-- 	    showWinTimer = true
	-- 	end
	-- end

	if(isGoalGenerated == false and isReflect) then genGoal( startX, startY, destX, destY, hits, reflectDestX, reflectDestY) end

end

-- Generate the laser position.
local function genLaserPos()

	-- Get laser point direction.
	local function laserDir(dir)
		if(dir == "TopLeft") then return -1, -1
		elseif(dir == "TopRight") then return 1, -1
		elseif(dir == "BtmLeft") then return -1, 1
		elseif(dir == "BtmRight") then return 1, 1
		end
	end

	-- Get random tile to spawn the laser.
	local indexNo = math.random( 1, bgTileGroup.numChildren )
	local tile = bgTileGroup[indexNo]
	print("\nLaser spawn index no : " .. indexNo)

	-- Get any 4 directions around the selected tile to spawn laser.
	local rand = math.random( 1, 4 )
	local spawnPos = { x = tile.x, y = tile.y }

	if(rand == 1) then spawnPos.x = tile.x + tile.contentWidth / 2 + tileSpacing / 2  -- Spawn right
	elseif(rand == 2) then spawnPos.x = tile.x - tile.contentWidth / 2 - tileSpacing / 2 -- Spawn left
	elseif(rand == 3) then spawnPos.y = tile.y + tile.contentHeight / 2 + tileSpacing / 2-- Spawn top
	elseif(rand == 4) then spawnPos.y = tile.y - tile.contentHeight / 2 - tileSpacing / 2-- Spawn bottom
	end 

	local laser = display.newImage( laserGenGroup, laserGenImg, spawnPos.x, spawnPos.y )
	laser.xScale = 0.2; laser.yScale = 0.2;
	
	local dirX, dirY

	if(indexNo < col + 1) then

		-- Top Left to Right
		if(indexNo == 1) then dirX, dirY = laserDir("BtmRight")
		elseif(indexNo > 1 and indexNo < col) then
			local rand = math.random( 1, 2 )
			
			if(rand == 1) then dirX, dirY = laserDir("BtmRight")
			elseif(rand == 2) then dirX, dirY = laserDir("BtmLeft")
			end
		elseif(indexNo == col) then dirX, dirY = laserDir("BtmLeft")
		end

	elseif(indexNo < col * (row - 1) + 1) then
		
		local isEdge = false

		for i = 1, row - 2 do
			if(indexNo == (i * col) + 1) then -- Left edge topdown
				rand = math.random( 1, 2 )
			
				if(rand == 1) then dirX, dirY = laserDir("TopRight"); isEdge = true;
				elseif(rand == 2) then dirX, dirY = laserDir("BtmRight") isEdge = true;
				end
				
			elseif(indexNo == (i * col) + col) then -- Right edge topdown
				rand = math.random( 1, 2 )

				if(rand == 1) then dirX, dirY = laserDir("TopLeft") isEdge = true;
				elseif(rand == 2) then dirX, dirY = laserDir("BtmLeft") isEdge = true;
				end
			end
		end

		if(isEdge == false) then
			rand = math.random( 1, 4 )

			if(rand == 1) then dirX, dirY = laserDir("TopLeft") 
			elseif(rand == 2) then dirX, dirY = laserDir("TopRight") 
			elseif(rand == 3) then dirX, dirY = laserDir("BtmLeft") 
			elseif(rand == 4) then dirX, dirY = laserDir("BtmRight") 
			end 
		end
		
	elseif(indexNo < col * row + 1) then

		-- Btm Left to Right
		local btmLeftIndex = col * (row - 1) + 1
		local btmRightIndex = row * col

		if(indexNo == btmLeftIndex) then dirX, dirY = laserDir("TopRight")
		elseif(indexNo > btmLeftIndex and indexNo < btmRightIndex) then 
			rand = math.random( 1, 2 )
			
			if(rand == 1) then dirX, dirY = laserDir("TopRight")
			elseif(rand == 2) then dirX, dirY = laserDir("TopLeft")
			end

		elseif(indexNo == btmRightIndex) then dirX, dirY = laserDir("TopLeft")
		end
	end
	
	currLaser = currLaser + 1
	laserGenGroup[currLaser].x = spawnPos.x
	laserGenGroup[currLaser].y = spawnPos.y
	laserGenGroup[currLaser].dirX = dirX
	laserGenGroup[currLaser].dirY = dirY

	local laserIndex = #lasersTbl + 1
	lasersTbl[laserIndex] = 
	{
		tileID = indexNo,
		dir = { x = dirX, y = dirY },
		oriDir = { x = dirX, y = dirY }
	}

	local dest = { x = spawnPos.x + (dirX * (_W + tileSpacing + testray)), y = spawnPos.y + (dirY * (_W + tileSpacing + testray)) }
	castRay(spawnPos.x, spawnPos.y, dest.x , dest.y, currLaser, "Goal", true)

	spawnPosSave.x = spawnPos.x
	spawnPosSave.y = spawnPos.y
	
end

local function setMargin()
	if(row == 3 and col == 3) then marginX = 90; marginY = 170; 
	elseif(row == 4 and col == 3) then marginX = 90; marginY = 140; 
	elseif(row == 4 and col == 4) then marginX = 55; marginY = 140; 
	elseif(row == 5 and col == 3) then marginX = 90; marginY = 100; 
	elseif(row == 5 and col == 4) then marginX = 55; marginY = 100; 
	end
end

local function createPreDefinedPuzzle( title, bgIDTbl, blockIDTbl, lockTbl, blockTypeTbl, rayProperties, goalProperties, screenGroup )

	if(title ~= nil) then
		if(stageTitle == nil) then
			stageTitle = display.newText( title, X_Center, 5, native.systemFontBold, 24 )
			stageTitle.anchorY = 0
		else stageTitle.text = title
		end
	end

	setMargin()
	genBgTile()

	-- Delete unused tiles.
	local deleteBgTbl = {}
	for i = 1, bgTileGroup.numChildren, 1 do
		if(hasValWithinTbl(i, bgIDTbl) == false) then table.insert(deleteBgTbl, i) end
	end

	for i = 1, #deleteBgTbl, 1 do
		local tileID = deleteBgTbl[i]

		for j = 1, bgTileGroup.numChildren, 1 do
			if(bgTileGroup[j].id == tileID) then 
				bgTileGroup[j]:removeSelf() 
				-- print("Deleted"..tileID)
				break
			end
		end
	end

	-- Generate blocks.
	for i = 1, #blockIDTbl, 1 do
		local blockType = blockTypeTbl[i]
		local blockID = blockIDTbl[i]

		if(blockType == nil) then genBlock( blockID )
		else 
			if(lockTbl ~= nil and hasValWithinTbl( blockID, lockTbl )) then
				genBlock( blockID, blockType, true ); 
				print("Block id : " .. blockID)
				print("Block type : " .. blockTypeTbl[i] .. " (Locked)")
			else 
				genBlock( blockID, blockType ); 
				print("Block id : " .. blockID)
				print("Block type : " .. blockTypeTbl[i])
			end
		end
	end

	-- Generate goal.
	if(#goalProperties == 0) then
		local goal = display.newImage( goalGroup, goalImg, goalProperties.x , goalProperties.y )
		goal.xScale = goalScale; goal.yScale = goalScale;
		goal.id = 1
		goal.type = "Goal"

		local goalAct = display.newImage( goalActiveGroup, goalActiveImg, goalProperties.x , goalProperties.y )
		goalAct.xScale = goalScale; goalAct.yScale = goalScale;
		goalAct.isVisible = false

		local avrRad = goal.contentWidth + goal.contentHeight
		avrRad = avrRad / 4

		physics.addBody( goal, "static", { radius = avrRad } )
	else
		for i = 1, #goalProperties, 1 do
			local goal = display.newImage( goalGroup, goalImg, goalProperties[i].x , goalProperties[i].y )
			goal.xScale = goalScale; goal.yScale = goalScale;
			goal.id = i
			goal.type = "Goal"

			local goalAct = display.newImage( goalActiveGroup, goalActiveImg, goalProperties[i].x , goalProperties[i].y )
			goalAct.xScale = goalScale; goalAct.yScale = goalScale;
			goalAct.isVisible = false

			local avrRad = goal.contentWidth + goal.contentHeight
			avrRad = avrRad / 4

			physics.addBody( goal, "static", { radius = avrRad } )
		end
	end

	
	isGoalGenerated = true


	-- Generate laser.
	local function CreateLaser( posX, posY, dirX, dirY )
		local laser = display.newImage( laserGenGroup, laserGenImg, posX, posY )
		laser.xScale = 0.2; laser.yScale = 0.2;

		currLaser = currLaser + 1
		laserGenGroup[currLaser].x = posX
		laserGenGroup[currLaser].y = posY
		laserGenGroup[currLaser].dirX = dirX
		laserGenGroup[currLaser].dirY = dirY

		local laserIndex = #lasersTbl + 1
		lasersTbl[laserIndex] = 
		{
			tileID = indexNo,
			dir = { x = dirX, y = dirY },
			oriDir = { x = dirX, y = dirY }
		}

		local dest = { x = posX + (dirX * (_W + tileSpacing + testray)), y = posY + (dirY * (_W + tileSpacing + testray)) }
		castRay(posX, posY, dest.x , dest.y, currLaser, "Goal", true)
	end

	local newRay
	local isSingleRay = true

	if( type(rayProperties[1]) == "table" ) then isSingleRay = false
	end

	if(isSingleRay) then

		local function delay()
			CreateLaser( rayProperties.pos.x, rayProperties.pos.y, rayProperties.dir.x, rayProperties.dir.y )
		end
   		timer.performWithDelay( 1, delay, 1 )
	else
		for i = 1, #rayProperties, 1 do
			local x = rayProperties[i].pos.x
			local y = rayProperties[i].pos.y
			local dirX = rayProperties[i].dir.x
			local dirY = rayProperties[i].dir.y

			CreateLaser( x, y, dirX, dirY )

			local function delay()
   				CreateLaser( x, y, dirX, dirY )
   			end
   			timer.performWithDelay( 1, delay, 1 )

		end
	end
	

	if(screenGroup ~= nil) then
		-- screenGroup:insert(stageTitle)
		screenGroup:insert(bgTileGroup)
		screenGroup:insert(blockGroup)
		screenGroup:insert(goalGroup)
		screenGroup:insert(goalActiveGroup)
		screenGroup:insert(laserGenGroup)
		screenGroup:insert(beamGroup)
	end
end

-- Re-cast the rays after hitting blocks.
function refreshRay()
	clearRayGroup()
	clearTbl(blockPlacemenIDTbl)
	
	for i = 1, goalActiveGroup.numChildren, 1 do
		goalActiveGroup[i].isVisible = false
	end

	currBounceCount = 0
	for i = 1, laserGenGroup.numChildren do
		local laser = laserGenGroup[i]
		local dest = { x = laser.x + (laser.dirX * (_W + tileSpacing + testray)), y = laser.y + (laser.dirY * (_W + tileSpacing + testray)) }

		lasersTbl[i].dir.x = lasersTbl[i].oriDir.x
		lasersTbl[i].dir.y = lasersTbl[i].oriDir.y

		castRay(laser.x, laser.y, dest.x, dest.y, i, "Goal", true)
	end
end

function resetCurrentRay(isFullReset)
	resetToDefault()

	if(mTimer ~= nil) then timer.cancel( mTimer ) end
	if(mTimerPrism ~= nil) then timer.cancel( mTimerPrism ) end

	if(isFullReset == false) then
		local laser = laserGenGroup[currLaser]
		local dest = { x = laser.x + (laser.dirX * (_W + tileSpacing + testray)), y = laser.y + (laser.dirY * (_W + tileSpacing + testray)) }

		local function reCast( ... )
			castRay(laser.x, laser.y, dest.x , dest.y, currLaser, "Goal", true)
		end
		
		timer.performWithDelay( 2, reCast )

	elseif(isFullReset) then
		laserGenGroup[currLaser]:removeSelf()
		currLaser = currLaser - 1
		resetCount = 0
		clearTbl(lasersTbl)
		print("FULL RESET")

		local function reCast( ... )
			genLaserPos()
			-- genLaserPos()
		end

		timer.performWithDelay( 2, reCast )
	end
	
end

function restartLevel()
	local tileTbl = stageProperties.mtileTbl
	local blockTbl = stageProperties.mblockTbl
	local lockTbl = stageProperties.mlockTbl
	local blockTypeTbl = stageProperties.mblockTypeTbl
	local rayProperties = stageProperties.mrayProperties
	local goalProperties = stageProperties.mgoalProperties

	row = stageProperties.mstageProperties.row
	col = stageProperties.mstageProperties.col
	answerIDTbl = stageProperties.mAnswerTbl
	emptyIDTbl = stageProperties.memptyTileTbl

   	scrollView:toFront()

   	local function delay()
   		createPreDefinedPuzzle(nil, tileTbl, blockTbl, lockTbl, blockTypeTbl, rayProperties, goalProperties, screenGroup)
		screenGroup:toFront()
   	end
   	timer.performWithDelay( 1, delay, 1 )
	
end

function goToNextLevel(level)

 	reinitializeDefault()
 	-- removeSelf(stageTitle)

	local options = loadLevel(nil, level)
	stageProperties = options.params

	local title = "Level " .. level
	local tileTbl = stageProperties.mtileTbl
	local tileTbl = stageProperties.mtileTbl
	local blockTbl = stageProperties.mblockTbl
	local lockTbl = stageProperties.mlockTbl
	local blockTypeTbl = stageProperties.mblockTypeTbl
	local rayProperties = stageProperties.mrayProperties
	local goalProperties = stageProperties.mgoalProperties

	row = stageProperties.mstageProperties.row
	col = stageProperties.mstageProperties.col
	answerIDTbl = stageProperties.mAnswerTbl
	emptyIDTbl = stageProperties.memptyTileTbl

	createPreDefinedPuzzle(title, tileTbl, blockTbl, lockTbl, blockTypeTbl, rayProperties, goalProperties, screenGroup)
	menuGroup:toFront()
	pauseGroup:toFront()
end

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

function scene:createScene( event )
	print( "\nMain Game: createScene event" )

	screenGroup = self.view

	local gameBg = display.newImage("Images/game/background.png", X_Center, Y_Center); gameBg:toBack();
	screenGroup:insert( gameBg ) 
end

function scene:willEnterScene( event )
	print( "\nMain Game: willEnterScene event" )

	-- storyboard.purgeScene( "scene5" )

	local function genBtn( default, over, w, h, x, y, id, name)
	    local button = widget.newButton
	    {
	    	font = "Arial",
	        emboss = true,
	        width = w,
	        height = h,
	        defaultFile = default,
	        overFile = over,
	        onEvent = handleButtonEvent
	    }
	    button.anchorX = 0.5; button.anchorY = 0.5;
	    button.x = x; button.y = y;
	    button.name = name

	    -- Add buttons to each respective's group.
	    if(id == 1) then
	    	menuGroup:insert( button )
	    elseif(id == 2) then
	    	pauseGroup:insert( button )

	    	if(name == "soundBtnOn") then
	    		soundOnGroup:insert ( button )
	    	elseif(name == "soundBtnOff") then
	    		soundOffGroup:insert ( button )
	    	end
	    end

	    return button
	end

	if(event.params ~= nil) then stageProperties = event.params end

	local screenGroup = self.view
	local bgOverlayString

	if(stageProperties ~= nil) then
		if(stageProperties.mworld == 1) then bgOverlayString = mirrorBg
		elseif(stageProperties.mworld == 2) then bgOverlayString = glassBg
		elseif(stageProperties.mworld == 3) then bgOverlayString = solidBg
		elseif(stageProperties.mworld == 4) then bgOverlayString = prismBg
		elseif(stageProperties.mworld == 5) then bgOverlayString = twistedBg
		end

		if(stageProperties.isRandomizeStage) then
			if(stageProperties.bgID == 1) then bgOverlayString = mirrorBg
			elseif(stageProperties.bgID == 2) then bgOverlayString = glassBg
			elseif(stageProperties.bgID == 3) then bgOverlayString = twistedBg
			elseif(stageProperties.bgID == 4) then bgOverlayString = hardBg
			end
		end
	end

	local gameBgOverlay = display.newImage(bgOverlayString, X_Center, Y_Center);
	gameBgOverlay.xScale = 0.22; gameBgOverlay.yScale = 0.24

	local boundary = display.newImage("Images/game/boundry.png", X_Center, Y_Center);
	boundary.xScale = 0.22; boundary.yScale = 0.24;

	local levelImg = display.newImage("Images/game/title_bar.png", X_Center, 0)
	levelImg.anchorY = 0
	levelImg.xScale = 0.25; levelImg.yScale = 0.25;
	
	screenGroup:insert( gameBgOverlay ) 

    -------------------- Puzzle generation --------------------

	if(event.params ~= nil and event.params.isRandomizeStage == nil) then
		
		-- Create predefined puzzle.
		-- stageProperties = event.params
		
		local level = "Level " .. stageProperties.mlevel
		local tileTbl = stageProperties.mtileTbl
		local blockTbl = stageProperties.mblockTbl
		local lockTbl = stageProperties.mlockTbl
		local blockTypeTbl = stageProperties.mblockTypeTbl
		local rayProperties = stageProperties.mrayProperties
		local goalProperties = stageProperties.mgoalProperties

		row = stageProperties.mstageProperties.row
		col = stageProperties.mstageProperties.col
		answerIDTbl = stageProperties.mAnswerTbl
		emptyIDTbl = stageProperties.memptyTileTbl

		createPreDefinedPuzzle(level, tileTbl, blockTbl, lockTbl, blockTypeTbl, rayProperties, goalProperties, screenGroup)
	elseif(event.params ~= nil and event.params.isRandomizeStage) then
		
		stageTitle = display.newText( maxStageTime, X_Center, 5, native.systemFontBold, 24 )
		stageTitle.anchorY = 0

		-- Create random puzzle.

		math.randomseed(os.time())
		setMargin()
		genBgTile()
		genLaserPos()

		screenGroup:insert(bgTileGroup)
		screenGroup:insert(blockGroup)
		screenGroup:insert(laserGenGroup)
		screenGroup:insert(goalGroup)
		screenGroup:insert(goalActiveGroup)
		screenGroup:insert(beamGroup)
	end
	-------------------------------------------------------------

    menuGroup:insert( boundary ) 
	menuGroup:insert( levelImg )
	menuGroup:insert(stageTitle)
	
    -- Create the widget
    scrollView = widget.newScrollView
    {
        top = 1,
        left = 1,
        width = _W,
        height = _H,
        scrollWidth = 600,
        scrollHeight = 800,
        hideBackground = true,
    }
    scrollView._view._isHorizontalScrollingDisabled = true
    scrollView._view._isVerticalScrollingDisabled = true
    scrollView.currPage = 1

    ------- Menu section -------
    local hintBorder = display.newImage( menuGroup, "Images/game/hint.png", _W * 0.2, _H * 0.94); 
    hintBorder.xScale = 0.2; hintBorder.yScale = 0.2;

    if(dataTable.hints ~= -1) then totalHints = dataTable.hints end 

    options1 = 
    {
        parent = menuGroup,
        text = "Hint",     
        x = hintBorder.x,
        y = hintBorder.y - 13,
        width = 50,     
        font = native.systemFont,   
        fontSize = 12,
        align = "center" 
    }
    
    options2 = 
    {
        parent = menuGroup,
        text = totalHints,     
        x = hintBorder.x,
        y = hintBorder.y + 6,
        width = 50,     
        font = native.systemFont,   
        fontSize = 32,
        align = "center" 
    }

    local myText = display.newText( options1 )
    myText:setFillColor( 0, 0, 0 )

    hintText = display.newText( options2 )
    hintText:setFillColor( 0, 0, 0 )

    genBtn( "Images/game/hint_on_botton.png", "Images/game/hint_off_botton.png", 50, 45, _W * 0.38, _H * 0.94, 1, "hintBtn" )
    genBtn( "Images/game/moret_on_botton.png", "Images/game/moret_off_botton.png", 50, 45, _W * 0.54, _H * 0.94, 1, "moreBtn" )
    genBtn( "Images/game/menu_on_botton.png", "Images/game/menu_off_botton.png", 80, 45, _W * 0.75, _H * 0.94, 1,  "menuBtn" )

	screenGroup:insert(menuGroup)
    -----------------------------

    ---- Pause Menu section ----
    local xScrollWidth = scrollView.contentWidth
    local xScrollCenter = scrollView.contentWidth/2

    local tempBg = display.newImage("Images/Pause menu/background.png", 0, 0); 
    tempBg.anchorX = 0; tempBg.anchorY = 0;
    tempBg.alpha = 0

    local pauseBg = display.newImage("Images/Pause menu/background.png", xScrollCenter, 0)
    pauseBg.anchorY = 1
    local pauseImg = display.newImage("Images/Pause menu/pause_icon.png", xScrollCenter,  -_H + (_H * 0.4)); 
    pauseImg.xScale = 0.25; pauseImg.yScale = 0.25;

    genBtn( "Images/Pause menu/level_on_botton.png", "Images/Pause menu/level_off_botton.png", 50, 50, xScrollWidth * 0.2, -_H + (_H * 0.6), 2, "levelSelectBtn" )
    genBtn( "Images/Pause menu/sound_active_on_botton.png", "Images/Pause menu/sound_active_off_botton.png", 50, 50, xScrollWidth * 0.4, -_H + (_H * 0.6), 2, "soundBtnOn" )
    genBtn( "Images/Pause menu/sound_in-active_on_botton.png", "Images/Pause menu/sound_in-active_off_botton.png", 50, 50, xScrollWidth * 0.4, -_H + (_H * 0.6), 2, "soundBtnOff" )
    genBtn( "Images/Pause menu/reset_on_botton.png", "Images/Pause menu/reset_off_botton.png", 50, 50, xScrollWidth * 0.6, -_H + (_H * 0.6), 2, "restartBtn" )
    genBtn( "Images/Pause menu/next_on_botton.png", "Images/Pause menu/next_off_botton.png", 50, 50, xScrollWidth * 0.8, -_H + (_H * 0.6), 2, "nextBtn" )
    genBtn( "Images/Pause menu/resume_on_botton.png", "Images/Pause menu/resume_off_botton.png", 100, 50, xScrollWidth * 0.5, -_H + (_H * 0.73), 2, "resumeBtn" )
    
    soundOffGroup.isVisible = false
 --    -----------------------------

    scrollView:insert( tempBg )
    scrollView:insert( pauseBg )
    scrollView:insert( pauseImg )
    scrollView:insert( pauseGroup )
    scrollView:insert( soundOnGroup )
    scrollView:insert( soundOffGroup )

    scrollView:toBack()

    if(stageProperties.mlevel == 1) then
    	local options =
	    {
	        effect = sceneEffect,
	        time = nextSceneTime,
	        isModal = true,
	        params =
	        {
	        	name = "Tutorial",
	        	id = stageProperties.mworld,
	        	level = stageProperties.mlevel
	    	}
	    }

	    local function nextOnDelay()
	    	storyboard.showOverlay( nextScene, options )
	    end

	    timer.performWithDelay( 1000, nextOnDelay )
    end
    
end

function scene:exitScene()
	print( "Main Game: exitScene event" )
	scrollView:removeSelf()
	reinitializeDefault(true)
end

function scene:destroyScene( event )
	print( "((destroying scene Main Game's view))" )
end

---------------------------------------------------------------------------------
-- END OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

scene:addEventListener( "createScene", scene )
scene:addEventListener( "willEnterScene", scene )
-- scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

-----------------------------------------------------------------------------------

return scene