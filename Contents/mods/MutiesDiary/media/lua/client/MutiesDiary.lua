if not MutiesDiary then
    MutiesDiary = {};
    MutiesDiary.ignoredTraitNames = {};
    MutiesDiary.ignoredRecipeNames = {};
    MutiesDiary.musingChance = 0;
    MutiesDiary.genericMusings = {};
    MutiesDiary.studyMultiplier = 4.0;
    MutiesDiary.multiplicativeTraitPenalty = true;
    MutiesDiary.traitPenalty = 0.2;
    MutiesDiary.penaltyFloor = 0.4;
end

function MutiesDiary.loadModOptions()

end

function MutiesDiary.loadSandboxVars()

end

function MutiesDiary.loadSettings()
    MutiesDiary.musingChance = 65;
    MutiesDiary.genericMusings = {
        "Hm..", "Mhm.", "Mh.",
        "Uh-huh.", "Huh.",
        "I see..", "Of course.", "Naturally.", "That's clear.",
        "Interesting.", "How did they manage..",
        "What else?", "As if..", "Sure thing."
    };
    MutiesDiary.loadModOptions();
    MutiesDiary.loadSandboxVars();
end
Events.OnInitGlobalModData(MutiesDiary.loadSettings);

---@param item InventoryItem
---@return boolean
function MutiesDiary.isDiary(item)
    return item:getFullType() == "Mutie.Diary";
end

---@param player MutiesDiary.Player
---@param entry table
function MutiesDiary.randomMusing(player, entry)
    local probabilityNone = 100 - MutiesDiary.musingChance;
    if probabilityNone < ZombRand(0, 100) then
        return nil;
    end

    local phraseCount = #MutiesDiary.genericMusings;
    local phraseRoll = ZombRand(0, phraseCount);
    return MutiesDiary.genericMusings[phraseRoll];
end