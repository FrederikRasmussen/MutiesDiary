require "MutiesDiary"
require "MutiesDiary/Diary"
require "MutiesDiary/Player"

---@param character IsoPlayer
function MutiesDiary.hasNewExperiences(recipe, character, item)
    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(character);
    if not player:canRead() then return false end
    local daysRemembered = player:daysRemembered();
    if #daysRemembered < 1 then return false end
    local today = getGameTime():getDay();
    return daysRemembered[1] ~= today;
end

local function oldestDayRemembered(player)
    local validDays = player:daysRemembered();
    table.sort(validDays);
    return validDays[1];
end

local function skillLevelsFor(player, xp)
    local skillLevels = {};
    for skill, _ in pairs(xp) do
        local perk = PerkFactory.getPerkFromName(skill);
        skillLevels[skill] = player:perkLevel(perk);
    end
    return skillLevels;
end

---@param player MutiesDiary.Player
---@param number int
local function newEntry(player, number)
    local entry = {};
    entry.number = number;
    entry.writtenBy = player:fullName();
    entry.traits = copyTable(player:traits());
    entry.recipes = player:knownRecipes();
    entry.day = oldestDayRemembered(player);
    entry.xp = copyTable(player:rememberedXpForDay(entry.day));
    entry.skillLevels = skillLevelsFor(player, entry.xp);
    player:forgetDay(entry.day);
    return entry;
end

---@param items ArrayList
---@param character IsoObject
function MutiesDiary.writeInDiary(items, result, character)
    ---@type MutiesDiary.Diary
    local diary;
    for i = 0, items:size() - 1 do
        diary = MutiesDiary.Diary:new(items:get(i));
        if diary then break end
    end
    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(character);

    if not diary:owner() then
        diary:changeOwner(player);
    end
    diary:addEntry(newEntry(player, diary:numberOfEntries() + 1));
    player:markNewestEntryAsRead(diary);
end
