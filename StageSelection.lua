---------------------------------------------------------------------------------
--
-- StageSelection.lua
--
---------------------------------------------------------------------------------

-- dataTable = { hints = -1, world = {} }

-- for i = 1, 5, 1 do
--     dataTable.world[i] = 
--     { 
--         isLocked = nil
--         lockPointID = -1,
--         getStage5Hint = true,
--         getStage10Hint = true
--     }
-- end

local loadsave = require("loadsave")

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local mirrorTbl = { }
local glassTbl = { }
local prismTbl = { }
local solidTbl = { }
local twistedTbl = { }

local btnGroup = display.newGroup()
local lockGroup = display.newGroup()

local stageTitle = nil
local worldID = 0
local rowID = 0

-- Tweakable settings.
local prevScene = "WorldSelection"
local nextScene = "MainGame"
local sceneEffect = "fade"
local nextSceneTime = 500


local function saveLockStages()

    local startLock = 11

    local function saveToTbl( tbl )

        for i = 1, btnGroup.numChildren, 1 do
            tbl[i] = {}
            tbl[i].id = btnGroup[i].id
            tbl[i].isLocked = btnGroup[i].isLocked

            if(tbl[i].isLocked) then startLock = tbl[i].id end
            -- print(tbl[i].id)
        end
        
        return startLock
    end

    if(worldID == 1) then mirrorTbl = {}; saveToTbl(mirrorTbl)
    elseif(worldID == 2) then glassTbl = {}; saveToTbl(glassTbl)
    elseif(worldID == 3) then solidTbl = {}; saveToTbl(solidTbl)
    elseif(worldID == 4) then prismTbl = {}; saveToTbl(prismTbl)
    elseif(worldID == 5) then twistedTbl = {}; saveToTbl(twistedTbl)
    end
    
    dataTable.world[worldID].lockPointID = startLock 
    loadsave.saveTable(dataTable, "dataTable.json")

    print("\n\n----DATA SAVED!----\n\n")
end

function unlockStage( stageID )

    if(stageID > 10) then 
        local nextWorld = worldID + 1

        if(nextWorld < 6) then unlockWorld(nextWorld) end
        
        return 
    end
    if(btnGroup[stageID].isLocked == false) then return end
    
    btnGroup[stageID].isLocked = false
    for i = 1, lockGroup.numChildren, 1 do
        if(lockGroup[i].id == stageID) then lockGroup[i]:removeSelf(); break end
    end

    saveLockStages()
end

function loadLevel( world, level )

    if(world == nil) then world = worldID end

    local tileTbl, blockTbl, rayProperties, goalProperties, stageProperties, lockTbl
    local blockTypeTbl = {}
    local answerTbl = {}
    local emptyTileTbl = {}

    local function sameTileType( type, count )
        for i = 1, count, 1 do
            table.insert(blockTypeTbl, type) 
        end
    end

    if(world == 1) then
        --------------------------------------- MIRROR WORLD ---------------------------------------

        if(level == 1) then 

            tileTbl = {3,4,6,7}
            blockTbl = {7}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 125.5, y = 240 },  dir =  { x = 1, y = -1 } }
            goalProperties = { x = 162, y = 134 }
            stageProperties = { row = 3, col = 3 }
            answerTbl = {3}

        elseif(level == 2) then
           
            tileTbl = {1,3,4,5}
            blockTbl = {4,5}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 161, y = 275 },  dir =  { x = -1, y = -1 } }
            goalProperties = { x = 162, y = 132.5 }
            stageProperties = { row = 3, col = 3 }
            answerTbl = {3,4}

        elseif(level == 3) then 
           
            tileTbl = {1,3,5,6,7,8,9}
            blockTbl = {3,5,6}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 125.5, y = 170 },  dir =  { x = 1, y = 1 } }
            goalProperties = { x = 57, y = 239 }
            stageProperties = { row = 3, col = 3 }
            answerTbl = {1,6,8}

        elseif(level == 4) then 

            tileTbl = {1,2,3,4,6,8,9}
            blockTbl = {1,2,6,9}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 125.5, y = 170 },  dir =  { x = 1, y = 1 } }
            goalProperties = { x = 162, y = 131 }
            stageProperties = { row = 3, col = 3 }
            answerTbl = {3,4,6,8}

        elseif(level == 5) then 

            tileTbl = {1,2,3,5,7,8,9,10}
            blockTbl = {3,5,9}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 267.5, y = 210 },  dir =  { x = -1, y = -1 } }
            goalProperties = { x = 55, y = 209 }
            stageProperties = { row = 4, col = 3 }
            answerTbl = {1,3,8}

        elseif(level == 6) then 

            tileTbl = {1,2,3,4,6,7,8,9,10,12}
            blockTbl = {1,6,10,12}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 232, y = 175 },  dir =  { x = -1, y = 1 } }
            goalProperties = { x = 265.5, y = 211 }
            stageProperties = { row = 4, col = 3 }
            answerTbl = {2,4,8,9}

        elseif(level == 7) then 

            tileTbl = {1,2,3,4,5,6,7,9,10,11,14,16}
            blockTbl = {1,5,7,16}
            lockTbl = {5}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 90.5, y = 280 },  dir =  { x = 1, y = -1 } }
            goalProperties = { x = 21, y = 279 }
            stageProperties = { row = 4, col = 4 }
            answerTbl = {6,11,14}

        elseif(level == 8) then 

            tileTbl = {1,2,3,4,5,6,8,10,12,13,14,15}
            blockTbl = {1,3,6,8,10,13}
            lockTbl = {3,13}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 268, y = 385 },  dir =  { x = -1, y = -1 } }
            goalProperties = { x = 196, y = 391.5 }
            stageProperties = { row = 4, col = 4 }
            answerTbl = {2,5,12,14}

        elseif(level == 9) then 

            tileTbl = {1,2,3,4,5,6,8,9,10,13,14,15,16,17,18,19}
            blockTbl = {5,8,9,10,13,15,16,17}
            lockTbl = {9,10}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 197, y = 205 },  dir =  { x = -1, y = -1 } }
            goalProperties = { x = 23.5, y = 308 }
            stageProperties = { row = 5, col = 4 }
            answerTbl = {3,6,8,16,17,19}

        elseif(level == 10) then 

            tileTbl = {1,2,3,4,5,6,8,9,10,11,13,14,16,17,18,19}
            blockTbl = {4,5,9,13,16,19}
            lockTbl = {5,13}
            sameTileType( "Mirror", #blockTbl )
            rayProperties = { pos =  { x = 305, y = 170 },  dir =  { x = -1, y = -1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 90, y = 311 }
            goalProperties[2] = { x = 90, y = 170 }
            goalProperties[3] = { x = 230, y = 311 }
            goalProperties[4] = { x = 230, y = 170 }

            stageProperties = { row = 5, col = 4 }
            local tempAnswerTbl = {2,4,11,18}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Mirror" }
                table.insert(answerTbl, tempTbl)
            end
            
        end

    elseif(world == 2) then
        --------------------------------------- GLASS WORLD ---------------------------------------

        if(level == 1) then 

            tileTbl = {2,3,4,5,6,8,9}
            blockTbl = {2,4,6}
            blockTypeTbl = { "Mirror", "Mirror", "Glass"}
            lockTbl = {4}
            emptyTileTbl = {2}
            rayProperties = { pos =  { x = 270, y = 310 },  dir =  { x = -1, y = -1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 90, y = 134.5 }
            goalProperties[2] = { x = 230, y = 205 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {5}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Glass" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 2) then
           
            tileTbl = {1,2,5,6,7,8,9,10,11,12,13,15}
            blockTbl = {10,11,12}
            blockTypeTbl = { "Glass", "Glass", "Glass" }
            -- lockTbl = {4}
            rayProperties = { pos =  { x = 55, y = 385 },  dir =  { x = 1, y = -1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 90, y = 205 }
            goalProperties[2] = { x = 195, y = 104 }
            goalProperties[3] = { x = 230, y = 208 }
            goalProperties[4] = { x = 300, y = 351 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {5,7,11}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Glass" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 3) then 
           
            tileTbl = {2,3,4,5,7,8,9,10,11,12,15}
            blockTbl = {7,8,9,10,4}
            blockTypeTbl = { "Glass", "Mirror", "Mirror", "Glass", "Glass" }
            -- lockTbl = {4}
            rayProperties = { pos =  { x = 126, y = 175 },  dir =  { x = 1, y = 1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 127, y = 104 }
            goalProperties[2] = { x = 195, y = 384 }
            goalProperties[3] = { x = 230, y = 208 }
            goalProperties[4] = { x = 300, y = 351 }
            goalProperties[5] = { x = 22, y = 138 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {7,8,9,10,11}
            local tempType = { "Glass", "Mirror", "Mirror", "Glass", "Glass" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 4) then 

            tileTbl = {1,2,3,4,5,7,8,9,11,12,14,15,16}
            blockTbl = {1,2,5,8,11}
            blockTypeTbl = { "Glass", "Mirror", "Glass", "Mirror", "Glass" }
            -- lockTbl = {4}
            rayProperties = { pos =  { x = 90.5, y = 210 },  dir =  { x = 1, y = -1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 124, y = 314 }
            goalProperties[2] = { x = 230, y = 208 }
            goalProperties[3] = { x = 196, y = 104 }
            goalProperties[4] = { x = 124, y = 390 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {2,7,9,12,14}
            local tempType = { "Glass", "Glass", "Mirror", "Mirror", "Glass" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 5) then 

            tileTbl = {1,2,3,4,5,6,7,9,11,12,14,15,16}
            blockTbl = {5,6,9,12,16}
            blockTypeTbl = { "Mirror", "Mirror", "Glass", "Mirror", "Mirror" }
            lockTbl = {16}
            rayProperties = { pos =  { x = 55, y = 315 },  dir =  { x = 1, y = -1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 300, y = 211 }
            goalProperties[2] = { x = 196, y = 390 }
            goalProperties[3] = { x = 196, y = 243 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {3,6,12,15}
            local tempType = { "Mirror", "Mirror", "Mirror", "Glass" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 6) then 

            tileTbl = {1,2,3,4,5,8,10,11,12,13,14}
            blockTbl = {1,2,3,8,13}
            blockTypeTbl = { "Glass", "Mirror", "Glass", "Mirror", "Mirror" }
            lockTbl = {2}
            rayProperties = { pos =  { x = 232.5, y = 140 },  dir =  { x = -1, y = 1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 196, y = 101 }
            goalProperties[2] = { x = 300, y = 140 }
            goalProperties[3] = { x = 22, y = 350 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {5,8,10,11}
            local tempType = { "Mirror", "Glass", "Glass", "Mirror" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 7) then 

            tileTbl = {2,3,4,5,6,7,9,10,11,12,13,14}
            blockTbl = {5,6,7,11}
            blockTypeTbl = { "Mirror", "Mirror", "Mirror", "Glass" }
            -- lockTbl = {13,20}
            rayProperties = { pos =  { x = 161, y = 205 },  dir =  { x = -1, y = -1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 128.5, y = 171 }
            goalProperties[2] = { x = 264, y = 235 }
            goalProperties[3] = { x = 55, y = 238 }

            stageProperties = { row = 5, col = 3 }
            
            local tempAnswerTbl = {2,4,6,10}
            local tempType = { "Mirror", "Mirror", "Glass", "Mirror" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 8) then 

            tileTbl = {1,4,5,6,7,10,11,12,16,17,18,19}
            blockTbl = {4,6,11,12,19}
            blockTypeTbl = { "Glass", "Mirror", "Glass", "Glass", "Glass" }
            lockTbl = {6,11}
            rayProperties = { pos =  { x = 268, y = 345 },  dir =  { x = -1, y = -1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 22, y = 240 }
            goalProperties[2] = { x = 198, y = 414 }
            goalProperties[3] = { x = 305, y = 97 }

            stageProperties = { row = 5, col = 4 }
            
            local tempAnswerTbl = {10,16,18}
            local tempType = { "Glass", "Glass", "Glass" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 9) then 

            tileTbl = {3,4,6,7,8,9,10,12,13,14,16,17,18,19,20}
            blockTbl = {4,7,9,13,14,20}
            blockTypeTbl = { "Mirror", "Mirror", "Mirror", "Glass", "Mirror", "Mirror" }
            lockTbl = {13,20}
            rayProperties = { pos =  { x = 197, y = 415 },  dir =  { x = 1, y = -1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 163, y = 241 }
            goalProperties[2] = { x = 300, y = 305 }
            goalProperties[3] = { x = 22, y = 382 }

            stageProperties = { row = 5, col = 4 }
            
            local tempAnswerTbl = {7,10,12,18}
            local tempType = { "Mirror", "Mirror", "Mirror", "Mirror" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 10) then 

            tileTbl = {1,2,3,4,7,8,9,10,12,14,15,16,17,18,19,20}
            blockTbl = {1,8,9,10,12,14,16,18,20}
            blockTypeTbl = { "Glass", "Mirror", "Mirror", "Mirror", "Glass", "Mirror", "Mirror", "Glass", "Glass" }
            lockTbl = {10}
            rayProperties = { pos =  { x = 161.5, y = 310 },  dir =  { x = 1, y = 1 } }
            goalProperties = {} 
            goalProperties[1] = { x = 22, y = 239 }
            goalProperties[2] = { x = 55, y = 414 }
            goalProperties[3] = { x = 22, y = 170 }
            goalProperties[4] = { x = 195, y = 60 }
            goalProperties[5] = { x = 123, y = 60 }

            stageProperties = { row = 5, col = 4 }
            
            local tempAnswerTbl = {1,2,3,8,15,16,18,19}
            local tempType = { "Mirror", "Glass", "Glass", "Mirror", "Glass", "Mirror", "Glass", "Mirror" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        end

    elseif(world == 3) then
        --------------------------------------- SOLID WORLD ---------------------------------------

        if(level == 1) then 

            tileTbl = {2,3,4,5,6,8,9}
            blockTbl = {3,4,5,6}
            sameTileType( "Solid", #blockTbl )
            emptyTileTbl = {2,4,5}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 90, y = 205 },  dir =  { x = -1, y = 1 } }
            rayProperties[2] = { pos =  { x = 196.5, y = 170 },  dir =  { x = -1, y = 1 } }
            rayProperties[3] = { pos =  { x = 268.5, y = 170 },  dir =  { x = -1, y = 1 } }
            rayProperties[4] = { pos =  { x = 268.5, y = 235 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 57, y = 240 }
            goalProperties[2] = { x = 57, y = 308 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {3,6,8,9}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Solid" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 2) then
           
            tileTbl = {1,2,3,4,5,6,7,8,9}
            blockTbl = {2,4,8,9}
            sameTileType( "Solid", #blockTbl )
            emptyTileTbl = {1,4,5,7,8}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 196.5, y = 240 },  dir =  { x = -1, y = 1 } }
            rayProperties[2] = { pos =  { x = 90, y = 275 },  dir =  { x = 1, y = -1 } }
            rayProperties[3] = { pos =  { x = 232, y = 205 },  dir =  { x = -1, y = 1 } }
            rayProperties[4] = { pos =  { x = 54.5, y = 170 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 157, y = 205 }
            goalProperties[2] = { x = 88, y = 348 }
            goalProperties[3] = { x = 195, y = 308 }

            stageProperties = { row = 3, col = 3 }

            local tempAnswerTbl = {2,3,6,9}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Solid" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 3) then 
           
            tileTbl = {1,3,4,5,6,7,9}
            blockTbl = {3,4,5}
            sameTileType( "Solid", #blockTbl )
            emptyTileTbl = {2,4,5,7,8}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 90, y = 205 },  dir =  { x = 1, y = 1 } }
            rayProperties[2] = { pos =  { x = 54.5, y = 310 },  dir =  { x = 1, y = -1 } }
            rayProperties[3] = { pos =  { x = 161, y = 135 },  dir =  { x = 1, y = 1 } }
            rayProperties[4] = { pos =  { x = 268, y = 170 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 125, y = 235 }
            goalProperties[2] = { x = 160, y = 205 }
            goalProperties[3] = { x = 160, y = 273 }
            goalProperties[4] = { x = 230, y = 205 }

            stageProperties = { row = 3, col = 3 }

            local tempAnswerTbl = {1,6,9}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Solid" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 4) then 

            tileTbl = {1,2,3,4,5,6,7,8,9,10,11,12}
            blockTbl = {3,4,7,11}
            sameTileType( "Solid", #blockTbl )
            -- emptyTileTbl = {2,4,5,6,7,8}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 54.5, y = 140 },  dir =  { x = 1, y = 1 } }
            rayProperties[2] = { pos =  { x = 54.5, y = 350 },  dir =  { x = 1, y = -1 } }
            rayProperties[3] = { pos =  { x = 90, y = 245 },  dir =  { x = 1, y = 1 } }
            rayProperties[4] = { pos =  { x = 125.5, y = 140 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 195, y = 279 }
            goalProperties[2] = { x = 195, y = 208 }
            goalProperties[3] = { x = 160, y = 313 }
            goalProperties[4] = { x = 230, y = 384 }

            stageProperties = { row = 4, col = 3 }

            local tempAnswerTbl = {3,6,9,10}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Solid" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 5) then 

            tileTbl = {1,2,3,4,5,7,8,9,10,11,12}
            blockTbl = {2,4,5,7,9,10,12}
            sameTileType( "Solid", #blockTbl )
            -- emptyTileTbl = {2,4,5,6,7,8}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 54.5, y = 140 },  dir =  { x = 1, y = 1 } }
            rayProperties[2] = { pos =  { x = 54.5, y = 350 },  dir =  { x = 1, y = -1 } }
            rayProperties[3] = { pos =  { x = 90, y = 245 },  dir =  { x = 1, y = 1 } }
            rayProperties[4] = { pos =  { x = 268.5, y = 140 },  dir =  { x = -1, y = 1 } }
            rayProperties[5] = { pos =  { x = 232, y = 313 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 196, y = 210 }
            goalProperties[2] = { x = 90, y = 313 }
            goalProperties[3] = { x = 90, y = 173 }
            goalProperties[4] = { x = 196, y = 348 }

            stageProperties = { row = 4, col = 3 }

            local tempAnswerTbl = {2,4,5,7,8,9,11}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Solid" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 6) then 

            tileTbl = {2,3,4,5,6,7,9,10,11,12}
            blockTbl = {2,3,4,6,7,10,11,12}
            blockTypeTbl = { "Mirror", "Mirror", "Mirror", "Solid", "Solid", "Solid", "Solid", "Solid" }
            -- emptyTileTbl = {2,4,5,6,7,8}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 267.5, y = 280 },  dir =  { x = -1, y = -1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 160, y = 245 }

            stageProperties = { row = 4, col = 3 }

            local tempAnswerTbl = {6,7,11}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Mirror" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 7) then 

            tileTbl = {1,2,3,5,6,7,8,9,10,11,12,13,14,15,16}
            blockTbl = {1,3,5,6,7,5,8,9,10,15}
            blockTypeTbl = { "Mirror", "Mirror", "Solid", "Mirror", "Mirror", "Solid", "Solid", "Solid", "Solid", "Solid" }
            lockTbl = {3,5,7,8}
            -- emptyTileTbl = {6,9,10,11,12,14}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 126, y = 175 },  dir =  { x = 1, y = 1 } }
            rayProperties[2] = { pos =  { x = 308, y = 280 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 126, y = 316 }
            goalProperties[2] = { x = 55, y = 316 }
            goalProperties[3] = { x = 126, y = 387 }
            goalProperties[4] = { x = 20, y = 280 }

            stageProperties = { row = 4, col = 4 }

            local tempAnswerTbl = {13,16,1,2,15}
            local tempType = { "Mirror", "Mirror", "Solid", "Solid", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 8) then 

            tileTbl = {2,3,4,5,7,8,9,10,11,12,13,14,17,18,19,20}
            blockTbl = {8,11,13,19,2,4,14,18,20,5,7,9}
            blockTypeTbl = { "Mirror", "Mirror", "Mirror", "Mirror", "Solid", "Solid", "Solid", "Solid", "Solid", "Solid", "Solid", "Solid", "Solid" }
            lockTbl = {18}
            emptyTileTbl = {7,11}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 126, y = 205 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 299.5, y = 311 }
            goalProperties[2] = { x = 198, y = 132 }

            stageProperties = { row = 5, col = 4 }

            local tempAnswerTbl = {3,8,10,20}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Mirror" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 9) then 

            tileTbl = {1,2,4,5,6,7,8,9,10,12,14,16,18,19}
            blockTbl = {2,8,9,10,18,5,7,14}
            blockTypeTbl = { "Glass", "Mirror", "Mirror", "Mirror", "Mirror", "Solid", "Solid", "Solid", "Solid", "Solid" }
            lockTbl = {9}
            -- emptyTileTbl = {1,6,7,10,14,16}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 268, y = 345 },  dir =  { x = -1, y = -1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 25, y = 309 }
            goalProperties[2] = { x = 25, y = 98 }
            goalProperties[3] = { x = 125, y = 132 }

            stageProperties = { row = 5, col = 4 }

            local tempAnswerTbl = {2,5,12,18,4,8,19}
            local tempType = { "Mirror", "Glass", "Mirror", "Mirror", "Solid", "Solid", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 10) then 

            tileTbl = {1,2,3,4,6,7,8,9,11,12,13,14,15,16,17,18,19,20}
            blockTbl = {9,12,14,16,17,1,6,8,11,19}
            blockTypeTbl = { "Glass", "Mirror", "Glass", "Glass", "Mirror", "Solid", "Solid", "Solid", "Solid", "Solid" }
            -- lockTbl = {18}
            emptyTileTbl = {1,4,7,8,13,14,15,16}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 55, y = 345 },  dir =  { x = 1, y = -1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 298.5, y = 309 }
            goalProperties[2] = { x = 298.5, y = 98 }
            goalProperties[3] = { x = 20, y = 309 }
            goalProperties[4] = { x = 20, y = 98 }
            goalProperties[5] = { x = 160, y = 309 }

            stageProperties = { row = 5, col = 4 }

            local tempAnswerTbl = {6,9,11,12,19}
            local tempType = { "Glass", "Glass", "Glass", "Mirror", "Mirror" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        end

    elseif(world == 4) then
        --------------------------------------- PRISM WORLD ---------------------------------------

        if(level == 1) then 

            tileTbl = {2,3,4,5,6,7,8}
            blockTbl = {4}
            sameTileType( "Prism", #blockTbl )
            -- emptyTileTbl = {2,4,5}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 168 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 272, y = 312 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {5}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Prism" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 2) then
           
            tileTbl = {1,2,3,4,5,6,7,8,9}
            blockTbl = {2,6,5}
            blockTypeTbl = { "Prism", "Prism", "Solid" }
            lockTbl = {5}
            -- emptyTileTbl = {2,4,5}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 168 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 232, y = 345 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {4,8}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Prism" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 3) then 
           
            tileTbl = {1,2,4,5,7,9,10,11,12}
            blockTbl = {1,4,5}
            blockTypeTbl = { "Prism", "Prism", "Prism" }
            lockTbl = {5}
            -- emptyTileTbl = {2,4,5}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 268, y = 140 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 90, y = 390 }

            stageProperties = { row = 4, col = 3 }
            
            local tempAnswerTbl = {7,10}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Prism" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 4) then 

            tileTbl = {1,3,4,5,6,7,9,10,11,12}
            blockTbl = {5,7,9}
            blockTypeTbl = { "Prism", "Mirror", "Prism" }
            -- lockTbl = {5}
            -- emptyTileTbl = {2,4,5}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 268, y = 140 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 55, y = 140 }

            stageProperties = { row = 4, col = 3 }
            
            local tempAnswerTbl = {7,10}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Prism" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 5) then 

            tileTbl = {1,2,3,4,5,6,7,8,9,10,11,12}
            blockTbl = {5,2,7,9}
            blockTypeTbl = { "Prism", "Solid", "Solid", "Solid" }
            -- lockTbl = {5}
            -- emptyTileTbl = {2,4,5}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 232, y = 315 },  dir =  { x = -1, y = -1 } }
            rayProperties[2] = { pos =  { x = 53, y = 282 },  dir =  { x = 1, y = -1 } }
            rayProperties[3] = { pos =  { x = 124, y = 352 },  dir =  { x = 1, y = -1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 268, y = 140 }
            goalProperties[2] = { x = 90, y = 102 }

            stageProperties = { row = 4, col = 3 }
            
            local tempAnswerTbl = {5, 10,11,12}
            local tempType = { "Prism", "Solid", "Solid", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 6) then 

            tileTbl = {1,3,4,5,6,7,8,9,10,11,12,14}
            blockTbl = {6,7,9,11, 4,10,12}
            blockTypeTbl = { "Mirror", "Prism", "Mirror", "Prism", "Solid", "Solid", "Solid" }
            lockTbl = {6,7}
            emptyTileTbl = {1,4}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 98 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 53, y = 165 }

            stageProperties = { row = 5, col = 3 }
            
            local tempAnswerTbl = {5,10}
            local tempType = { "Prism", "Mirror" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 7) then 

            tileTbl = {1,2,3,4,5,6,9,10,11,12,13,14}
            blockTbl = {1,2}
            blockTypeTbl = { "Prism", "Prism" }
            -- lockTbl = {6,7}
            -- emptyTileTbl = {1,4}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 98 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 230, y = 413 }

            stageProperties = { row = 5, col = 3 }
            
            local tempAnswerTbl = {4,11}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Prism" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 8) then 

            tileTbl = {1,2,3,4,6,8,9,11,12,13,14,15,16}
            blockTbl = {1,2,3,8}
            blockTypeTbl = { "Prism", "Mirror", "Mirror", "Solid" }
            lockTbl = {8}
            -- emptyTileTbl = {1,4}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 388 },  dir =  { x = 1, y = -1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 267, y = 103 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {4,11}

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = "Prism" }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 9) then 

            tileTbl = {1,2,3,4,5,7,8,10,12,13,14,15,16}
            blockTbl = {1,2,3,5,12}
            blockTypeTbl = { "Prism", "Mirror", "Glass", "Solid", "Solid" }
            lockTbl = {5,12}
            -- emptyTileTbl = {1,4}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 267, y = 103 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 55, y = 243 }
            goalProperties[2] = { x = 267, y = 383 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {7,10,14}
            local tempType = { "Prism", "Glass", "Mirror" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 10) then 

            tileTbl = {1,2,4,5,6,7,8,9,10,11,12,13,14,16}
            blockTbl = {1,2,4,5,12,13,14}
            blockTypeTbl = { "Prism", "Mirror", "Mirror", "Solid", "Solid" }
            -- lockTbl = {5,12}
            emptyTileTbl = {2,4,6,10,11}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 125, y = 103 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 90, y = 280 }
            goalProperties[2] = { x = 267, y = 103 }
            goalProperties[3] = { x = 232, y = 208 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {1,7,8,9,14}
            local tempType = { "Mirror", "Prism", "Mirror", "Mirror", "Mirror" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        end

    elseif(world == 5) then
        --------------------------------------- TWISTED WORLD ---------------------------------------

        if(level == 1) then 

            tileTbl = {1,2,4,5,7,8,9}
            blockTbl = {2,4,9, 5}
            blockTypeTbl = { "Mirror", "Prism", "Glass", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 168 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 162, y = 345 }
            goalProperties[2] = { x = 238, y = 130 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {2,4,9, 7}
            local tempType = { "Prism", "Glass", "Mirror", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 2) then
           
            tileTbl = {1,4,5,6,7,8}
            blockTbl = {6,4,1, 5}
            blockTypeTbl = { "Mirror", "Prism", "Glass", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 168 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 55, y = 308 }
            goalProperties[2] = { x = 162, y = 130 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {4,5,6, 8}
            local tempType = { "Glass", "Prism", "Mirror", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 3) then 
           
            tileTbl = {1,2,3,5,6,8,9}
            blockTbl = {2,6,9, 5}
            blockTypeTbl = { "Mirror", "Prism", "Glass", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 168 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 268, y = 240 }
            goalProperties[2] = { x = 235, y = 130 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {1,5,9, 8}
            local tempType = { "Prism", "Glass", "Mirror", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 4) then 

            tileTbl = {1,2,3,4,5,6,7,8,9}
            blockTbl = {8,4,6, 1,3}
            blockTypeTbl = { "Mirror", "Prism", "Glass", "Solid", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 162, y = 134 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 55, y = 165 }
            goalProperties[2] = { x = 90, y = 345 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {2,6,8, 3,9}
            local tempType = { "Prism", "Mirror", "Glass", "Solid", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 5) then 

            tileTbl = {1,2,3,4,5,6,8,9}
            blockTbl = {2,6,5, 8}
            blockTypeTbl = { "Glass", "Mirror", "Prism", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 270, y = 168 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 234, y = 345 }
            goalProperties[2] = { x = 90, y = 130 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {3,4,5, 6}
            local tempType = { "Prism", "Mirror", "Glass", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 6) then 

            tileTbl = {1,2,3,4,5,6,7,9}
            blockTbl = {1,3,5, 4}
            blockTypeTbl = { "Mirror", "Prism", "Glass", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 168 },  dir =  { x = 1, y = 1 } }
            rayProperties[2] = { pos =  { x = 270, y = 168 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 55, y = 308 }
            goalProperties[2] = { x = 232, y = 130 }
            goalProperties[3] = { x = 232, y = 273 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {2,5,6, 9}
            local tempType = { "Mirror", "Prism", "Glass", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 7) then 

            tileTbl = {1,2,3,4,5,7,8}
            blockTbl = {1,3,4, 5}
            blockTypeTbl = { "Mirror", "Glass", "Prism", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 54, y = 310 },  dir =  { x = 1, y = -1 } }
            rayProperties[2] = { pos =  { x = 270, y = 168 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 55, y = 168 }
            goalProperties[2] = { x = 90, y = 130 }
            goalProperties[3] = { x = 55, y = 240 }
            goalProperties[4] = { x = 162, y = 130 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {1,3,5, 8}
            local tempType = { "Glass", "Prism", "Mirror", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 8) then 

            tileTbl = {1,2,3,5,6,7,8,9}
            blockTbl = {5,8,9, 3}
            blockTypeTbl = { "Mirror", "Glass", "Prism", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 54, y = 310 },  dir =  { x = 1, y = -1 } }
            rayProperties[2] = { pos =  { x = 270, y = 238 },  dir =  { x = -1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 162, y = 130 }
            goalProperties[2] = { x = 90, y = 345 }
            goalProperties[3] = { x = 232, y = 345 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {3,7,8, 1}
            local tempType = { "Mirror", "Glass", "Prism", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 9) then 

            tileTbl = {1,2,3,4,5,6,9}
            blockTbl = {4,5,6, 2}
            blockTypeTbl = { "Glass", "Mirror", "Prism", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 53, y = 168 },  dir =  { x = 1, y = 1 } }
            rayProperties[2] = { pos =  { x = 198, y = 310 },  dir =  { x = -1, y = -1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 270, y = 238 }
            goalProperties[2] = { x = 90, y = 130 }
            goalProperties[3] = { x = 162, y = 130 }

            stageProperties = { row = 3, col = 3 }
            
            local tempAnswerTbl = {4,5,9, 3}
            local tempType = { "Glass", "Prism", "Mirror", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        elseif(level == 10) then 

            tileTbl = {1,2,3,5,7,8,9,11,12,14,15,16}
            blockTbl = {2,3,5,7,12,15, 8,9,16}
            blockTypeTbl = { "Glass", "Mirror", "Mirror", "Mirror", "Mirror", "Prism", "Solid", "Solid", "Solid" }
            -- lockTbl = {7}

            rayProperties = {}
            rayProperties[1] = { pos =  { x = 161.5, y = 280 },  dir =  { x = 1, y = 1 } }

            goalProperties = {} 
            goalProperties[1] = { x = 90, y = 280 }
            goalProperties[2] = { x = 55, y = 102 }
            goalProperties[3] = { x = 305, y = 205 }

            stageProperties = { row = 4, col = 4 }
            
            local tempAnswerTbl = {3,7,9,11,12,14, 5,15,16}
            local tempType = { "Mirror", "Glass", "Mirror", "Prism", "Mirror", "Mirror", "Solid", "Solid", "Solid" }

            for i = 1, #tempAnswerTbl, 1 do
                local tempTbl = { answerID = tempAnswerTbl[i], answerType = tempType[i] }
                table.insert(answerTbl, tempTbl)
            end

        end
    end

    local options =
    {
        effect = sceneEffect,
        time = nextSceneTime,
        params =
        {
            mworld = worldID,
            mlevel = level,
            mtileTbl = tileTbl,
            mblockTbl = blockTbl,
            mlockTbl = lockTbl,
            memptyTileTbl = emptyTileTbl,
            mblockTypeTbl = blockTypeTbl,
            mrayProperties = rayProperties,
            mgoalProperties = goalProperties,
            mstageProperties = stageProperties,
            mAnswerTbl = answerTbl
        }
    }

    return options
end

-----------------------------------------------------------------------------------------------
    -- Event functions
-----------------------------------------------------------------------------------------------

-- Function to handle button events
local function handleButtonEvent( event )
    if ( event.phase == "ended" ) then

        if(event.target.isLocked) then return end
        
        if(event.target.name == "backBtn") then
            storyboard.gotoScene(prevScene, sceneEffect, nextSceneTime)
        else
            local options = loadLevel(worldID, event.target.id)
            storyboard.gotoScene( nextScene, options );
        end

    end
end

-----------------------------------------------------------------------------------------------
    -- Main
-----------------------------------------------------------------------------------------------

local function isStageIDLock( id )
    if(worldID == 1) then

        if(#mirrorTbl == 0) then return nil
        else print("ID: " .. id); print(mirrorTbl[id].isLocked); return mirrorTbl[id].isLocked
        end
     
    elseif(worldID == 2) then 

        if(#glassTbl == 0) then return nil
        else print("ID: " .. id); print(glassTbl[id].isLocked); return glassTbl[id].isLocked
        end

    elseif(worldID == 3) then 
        if(#solidTbl == 0) then return nil
        else print("ID: " .. id); print(solidTbl[id].isLocked); return solidTbl[id].isLocked
        end

    elseif(worldID == 4) then 

        if(#prismTbl == 0) then return nil
        else return prismTbl[id].isLocked
        end

    elseif(worldID == 5) then 

        if(#twistedTbl == 0) then return nil
        else return twistedTbl[id].isLocked
        end

    end
end

local function createButtons(screenGroup)

    local function genBtn( default, over, id )
        local button = widget.newButton
        {
            font = "Arial",
            emboss = true,
            width = 60,
            height = 60,
            defaultFile = default,
            overFile = over,
            onEvent = handleButtonEvent
        }
        button.anchorX = 0.5; button.anchorY = 0.5;

        local colID = id

        if(id > 8) then colID = id - 7
        elseif(id > 4) then colID = id - 4
        end

        if(id == 5 or id == 9) then  rowID = rowID + 1 end

        button.x = _W * ( 0.2 * (colID) ); button.y = _H * ( 0.43 +  0.15 * rowID );
        button.id = id
        
        if(id == 5 or id == 10) then button.isGetHint = true end

        if(dataTable.world[worldID].lockPointID == -1) then 

            if( id == 1 ) then 
                button.isLocked = false
                btnGroup:insert( button )
                return 
            end

            if(isStageIDLock(id) == false) then
                button.isLocked = false
                btnGroup:insert( button )
                return
            end

            button.isLocked = true

            local lockImg = display.newImage("Images/Glass_level/level_lock.png", button.x + 16, button.y + 14);
            lockImg.xScale = 0.12; lockImg.yScale = 0.12;
            lockImg.id = id

            lockGroup:insert( lockImg )
        else

            local currStartLock = dataTable.world[worldID].lockPointID

            if( id < currStartLock ) then
                button.isLocked = false
                btnGroup:insert( button )
                return
            elseif( id >= currStartLock ) then
                button.isLocked = true

                local lockImg = display.newImage("Images/Glass_level/level_lock.png", button.x + 16, button.y + 14);
                lockImg.xScale = 0.12; lockImg.yScale = 0.12;
                lockImg.id = id

                lockGroup:insert( lockImg )
            end
        end
             
        
        btnGroup:insert( button )
        
    end


    if(worldID == 1) then
        genBtn( "Images/Mirrors_level/level_1_botton.png", "Images/game/empty_box.png", 1 )
        genBtn( "Images/Mirrors_level/level_2_botton.png", "Images/game/empty_box.png", 2 )
        genBtn( "Images/Mirrors_level/level_3_botton.png", "Images/game/empty_box.png", 3 )
        genBtn( "Images/Mirrors_level/level_4_botton.png", "Images/game/empty_box.png", 4 )
        genBtn( "Images/Mirrors_level/level_5_botton.png", "Images/game/empty_box.png", 5 )
        genBtn( "Images/Mirrors_level/level_6_botton.png", "Images/game/empty_box.png", 6 )
        genBtn( "Images/Mirrors_level/level_7_botton.png", "Images/game/empty_box.png", 7 )
        genBtn( "Images/Mirrors_level/level_8_botton.png", "Images/game/empty_box.png", 8 )
        genBtn( "Images/Mirrors_level/level_9_botton.png", "Images/game/empty_box.png", 9 )
        genBtn( "Images/Mirrors_level/level_10_botton.png", "Images/game/empty_box.png", 10 )
    elseif(worldID == 2) then
        genBtn( "Images/Glass_level/level_1_botton.png", "Images/game/empty_box.png", 1 )
        genBtn( "Images/Glass_level/level_2_botton.png", "Images/game/empty_box.png", 2 )
        genBtn( "Images/Glass_level/level_3_botton.png", "Images/game/empty_box.png", 3 )
        genBtn( "Images/Glass_level/level_4_botton.png", "Images/game/empty_box.png", 4 )
        genBtn( "Images/Glass_level/level_5_botton.png", "Images/game/empty_box.png", 5 )
        genBtn( "Images/Glass_level/level_6_botton.png", "Images/game/empty_box.png", 6 )
        genBtn( "Images/Glass_level/level_7_botton.png", "Images/game/empty_box.png", 7 )
        genBtn( "Images/Glass_level/level_8_botton.png", "Images/game/empty_box.png", 8 )
        genBtn( "Images/Glass_level/level_9_botton.png", "Images/game/empty_box.png", 9 )
        genBtn( "Images/Glass_level/level_10_botton.png", "Images/game/empty_box.png", 10 )
    elseif(worldID == 3) then
        genBtn( "Images/Solids_level/level_1_botton.png", "Images/game/empty_box.png", 1 )
        genBtn( "Images/Solids_level/level_2_botton.png", "Images/game/empty_box.png", 2 )
        genBtn( "Images/Solids_level/level_3_botton.png", "Images/game/empty_box.png", 3 )
        genBtn( "Images/Solids_level/level_4_botton.png", "Images/game/empty_box.png", 4 )
        genBtn( "Images/Solids_level/level_5_botton.png", "Images/game/empty_box.png", 5 )
        genBtn( "Images/Solids_level/level_6_botton.png", "Images/game/empty_box.png", 6 )
        genBtn( "Images/Solids_level/level_7_botton.png", "Images/game/empty_box.png", 7 )
        genBtn( "Images/Solids_level/level_8_botton.png", "Images/game/empty_box.png", 8 )
        genBtn( "Images/Solids_level/level_9_botton.png", "Images/game/empty_box.png", 9 )
        genBtn( "Images/Solids_level/level_10_botton.png", "Images/game/empty_box.png", 10 )
    elseif(worldID == 4) then
        genBtn( "Images/Prisms_level/level_1_botton.png", "Images/game/empty_box.png", 1 )
        genBtn( "Images/Prisms_level/level_2_botton.png", "Images/game/empty_box.png", 2 )
        genBtn( "Images/Prisms_level/level_3_botton.png", "Images/game/empty_box.png", 3 )
        genBtn( "Images/Prisms_level/level_4_botton.png", "Images/game/empty_box.png", 4 )
        genBtn( "Images/Prisms_level/level_5_botton.png", "Images/game/empty_box.png", 5 )
        genBtn( "Images/Prisms_level/level_6_botton.png", "Images/game/empty_box.png", 6 )
        genBtn( "Images/Prisms_level/level_7_botton.png", "Images/game/empty_box.png", 7 )
        genBtn( "Images/Prisms_level/level_8_botton.png", "Images/game/empty_box.png", 8 )
        genBtn( "Images/Prisms_level/level_9_botton.png", "Images/game/empty_box.png", 9 )
        genBtn( "Images/Prisms_level/level_10_botton.png", "Images/game/empty_box.png", 10 )
    elseif(worldID == 5) then
        genBtn( "Images/Twisted Level/level_1_botton.png", "Images/game/empty_box.png", 1 )
        genBtn( "Images/Twisted Level/level_2_botton.png", "Images/game/empty_box.png", 2 )
        genBtn( "Images/Twisted Level/level_3_botton.png", "Images/game/empty_box.png", 3 )
        genBtn( "Images/Twisted Level/level_4_botton.png", "Images/game/empty_box.png", 4 )
        genBtn( "Images/Twisted Level/level_5_botton.png", "Images/game/empty_box.png", 5 )
        genBtn( "Images/Twisted Level/level_6_botton.png", "Images/game/empty_box.png", 6 )
        genBtn( "Images/Twisted Level/level_7_botton.png", "Images/game/empty_box.png", 7 )
        genBtn( "Images/Twisted Level/level_8_botton.png", "Images/game/empty_box.png", 8 )
        genBtn( "Images/Twisted Level/level_9_botton.png", "Images/game/empty_box.png", 9 )
        genBtn( "Images/Twisted Level/level_10_botton.png", "Images/game/empty_box.png", 10 )
    end

    screenGroup:insert( btnGroup )
    screenGroup:insert( lockGroup )
end

local function clearScene()
    btnGroup:removeSelf()
    lockGroup:removeSelf()

    btnGroup = display.newGroup()
    lockGroup = display.newGroup()
    
    rowID = 0

    if(stageTitle ~= nil) then 
        stageTitle:removeSelf()
        stageTitle = nil
    end
end

---------------------------------------------------------------------------------
-- BEGINNING OF YOUR IMPLEMENTATION
---------------------------------------------------------------------------------

function scene:createScene( event )
    print( "\nStageSelect: createScene event" )

    local screenGroup = self.view

    local gameBg = display.newImage("Images/Glass_level/background.png", X_Center, Y_Center);
    gameBg.xScale = 0.21; gameBg.yScale = 0.25;

    screenGroup:insert( gameBg ) 
    screenGroup:insert( genBackBtn( handleButtonEvent ) )
    
 end

function scene:willEnterScene( event )
    print( "\nStageSelect: willEnterScene event" )

    local screenGroup = self.view

    if(event.params ~= nil) then 

        local params = event.params

        if(params.mlevel ~= nil) then
            -- This occurs after finishing a level and moving on to the next one.
            local options = loadLevel(worldID, params.mlevel)
            storyboard.gotoScene( nextScene, options );
        elseif(params.id ~= nil) then
            -- This occurs after the world selection scene. Get current world.

            if(worldID ~= params.id) then
                -- Selected a different world. Clear scene.
                clearScene()
                worldID = params.id
            else return
            end

            local tittleImg
            if(worldID == 1) then tittleImg = "Images/Mirrors_level/Mirrors_title.png"
            elseif(worldID == 2) then tittleImg = "Images/Glass_level/Glass_title.png"
            elseif(worldID == 3) then tittleImg = "Images/Solids_level/Solids_title.png"
            elseif(worldID == 4) then tittleImg = "Images/Prisms_level/Prisms_title.png"
            elseif(worldID == 5) then tittleImg = "Images/Twisted Level/Twisted_title.png"
            end

            stageTitle = display.newImage(tittleImg, X_Center, _H * 0.17);
            stageTitle.xScale = 0.25; stageTitle.yScale = 0.25;
            screenGroup:insert( stageTitle ) 

            createButtons(screenGroup)
        end
         
    end
end

function scene:exitScene()
    print( "StageSelect: exitScene event" )
end

function scene:destroyScene( event )
    print( "((destroying scene StageSelect's view))" )
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