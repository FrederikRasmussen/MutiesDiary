require "DearDiary";

---@param player IsoGameCharacter | IsoObject
---@param perk PerkFactory.Perk
---@param amount float
function DearDiary.addXP(player, perk, amount)
    local playerData = player:getModData();

    playerData.xpByDay = playerData.xpByDay or {};
    local day = getGameTime():getDay();
    playerData.xpByDay[day] = playerData.xpByDay[day] or {};
    local perkName = perk:getName();
    playerData.xpByDay[day][perkName] = playerData.xpByDay[day][perkName] or 0.0;
    playerData.xpByDay[day][perkName] = playerData.xpByDay[day][perkName] + amount;
end
Events.AddXP.Add(DearDiary.addXP);

function DearDiary.cleanupXP()
    local playerData = getPlayer():getModData();

    local daysUntilForgotten = 7;
    local today = getGameTime():getDay();
    local diaryXp = playerData.xpByDay;
    if diaryXp then
        for day, _ in pairs(diaryXp) do
            if day + daysUntilForgotten < today then
                diaryXp[day] = nil;
            end
        end
    end
end
Events.EveryTenMinutes.Add(DearDiary.cleanupXP);