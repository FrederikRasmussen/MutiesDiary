require "MutiesDiary";
require "MutiesDiary/Diary";
require "ISUI/ISToolTipInv";

---@param diary MutiesDiary.Diary
function MutiesDiary.interpretDiaryForTooltip(diary)
    if not diary:owner() then
        return "An open book to write in.";
    end

    local names = {};
    local nameString = "";
    local skills = {};
    local skillXP = {};
    for i = 1, diary:numberOfEntries() do
        local entry = diary:entry(i);
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
        local xpText = string.format("%.2f", xp);
        xpText = string.gsub(xpText, "%.00", "");
        xpText = string.gsub(xpText, "(%.%d)0", "%1")
        text = string.format("%s%s (%sxp)\n", text, skill, xpText);
    end

    local player = MutiesDiary.Player:new(getPlayer());
    local readPages = diary:numberOfEntries() - diary:numberOfUnreadEntries(player);
    local readingProgressText =
            "Entries read: " .. readPages .. "/" .. diary:numberOfEntries();
    text = text .. "\n" .. readingProgressText

    return text;
end

---@param inventoryTooltip ISToolTipInv
function MutiesDiary.renderTooltip(inventoryTooltip)
    if ISContextMenu.instance and ISContextMenu.instance.visibleCheck then return end
    if not inventoryTooltip.item then return end
    ---@type MutiesDiary.Diary
    local diary = MutiesDiary.Diary:new(inventoryTooltip.item);
    if not diary then return end
    if (inventoryTooltip.x <= 0 or inventoryTooltip.y <= 0) then return end

    local text = MutiesDiary.interpretDiaryForTooltip(diary);

    ---@type UIFont
    local drawFont = UIFont[getCore():getOptionTooltipFont()];
    ---@type UIElement
    local tooltip = inventoryTooltip.tooltip;

    --Mimic vanilla style
    local topMargin = 5;
    local bottomMargin = 5;
    local leftMargin = 5;
    local rightMargin = 6;

    local x = 0;
    local y = tooltip:getHeight() - 1;
    local width = math.max(
            tooltip:getWidth() + leftMargin + rightMargin,
            getTextManager():MeasureStringX(drawFont, text) + 20
    );
    local height =
            getTextManager():MeasureStringY(drawFont, text)
                    + topMargin
                    + bottomMargin;

    local backgroundColour = inventoryTooltip.backgroundColor;
    inventoryTooltip:drawRect(
            x, y,
            width, height,
            backgroundColour.a, backgroundColour.r, backgroundColour.g, backgroundColour.b
    );

    local borderColour = inventoryTooltip.borderColor;
    inventoryTooltip:drawRectBorder(
            x, y,
            width, height,
            borderColour.a, borderColour.r, borderColour.g, borderColour.b
    );
    tooltip:DrawText(
            drawFont, text,
            leftMargin + x, y + topMargin,
            1.0, 1.0, 0.8, 1.0
    );
end

local originalISToolTipInvRender = ISToolTipInv.render;
function ISToolTipInv:render()
    MutiesDiary.renderTooltip(self);
    originalISToolTipInvRender(self);
end