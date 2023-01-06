require "MutiesDiary"

local originalISReadABookNew = ISReadABook.new;
---@param character IsoPlayer | IsoGameCharacter | IsoObject
---@param item Literature | InventoryItem
function ISReadABook:new(character, item, time, study)
    ---@type MutiesDiary.Diary
    local diary = MutiesDiary.Diary:new(item);
    if not diary then
        originalISReadABookNew(self, character, item, time);
    end

    local action;
    if diary:unwritten() then
        action = originalISReadABookNew(self, character, item, time);
        action.maxTime = 0;
        action.skip = true;
        character:setSayLine("It's empty.");
        return action;
    end

    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(character);
    action = originalISReadABookNew(self, character, item, time);
    -- action.unreadEntries;
    action.study = study;
    if action.study then
        action.unreadEntries = diary:entriesForStudy(player);
    else
        action.unreadEntries = diary:unreadEntries(player);
    end
    action.numberOfEntries = diary:numberOfEntries();
    action.numberOfReadEntries = action.numberOfEntries - #action.unreadEntries;
    if action.numberOfEntries == action.numberOfReadEntries then
        item:setNumberOfPages(-1);
        action.maxTime = 0;
        action.skip = true;
    else
        item:setNumberOfPages(action.numberOfEntries);
        character:setAlreadyReadPages(
                item:getFullType(),
                action.numberOfReadEntries
        );
    end
    return action;
end

local function updateReadStatus(action)
    ---@type MutiesDiary.Diary
    local diary = MutiesDiary.Diary:new(action.item);
    if not diary then return end
    if action.skip then return end
    if action.item:getAlreadyReadPages() >= action.item:getNumberOfPages() then
        action.item:setNumberOfPages(-1);
    end
    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(action.character);
    if diary:numberOfReadPages() > action.numberOfReadEntries then
        local entries = {};
        for i = 1, diary:numberOfReadPages() - action.numberOfReadEntries do
            table.insert(entries, action.unreadEntries[i]);
        end
        if action.study then
            player:studyEntries(entries);
        else
            player:readEntries(diary, entries);
        end
    end
    -- action.unreadEntries;
    if action.study then
        action.unreadEntries = diary:entriesForStudy(player);
    else
        action.unreadEntries = diary:unreadEntries(player);
    end
end

local originalISReadABooKUpdate = ISReadABook.update
function ISReadABook:update()
    originalISReadABooKUpdate(self);
    updateReadStatus(self);
end

local originalISReadABookStop = ISReadABook.stop;
function ISReadABook:stop()
    originalISReadABookStop(self);
    updateReadStatus(self);
    self.item:setNumberOfPages(-1);
end