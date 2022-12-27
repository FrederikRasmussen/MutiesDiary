require "ISUI/ISToolTipInv";
require "DearDiary";

---@param diary InventoryItem
function DearDiary.interpretDiaryForTooltip(diary)
    local diaryData = diary:getModData();

    if not diaryData.username then
        return "An untainted diary.";
    end

    local names = {};
    local nameString = "";

    local skills = {};
    local skillXP = {};

    local entries = diaryData.entries;
    for i = 1, #entries do
        local entry = entries[i];
        local name = entry.writtenBy;
        if not names[name] then
            names[name] = true;
            if nameString == "" then
                nameString = name;
            else
                nameString = nameString .. ", " .. name;
            end
        end
        for skill, xp in pairs(entry.xp) do
            if not skillXP[skill] then
                table.insert(skills, skill);
                skillXP[skill] = 0;
            end
            skillXP[skill] = skillXP[skill] + xp;
        end
    end

    local text = "Written by " .. nameString .. "\n\n";
    table.sort(skills);
    for i = 1, #skills do
        local skill = skills[i];
        local xp = skillXP[skill];
        text = text .. skill .. " (" .. xp .. "xp)\n";
    end

    return text;
end

---@param inventoryTooltip ISToolTipInv
function DearDiary.renderTooltip(inventoryTooltip)
    if ISContextMenu.instance and ISContextMenu.instance.visibleCheck then
        return;
    end
    if not inventoryTooltip.item then
        return;
    end
    ---@type InventoryItem
    local diary = inventoryTooltip.item;
    if diary:getFullType() ~= "Mutie.Diary" then
        return;
    end
    if (inventoryTooltip.x <= 0 or inventoryTooltip.y <= 0) then
        return;
    end

    local text = DearDiary.interpretDiaryForTooltip(diary);
    ---@type UIFont
    local drawFont = UIFont[getCore():getOptionTooltipFont()];

    ---@type UIElement
    local tooltip = inventoryTooltip.tooltip;
    local currentX = 0;
    local currentY = tooltip:getHeight() - 1;
    if inventoryTooltip.followMouse then
        currentX = currentX + getMouseX();
    end
    local currentWidth = tooltip:getWidth();
    local textWidth = math.max(
            currentWidth + 11,
            getTextManager():MeasureStringX(drawFont, text)
    );
    local diaryTooltipWidth = textWidth;
    local textHeight = getTextManager():MeasureStringY(drawFont, text);

    local backgroundColour = inventoryTooltip.backgroundColor;
    inventoryTooltip:drawRect(
            0, currentY,
            diaryTooltipWidth, textHeight,
            backgroundColour.a, backgroundColour.r, backgroundColour.g, backgroundColour.b
    );

    local borderColour = inventoryTooltip.borderColor;
    inventoryTooltip:drawRectBorder(
            0, currentY,
            diaryTooltipWidth, textHeight,
            borderColour.a, borderColour.r, borderColour.g, borderColour.b
    );
    tooltip:DrawText(
            drawFont, text,
            5, currentY + 8,
            1.0, 1.0, 0.8, 1.0
    );
end

local originalISToolTipInvRender = ISToolTipInv.render;
function ISToolTipInv:render()
    DearDiary.renderTooltip(self);
    originalISToolTipInvRender(self);
end