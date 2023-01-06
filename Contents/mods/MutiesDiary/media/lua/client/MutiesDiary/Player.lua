require "MutiesDiary"

---@class MutiesDiary.Player
MutiesDiary.Player = {
    player = IsoPlayer or IsoGameCharacter or IsoObject
};
MutiesDiary.Player.Type = "MutiesDiary.Player";

---@return boolean
function MutiesDiary.Player:canRead()
    return not self.player:getCharacterTraits():isIlliterate();
end

---@return String
function MutiesDiary.Player:username()
    return self.player:getUsername();
end

function MutiesDiary.Player:hasNoSteamId()
    return self.player:getSteamID() == 0;
end

---@return int
function MutiesDiary.Player:playerNum()
    return self.player:getPlayerNum();
end

---@private
function MutiesDiary.Player:data()
    local modData = self.player:getModData()
    modData.MutiesDiary = self.player:getModData().MutiesDiary or {};
    return modData.MutiesDiary;
end

---@private
function MutiesDiary.Player:rememberedXp()
    local data = self:data();
    data.rememberedXpByDay = data.rememberedXpByDay or {};
    return data.rememberedXpByDay
end

---@param day int
function MutiesDiary.Player:rememberedXpForDay(day)
    local rememberedXpByDay = self:rememberedXp();
    rememberedXpByDay[day] = rememberedXpByDay[day] or {};
    return rememberedXpByDay[day];
end

---@param day int
---@param perkName String
---@param amount float
function MutiesDiary.Player:rememberXp(day, perkName, amount)
    local rememberedXp = self:rememberedXpForDay(day);
    rememberedXp[perkName] = rememberedXp[perkName] or 0.0;
    rememberedXp[perkName] = rememberedXp[perkName] + amount;
end

function MutiesDiary.Player:daysRemembered()
    local daysRemembered = {}
    for day, _ in pairs(self:rememberedXp()) do
        table.insert(daysRemembered, day);
    end
    return daysRemembered;
end

---@param day int
function MutiesDiary.Player:forgetDay(day)
    self:rememberedXp()[day] = nil;
end

function MutiesDiary.Player:fullName()
    return self.player:getFullName();
end

function MutiesDiary.Player:traits()
    local traits = {};
    local allTraits = self.player:getTraits();
    for i = 0, allTraits:size() - 1 do
        local traitName = allTraits:get(i);
        if not MutiesDiary.ignoredTraitNames[traitName] then
            table.insert(traits, traitName);
        end
    end
    return traits;
end

function MutiesDiary.Player:knownRecipes()
    local knownRecipes = {};
    local allKnownRecipes = self.player:getKnownRecipes();
    for i = 0, allKnownRecipes:size() - 1 do
        local recipeName = allKnownRecipes[i];
        if not MutiesDiary.ignoredRecipeNames[recipeName] then
            table.insert(knownRecipes, recipeName);
        end
    end
    return knownRecipes;
end

function MutiesDiary.Player:perkLevel(perk)
    return self.player:getPerkLevel(perk);
end

---@private
function MutiesDiary.Player:diariesRead()
    local data = self.player:getModData();
    data.MutiesDiary.diariesRead = data.MutiesDiary.diariesRead or {};
    return data.MutiesDiary.diariesRead;
end

---@private
---@param diary MutiesDiary.Diary
function MutiesDiary.Player:entriesReadInDiary(diary)
    local diariesRead = self:diariesRead();
    local diaryId = diary:id();
    diariesRead[diaryId] = diariesRead[diaryId] or {};
    return diariesRead[diaryId];
end

---@param diary MutiesDiary.Diary
function MutiesDiary.Player:hasRead(diary, entryNumber)
    return self:entriesReadInDiary(diary)[entryNumber];
end

function MutiesDiary.Player:skillBoosts()
    local data = self.player:getModData();
    data.MutiesDiary.skillBoosts = data.MutiesDiary.skillBoosts or {};
    return data.MutiesDiary.skillBoosts;
end

function MutiesDiary.Player:skillBoost(skill)
    local skillBoosts = self:skillBoosts();
    skillBoosts[skill] = skillBoosts[skill] or 0.0;
    return skillBoosts[skill];
end

function MutiesDiary.Player:canStudy(entry)
    for skill, xp in pairs(entry.xp) do
        if self:skillBoost(skill) < xp then
            local perk = PerkFactory.getPerkFromName(skill);
            return self:perkLevel(perk) <= entry.skillLevels[skill];
        end
    end
    return false;
end

---@param diary MutiesDiary.Diary
function MutiesDiary.Player:markNewestEntryAsRead(diary)
    self:entriesReadInDiary(diary)[diary:newestEntryNumber()] = true;
end

---@private
------@param diary MutiesDiary.Diary
function MutiesDiary.Player:readEntry(diary, entry)
    local traits = self:traits();
    local traitSet = {};
    for i = 1, #traits do
        traitSet[trait[i]] = true;
    end
    local traitDifference = 0;
    for i = 1, #entry.traits do
        if traitSet[entry.traits[i]] then
            traitDifference = traitDifference + 1;
        end
    end
    local multiplier = 1.0;
    for i = 1, traitDifference do
        if MutiesDiary.multiplicativeTraitPenalty then
            multiplier = multiplier * MutiesDiary.traitPenalty;
        else
            multiplier = multiplier - MutiesDiary.traitPenalty;
        end
    end
    if multiplier < MutiesDiary.penaltyFloor then
        multiplier = MutiesDiary.penaltyFloor;
    end
    for skill, xp in pairs(entry.xp) do
        local perk = PerkFactory.getPerkFromName(skill);
        self.player:getXp():AddXP(perk, xp, false, true, false);
    end
    local recipes = entry.recipes;
    for i = 1, #recipes do
        local recipe = recipes[i];
        if not self.player:isRecipeKnown(recipe) then
            self.player:learnRecipe(recipe);
        end
    end
    self:entriesReadInDiary(diary)[entry.number] = true;
end

---@param diary MutiesDiary.Diary
function MutiesDiary.Player:readEntries(diary, entries)
    for i = 1, #entries do
        self:readEntry(diary, entries[i]);
        local musing = MutiesDiary.randomMusing(self, entry);
        if musing then self.player:setSayLine(musing) end
    end
end

function MutiesDiary.Player:studyEntry(entry)
    for skill, xp in pairs(entry.xp) do
        local perk = PerkFactory.getPerkFromName(skill);
        if self:perkLevel(perk) <= entry.skillLevels[skill] then
            self:skillBoosts()[skill] = math.max(xp, self:skillBoost(skill));
        end
    end
end

function MutiesDiary.Player:studyEntries(entries)
    for i = 1, #entries do
        self:studyEntry(entries[i]);
        local musing = MutiesDiary.randomMusing(self, entry);
        if musing then self.player:setSayLine(musing) end
    end
end

---@param player IsoPlayer
---@return MutiesDiary.Player
function MutiesDiary.Player:new(player)
    local object = {};
    setmetatable(object, self);
    self.__index = self;

    object.player = player;

    return object;
end