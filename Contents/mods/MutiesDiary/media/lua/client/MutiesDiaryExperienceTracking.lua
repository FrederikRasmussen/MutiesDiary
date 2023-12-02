require "MutiesDiary"

local trackXP = true;
---@param character IsoGameCharacter
---@param perk PerkFactory.Perk
---@param amount float
function MutiesDiary.addXP(character, perk, amount)
    if not trackXP then return end
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

local originalISRadioInteractionsCheckPlayer = ISRadioInteractions:getInstance().checkPlayer;
local radioInteractions = ISRadioInteractions:getInstance();
function radioInteractions.checkPlayer(player, _guid, _interactCodes, _x, _y, _z, _line, _source)
    trackXP = false;
    originalISRadioInteractionsCheckPlayer(player, _guid, _interactCodes, _x, _y, _z, _line, _source);
    trackXP = true;
end