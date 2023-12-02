require "MutiesDiary"

local originalISReadABookNew = ISReadABook.new;
---@param character IsoPlayer | IsoGameCharacter | IsoObject
---@param item Literature | InventoryItem
function ISReadABook:new(character, item, time, study)
    ---@type MutiesDiary.Diary
    local diary = MutiesDiary.Diary:new(item);
    if not diary then
        return originalISReadABookNew(self, character, item, time);
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
    if false and action.numberOfEntries == action.numberOfReadEntries then
        item:setNumberOfPages(-1);
        action.maxTime = 0;
        action.skip = true;
        character:setSayLine("I've already read what I can.");
    else
        item:setNumberOfPages(action.numberOfEntries);
        character:setAlreadyReadPages(
                item:getFullType(),
                action.numberOfReadEntries
        );
    end
    return action;
end

local function updateReadStatus(action, resetPageCount)
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

    if resetPageCount then
        action.item:setNumberOfPages(-1);
    end
end

ISReadABook.checkMultiplier = function(self)
    -- get all our info in the map
    local trainedStuff = SkillBook[self.item:getSkillTrained()];
    if trainedStuff then
        -- every 10% we add 10% of the max multiplier
        local readPercent = (self.item:getAlreadyReadPages() / self.item:getNumberOfPages()) * 100;
        if readPercent > 100 then
            readPercent = 100;
        end
        -- apply the multiplier to the skill
        local multiplier = (math.floor(readPercent/10) * (self.maxMultiplier/10));
        if multiplier > self.character:getXp():getMultiplier(trainedStuff.perk) then
            self.character:getXp():addXpMultiplier(trainedStuff.perk, multiplier, self.item:getLvlSkillTrained(), self.item:getMaxLevelTrained());
        end
    end
end

---@param action ISReadABook
local function preCheckMultiplier(action)
    if action.skip then return end
    local trainedStuff = SkillBook[action.item:getSkillTrained()];
    if not trainedStuff then return end

    ---@type PerkFactory.Perk
    local perk = trainedStuff.perk;
    local skill = perk:getName();

    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(action.character);
    local boostStart, boostEnd = player:boostLevels(skill);
    local studyMultiplier = 1.0 + player:skillBoostMultiplier(skill);
    local currentMultiplier = player.player:getXp():getMultiplier(perk);
    local foreignMultiplier = currentMultiplier / (studyMultiplier);
    if currentMultiplier ~= currentMultiplier then
        foreignMultiplier = 1.0;
    end
    foreignMultiplier = foreignMultiplier * 10.0;
    foreignMultiplier = math.floor(foreignMultiplier + 0.5);
    foreignMultiplier = foreignMultiplier / 10.0;
    player.player:getXp():addXpMultiplier(
            perk,
            foreignMultiplier,
            boostStart,
            boostEnd
    );
    return player.player, perk, studyMultiplier, boostStart, boostEnd;
end

---@param player IsoPlayer
local function postCheckMultiplier(player, perk, studyMultiplier, boostStart, boostEnd)
    if not player then return end;
    player:getXp():addXpMultiplier(
            perk,
            player:getXp():getMultiplier(perk) * studyMultiplier,
            boostStart,
            boostEnd
    );
end

local originalISCheckMultiplier = ISReadABook.checkMultiplier;
function ISReadABook:checkMultiplier()
    local player, perk, studyMultiplier, boostStart, boostEnd = preCheckMultiplier(self);
    originalISCheckMultiplier(self);
    postCheckMultiplier(player, perk, studyMultiplier, boostStart, boostEnd);
end

local originalISReadABookUpdate = ISReadABook.update;
function ISReadABook:update()
    originalISReadABookUpdate(self);
    updateReadStatus(self, false);
end

local originalISReadABookStop = ISReadABook.stop;
function ISReadABook:stop()
    originalISReadABookStop(self);
    updateReadStatus(self, true);
end