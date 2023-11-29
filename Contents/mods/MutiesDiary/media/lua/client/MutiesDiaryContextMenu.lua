require "MutiesDiary"
require "MutiesDiary/Diary"
require "MutiesDiary/Player"
require "ISUI/ISInventoryPaneContextMenu"

local MutiesDiaryContextMenu = {};
---@param character IsoPlayer
---@param item InventoryItem
local function addRenameContextForSingleItem(character, context, item)
    if not instanceof(item, "InventoryItem") then
        item = item.items[1];
    end
    ---@type MutiesDiary.Diary
    local diary = MutiesDiary.Diary:new(item);
    if not diary then return false end
    ---@type MutiesDiary.Player
    local player = MutiesDiary.Player:new(character);
    if not diary:ownedBy(player) then return false end

    local option = context:addOption(
            getText("IGUI_Rename"),
            item,
            MutiesDiaryContextMenu.onRenameDiary, player
    );
    option.iconTexture = getTexture("media/ui/icons/Drive File Rename Outline.png");
    return option;
end

function MutiesDiaryContextMenu.addRenameContext(playerNum, context, items)
    ---@type IsoPlayer
    local player = getSpecificPlayer(playerNum);
    if player:HasTrait("Illiterate") then
        return;
    end
    for _, item in ipairs(items) do
        if addRenameContextForSingleItem(player, context, item) then
            return;
        end
    end
end
Events.OnPreFillInventoryObjectContextMenu.Add(MutiesDiaryContextMenu.addRenameContext);

---@param item InventoryItem
---@param player MutiesDiary.Player
function MutiesDiaryContextMenu.onRenameDiary(item, player)
    ---@type MutiesDiary.Diary
    local diary = MutiesDiary.Diary:new(item);
    local x, y, width, height = 0, 0, 280, 100;
    local args = { player = player, diary = diary};
    local modal = ISTextBox:new(
            x, y,
            width, height,
            diary:displayName() .. ":",
            diary:name(),
            nil,
            MutiesDiaryContextMenu.onRenameDiaryClick,
            player:playerNum(),
            args.player, args.diary
    );
    modal:initialise();
    modal:addToUIManager();
end

---@param button ISButton | ISUIElement
---@param player MutiesDiary.Player
---@param diary MutiesDiary.Diary
function MutiesDiaryContextMenu.onRenameDiaryClick(target, button, player, diary)
    if button.internal ~= "OK" then
        return;
    end

    ---@type ISTextBox
    local textBox = button:getParent();
    local text = textBox.entry:getText();
    if not text or text == "" then
        return;
    end

    diary:rename(text);
    ---@type ISPlayerData
    local playerId = player:playerNum();
    getPlayerInventory(playerId):refreshBackpacks();
    getPlayerLoot(playerId):refreshBackpacks();
end