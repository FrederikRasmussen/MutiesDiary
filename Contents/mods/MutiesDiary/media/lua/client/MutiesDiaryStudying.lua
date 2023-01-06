require "MutiesDiary"
require "MutiesDiary/Diary"
require "ISUI/ISInventoryPaneContextMenu"

local function studyDiaryEntry(item, playerNum)
    local player = getSpecificPlayer(playerNum);
    if item:getContainer() == nil then
        return
    end
    ISInventoryPaneContextMenu.transferIfNeeded(player, item);
    -- read
    ISTimedActionQueue.add(ISReadABook:new(player, item, 150, true));
end

local MutiesDiaryContextMenu = {};
---@param context ISContextMenu
---@param diary InventoryItem
function MutiesDiaryContextMenu.addStudyContextForDiary(playerNum, context, items)
    for _, item in ipairs(items) do
        if not instanceof(item, "InventoryItem") then
            item = item.items[1];
        end
        ---@type MutiesDiary.Diary
        local diary = MutiesDiary.Diary:new(item);
        if diary then
            context:addOption(
                    getText("IGUI_Study"),
                    item,
                    studyDiaryEntry, playerNum
            );
        end
    end
end
Events.OnPreFillInventoryObjectContextMenu.Add(MutiesDiaryContextMenu.addStudyContextForDiary);
