require "MutiesDiary"

---@class MutiesDiary.Diary
MutiesDiary.Diary = {
    item = Literature or InventoryItem
};
MutiesDiary.Diary.Type = "MutiesDiary.Diary";

function MutiesDiary.Diary:id()
    return self.item:getID();
end

function MutiesDiary.Diary:name()
    return self.item:getName();
end

function MutiesDiary.Diary:rename(name)
    self.item:setName(name);
end

function MutiesDiary.Diary:displayName()
    return self.item:getDisplayName();
end

function MutiesDiary.Diary:owner()
    return self.item:getModData().username or nil;
end

---@param player MutiesDiary.Player
function MutiesDiary.Diary:changeOwner(player)
    self.item:getModData().username = player:username();
end

---@param player MutiesDiary.Player
function MutiesDiary.Diary:ownedBy(player)
    if player:hasNoSteamId() then return true end
    return player:username() == self:owner();
end

---@private
function MutiesDiary.Diary:entries()
    local data = self.item:getModData();
    data.entries = data.entries or {};
    return data.entries;
end

function MutiesDiary.Diary:addEntry(entry)
    local entries = self:entries();
    table.insert(entries, entry);
end

function MutiesDiary.Diary:unwritten()
    return #self:entries() <= 0;
end

function MutiesDiary.Diary:numberOfEntries()
    return #self:entries();
end

function MutiesDiary.Diary:newestEntryNumber()
    return self:numberOfEntries();
end

function MutiesDiary.Diary:entry(index)
    return self:entries()[index];
end

---@param player MutiesDiary.Player
function MutiesDiary.Diary:numberOfUnreadEntries(player)
    local number = 0;
    for i = 1, self:numberOfEntries() do
        if not player:hasRead(self, i) then
            number = number + 1;
        end
    end
    return number;
end

---@param player MutiesDiary.Player
function MutiesDiary.Diary:unreadEntries(player)
    local unreadEntries = {};
    for i = 1, self:numberOfEntries() do
        if not player:hasRead(self, i) then
            table.insert(unreadEntries, self:entry(i));
        end
    end
    return unreadEntries;
end

---@param player MutiesDiary.Player
function MutiesDiary.Diary:entriesForStudy(player)
    local entriesForStudy = {};
    for i = 1, self:numberOfEntries() do
        if player:canStudy(self:entry(i)) then
            table.insert(entriesForStudy, self:entry(i));
        end
    end
    return entriesForStudy;
end

function MutiesDiary.Diary:numberOfReadPages()
    return self.item:getAlreadyReadPages();
end

---@param item Literature | InventoryItem
---@return MutiesDiary.Diary
function MutiesDiary.Diary:new(item)
    if item:getFullType() ~= "Mutie.Diary" then return nil end

    local object = {};
    setmetatable(object, self);
    self.__index = self;

    object.item = item;

    return object;
end