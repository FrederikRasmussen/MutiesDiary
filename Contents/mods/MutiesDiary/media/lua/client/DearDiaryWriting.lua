require "DearDiary"

---@param player IsoGameCharacter | IsoObject
function DearDiary.hasNewExperiences(recipe, player, item)
    if player:getCharacterTraits():isIlliterate() then
        return false;
    end

    local playerData = player:getModData();

    local lastWritten = playerData.lastWrittenInDiary or 0;
    if getGameTime():getDay() <= lastWritten then
        return true;
    end

    return true;
end

---@param items ArrayList
---@param player IsoObject
function DearDiary.writeInDiary(items, result, player)
    ---@type Literature | InventoryItem
    local diary;
    for i = 0, items:size() - 1 do
        local current = items:get(i);
        if current:getFullType() == "Mutie.Diary" then
            diary = current;
            break;
        end
    end

    local diaryData = diary:getModData();
    local playerData = player:getModData();
    if diaryData.entryCount then
        DearDiary.writeEntry(player, diaryData, playerData);
    else
        DearDiary.writeFirstEntry(player, diaryData, playerData);
    end
end

---@param player IsoPlayer
---@param diaryData KahluaTable
---@param playerData KahluaTable
function DearDiary.writeFirstEntry(player, diaryData, playerData)
    diaryData.username = player:getUsername();
    diaryData.entryCount = 0;
    diaryData.entries = {};
    DearDiary.writeEntry(player, diaryData, playerData);
end

function DearDiary.traitIsIgnored(traitName)
    return false;
end

---@param player IsoPlayer | IsoGameCharacter
---@param diaryData KahluaTable
---@param playerData KahluaTable
function DearDiary.writeEntry(player, diaryData, playerData)
    local xpByDay = playerData.xpByDay or {};
    local day = getGameTime():getDay();
    local entry = {};
    entry.writtenBy = player:getFullName();
    local traits = player:getTraits();
    entry.traits = {};
    for i = 0, traits:size() - 1 do
        local trait = traits:get(i);
        if not DearDiary.traitIsIgnored(trait) then
            table.insert(entry.traits, trait);
        end
    end
    local recipes = player:getKnownRecipes();
    entry.recipes = {};
    for i = 0, recipes:size() - 1 do
        table.insert(entry.recipes, recipes:get(i));
    end
    entry.day = day;
    entry.xp = copyTable(xpByDay[day] or {});
    entry.title = DearDiary.titleEntry(player, diaryData, entry);
    table.insert(diaryData.entries, entry);
    diaryData.entryCount = diaryData.entryCount + 1;
end

---@param player IsoPlayer
---@param diaryData KahluaTable
---@param entry KahluaTable
function DearDiary.titleEntry(player, diaryData, entry)
    return "Dear Diary";
end
