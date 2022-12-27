require "DearDiary"

---@param player IsoObject
---@param diary InventoryItem
local function hasRead(player, diary, entryNumber)
    local playerData = player:getModData();
    local diariesRead = playerData.diaryReading;
    if not diariesRead then
        return false;
    end
    local diaryRead = diariesRead[diary:getID()];
    if not diaryRead then
        return false;
    end
    local entryRead = diaryRead[entryNumber];
    if not entryRead then
        return false;
    end
    return true;
end

function DearDiary.readEntireDiary(player, diary)
    if diary:getFullType() ~= "Mutie.Diary" then
        return;
    end
    local diaryData = diary:getModData();
    local entries = diaryData.entries;
    local unreadEntries = {};
    for i = 1, #entries do
        local entry = entries[i];
        if not hasRead(player, i) then
            table.insert(unreadEntries, entry);
        end
    end
    DearDiary.readEntries(player, unreadEntries);
end

function DearDiary.readEntries(player, entries)
    print("Reading entries!");
end

local originalISReadABookNew = ISReadABook.new;
---@param character IsoPlayer
---@param item Literature | InventoryItem
function ISReadABook:new(character, item, time)
    if item:getFullType() ~= "Mutie.Diary" then
        return originalISReadABookNew(character, item, time);
    end



    return originalISReadABookNew(character, item, time);
end

local originalISReadABookStart = ISReadABook.start;
local originalISReadABookStop = ISReadABook.stop;
