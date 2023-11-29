require "MutiesDiary"

---@param player IsoPlayer
---@param perk PerkFactory.Perk
---@param amount float
function MutiesDiary.addXP(character, perk, amount)
    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(character);
    player:rememberXp(getGameTime():getDay(), perk:getName(), amount);
    local skillBoost = player:skillBoost(perk:getName());
    if skillBoost > 0.0 then
        if amount > skillBoost then
            player:skillBoosts()[perk:getName()] = 0.0;
            amount = skillBoost;
        else
            player:skillBoosts()[perk:getName()] = skillBoost - amount;
        end
        character:getXp():AddXP(perk, amount * MutiesDiary.studyMultiplier, false, true, false);
    end
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