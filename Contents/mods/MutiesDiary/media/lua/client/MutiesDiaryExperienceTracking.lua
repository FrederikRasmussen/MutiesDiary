require "MutiesDiary"

---@param character IsoGameCharacter
---@param perk PerkFactory.Perk
---@param amount float
function MutiesDiary.addXP(character, perk, amount)
    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(character);
    player:rememberXp(getGameTime():getDay(), perk:getName(), amount);
end
Events.AddXP.Add(MutiesDiary.addXP);

function MutiesDiary.cleanupXP()
    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(getPlayer());
    local days = player:daysRemembered();
    local daysUntilForgotten = 7;
    local today = getGameTime():getDay();
    for i = 1, #days do
        local day = days[i];
        if day + daysUntilForgotten < today then
            player:forgetDay(day);
        end
    end
end
Events.EveryTenMinutes.Add(MutiesDiary.cleanupXP);